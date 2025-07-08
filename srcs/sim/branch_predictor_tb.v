`timescale 1ns / 1ps

// BRANCH PREDICTOR TESTBENCH
// Engineer: Sadad Haidari
//
// This testbench validates our AI-inspired branch predictor.
// It simulates realistic branch patterns and measures its accuracy.

module branch_predictor_tb();
    reg clk, reset;
    reg isBranch;
    reg [31:0] branchPC;
    reg [2:0] branchT;
    reg branchResolved;
    reg actualTaken;
    reg [31:0] resolvedPC;
    wire predictTaken;
    wire [3:0] confidence;
    wire predictionValid;
    wire [15:0] totalPredictions;
    wire [15:0] correctPredictions;
    wire [7:0] accuracyPresent;

    // Test Management
    integer testCount = 0;
    integer passCount = 0;
    integer failCount = 0;

    // Pattern Tracking
    reg [31:0] pcSequence [0:99]; // Store program counter sequence for pattern testing.
    reg patternTaken [0:99]; // Store pattern taken/not-taken for pattern testing.
    integer patternLength = 0;

    // Move these reg/integer declarations to module level
    reg predictedTaken;
    reg [3:0] predictionConfidence;
    reg alternatingPattern;
    reg randomTaken;
    integer confidenceTest;
    integer stressTest;
    integer patternFound;
    integer takenBurst;
    integer notTakenBurst;
    integer i, j;
    integer loopTest;
    reg [127:0] patternT;
    reg [7:0] pseudoRandom;

    // DEVICE UNDER TEST
    branch_predictor uut (
        .clk(clk),
        .reset(reset),
        .isBranch(isBranch),
        .branchPC(branchPC),
        .branchT(branchT),
        .branchResolved(branchResolved),
        .actualTaken(actualTaken),
        .resolvedPC(resolvedPC),
        .predictTaken(predictTaken),
        .confidence(confidence),
        .predictionValid(predictionValid),
        .totalPredictions(totalPredictions),
        .correctPredictions(correctPredictions),
        .accuracyPresent(accuracyPresent)
    );

    // CLOCK GENERATION
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

// HELPER FUNCTION
    // Gets the branch format name for display.
    function [48:0] getBranchName;
        input [2:0] bT;
        begin
            case (bT)
            3'b000: getBranchName = "BEQ";
            3'b001: getBranchName = "BNE";
            3'b010: getBranchName = "RESERVED";
            3'b011: getBranchName = "RESERVED";
            3'b100: getBranchName = "BLT";
            3'b101: getBranchName = "BGE";
            3'b110: getBranchName = "BLTU";
            3'b111: getBranchName = "BGEU";
            default: getBranchName = "UNKNOWN";
            endcase
        end
    endfunction

    // BRANCH PREDICTION AND TRAINING TASK
    // This simulates the pipeline behavior: predict, execute, then train.
    task testBranchSequence;
        input [31:0] pc;
        input [2:0] bT;
        input taken;
        input [100*8-1:0] description;

        begin
            testCount = testCount + 1;

            // PREDICTION PHASE
            @(posedge clk);
            isBranch = 1;
            branchPC = pc;
            branchT = bT;
            branchResolved = 0;

            @(posedge clk); // Wait for prediction to stabilize.

            // Capture prediction.
            predictedTaken = predictTaken;
            predictionConfidence = confidence;

            // EXECUTION PHASE
            @(posedge clk);
            isBranch = 0; // No new branch this cycle.

            // TRAINING PHASE
            branchResolved = 1;
            actualTaken = taken;
            resolvedPC = pc;

            @(posedge clk);
            branchResolved = 0;

            // RESULT ANALYSIS
            $display("Test %0d: %s", testCount, description);
            $display("  Program Counter: 0x%h", pc);
            $display("  Branch Format: %0d (%s)", bT, getBranchName(bT));
            $display("  Predicted: %s (confidence: %0d)", predictedTaken ? "TAKEN" : "NOT-TAKEN", predictionConfidence);
            $display("  Actual: %s", taken ? "TAKEN" : "NOT-TAKEN");

            if (predictedTaken == taken) begin
                $display("  PASS: Prediction matches actual outcome.");
                passCount = passCount + 1;
            end else begin
                $display("  FAIL: Prediction does not match actual outcome.");
                failCount = failCount + 1;
            end

            $display("   Accuracy: %0d%% (%0d/%0d)", accuracyPresent, correctPredictions, totalPredictions);
            $display("");

            // Store in pattern sequence for monitoring.
            if (patternLength < 100) begin
                pcSequence[patternLength] = pc;
                patternTaken[patternLength] = taken;
                patternLength = patternLength + 1;
            end
        end
    endtask

    // PATTERN ANALYSIS TASK
    task analyzePattern;
        begin
            $display("Pattern Analysis:");
            $display("Stored %0d branch outcomes for analysis.", patternLength);

            // Look for simple patterns.
            patternFound = 0;

            // Check for alternating patterns (T, N, T, N, ...).
            alternatingPattern = 1;
            for (i = 1; i < patternLength; i = i + 1) begin
                if (patternTaken[i] == patternTaken[i-1]) begin
                    alternatingPattern = 0;
                end
            end

            if (alternatingPattern && patternLength >= 4) begin
                $display("  DETECTED: Alternating pattern.");
                patternFound = 1;
                patternT = "Alternating";
            end

            // Check for consecutive taken/not-taken bursts.
            takenBurst = 0;
            notTakenBurst = 0;
            for (i = 0; i < patternLength; i = i + 1) begin
                if (patternTaken[i]) takenBurst = takenBurst + 1;
                else notTakenBurst = notTakenBurst + 1;
            end

            if (takenBurst > notTakenBurst * 2) begin
                $display("  DETECTED: Taken burst (%0d taken, %0d not taken).", takenBurst, notTakenBurst);
                patternFound = 1;
                patternT = "Taken Burst";
            end else if (notTakenBurst > takenBurst * 2) begin
                $display("  DETECTED: Not-taken burst (%0d not taken, %0d taken).", notTakenBurst, takenBurst);
                patternFound = 1;
                patternT = "Not-Taken Burst";
            end

            if (!patternFound) begin
                $display("  No simple pattern detected, random behavior alert!");
                patternT = "Random";
            end

            $display("");
        end
    endtask

    // REALISTIC LOOP SIMULATION TASK
    task simulateLoop;
        input [31:0] loopPC;
        input [2:0] bType;
        input integer iterations;
        input [100*8-1:0] description;
        begin
            $display("=== %s ===", description);
            for (loopTest = 1; loopTest <= iterations; loopTest = loopTest + 1) begin
                $display("Loop iteration %0d/%0d", loopTest, iterations);
                testBranchSequence(loopPC, bType, 1, "Loop iteration.");
            end
            testBranchSequence(loopPC, bType, 0, "Loop exit | not-taken.");
        end
    endtask

    // MAIN TEST SEQUENCE
    initial begin
        $display("================================================");
        $display("     ENHANCED BRANCH PREDICTOR TESTBENCH       ");
        $display("================================================");

        // INITIALIZATION
        isBranch = 0;
        branchResolved = 0;
        actualTaken = 0;
        branchPC = 0;
        branchT = 0;

        // RESET SEQUENCE
        $display("Initializing predictor...");
        reset = 1;
        repeat (5) @(posedge clk);
        reset = 0;
        repeat (3) @(posedge clk);

        $display("Predictor ready.");
        $display("Initial accuracy: %0d%%\n", accuracyPresent);

        // TEST 1: BASIC LEARNING
        $display("Test 1: Basic Prediction");
        testBranchSequence(32'h1000, 3'b000, 0, "Cold start BEQ | expect not-taken prediction.");
        testBranchSequence(32'h1004, 3'b001, 1, "Cold start BNE | learning begins.");
        testBranchSequence(32'h1008, 3'b100, 1, "Cold start BLT | learning begins.");

        // TEST 2: REALISTIC LOOP PATTERNS
        $display("Test 2: Realistic Loop Patterns");
        simulateLoop(32'h2000, 3'b001, 5, "Small loop (5 iterations)");
        simulateLoop(32'h3000, 3'b000, 10, "Medium loop (10 iterations)");
        simulateLoop(32'h4000, 3'b100, 15, "Large loop (15 iterations)");

        // TEST 3: BRANCH TYPE LEARNING
        $display("Test 3: Branch Type Specialization");
        for (i = 0; i < 6; i = i + 1) begin
            testBranchSequence(32'h5000 + i*4, 3'b000, 1, "BEQ training | taken.");
        end
        for (i = 0; i < 6; i = i + 1) begin
            testBranchSequence(32'h6000 + i*4, 3'b001, 0, "BNE training | not taken.");
        end
        testBranchSequence(32'h5100, 3'b000, 1, "BEQ test | should predict taken.");
        testBranchSequence(32'h6100, 3'b001, 0, "BNE test | should predict not taken.");

        // TEST 4: ALTERNATING PATTERN RECOGNITION
        $display("Test 4: Alternating Pattern Recognition");
        for (i = 0; i < 8; i = i + 1) begin
            $display("Alternating pattern %0d", i + 1);
            testBranchSequence(32'h7000, 3'b000, i % 2, "Alternating pattern.");
        end

        // TEST 5: CONFIDENCE BUILDING
        $display("=== TEST 5: Confidence Building ===");
        for (confidenceTest = 0; confidenceTest < 12; confidenceTest = confidenceTest + 1) begin
            $display("Confidence building iteration %0d", confidenceTest + 1);
            testBranchSequence(32'h8000, 3'b001, 1, "Confidence building iteration.");
        end

        // TEST 6: MIXED REALISTIC SCENARIOS
        $display("=== TEST 6: Mixed Realistic Scenarios ===");
        for (i = 0; i < 3; i = i + 1) begin
            testBranchSequence(32'h9000, 3'b000, 1, "Outer loop iteration.");
            for (j = 0; j < 4; j = j + 1) begin
                testBranchSequence(32'h9010, 3'b001, 1, "Inner loop iteration.");
            end
            testBranchSequence(32'h9010, 3'b001, 0, "Inner loop exit.");
        end
        testBranchSequence(32'h9000, 3'b000, 0, "Outer loop exit.");

        // TEST 7: CONTROLLED RANDOM STRESS TEST
        $display("Test 7: Controlled Random Test");
        pseudoRandom = 8'b10110100;
        for (stressTest = 0; stressTest < 8; stressTest = stressTest + 1) begin
            $display("Controlled random test %0d", stressTest + 1);
            randomTaken = pseudoRandom[stressTest];
            testBranchSequence(32'hA000 + (stressTest * 4),
                               stressTest % 4,
                               randomTaken,
                               "Controlled random test.");
        end

        // PATTERN ANALYSIS
        analyzePattern();

        // FINAL REPORT
        $display("================================================");
        $display("              TEST RESULTS SUMMARY              ");
        $display("================================================");
        $display("Main Test Results:");
        $display("  Total Tests: %0d", testCount);
        $display("  Correct Predictions: %0d", passCount);
        $display("  Failed Predictions: %0d", failCount);
        $display("  Total Predictions: %0d", totalPredictions);
        $display("  Test Success Rate: %0d%%", (passCount * 100) / testCount);
        $display("");
        $display("Predictor Statistics:");
        $display("  Total Predictions Made: %0d", totalPredictions);
        $display("  Correct Predictions: %0d", correctPredictions);
        $display("  Accuracy: %0d%%", accuracyPresent);
        $display("");
        $display("Pattern Analysis:");
        $display("  Stored %0d branch outcomes for analysis.", patternLength);
        $display("  Pattern Found: %s", patternFound ? "Yes" : "No");
        $display("  Pattern Type: %s", patternFound ? patternT : "None");
        $display("  Pattern Length: %0d", patternLength);
        $display("================================================");

        // EVALUATION
        if (accuracyPresent >= 70) begin
            $display("EXCELLENT: Predictor accuracy >= 70%");
        end else if (accuracyPresent >= 50) begin
            $display("GOOD: Predictor accuracy >= 50% (better than random).");
        end else begin
            $display("POOR: Predictor accuracy < 50% (needs improvement).");
        end
        // Check if all tests passed.
        if (testCount > 0 && (passCount * 100 / testCount) >= 70) begin
            $display("TEST SUITE: PASSED (>= 70%% individual tests correct).");
        end else begin
            $display("TEST SUITE: NEEDS REVIEW.");
        end
        $display("================================================");
        $finish;
    end

    // TIMEOUT PROTECTION
    initial begin
        #10000000; // 10ms timeout.
        $display("================================================");
        $display("          TEST TIMEOUT OCCURRED!                ");
        $display("================================================");
        $finish;
    end
endmodule