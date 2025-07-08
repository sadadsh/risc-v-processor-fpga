`timescale 1ns / 1ps

// WORKLOAD CLASSIFIER TESTBENCH
// Engineer: Sadad Haidari
//
// This testbench validates the AI-inspired workload_classifier module.
// It tests each classification scenario in isolation and verifies feature
// extraction, pattern recognition, and classification confidence.

module workload_classifier_tb;

    // TESTBENCH CONTROL SIGNALS
    reg clk;
    reg reset;
    
    // PROCESSOR ACTIVITY INPUTS
    reg instructionValid;
    reg [6:0] opcode;
    reg [2:0] fun3;
    reg isBranch;
    reg branchTaken;
    reg [31:0] resultALU;
    reg activeALU;
    reg [3:0] opALU;
    reg regWrite;
    reg [4:0] regAddress;
    reg [31:0] regData;
    reg [31:0] totalInstructions;
    reg [31:0] totalOperationsALU;
    reg [31:0] totalRegAccesses;
    reg [7:0] currentPower;
    
    // WORKLOAD CLASSIFIER OUTPUTS
    wire [2:0] workloadFormat;
    wire [3:0] workloadConfidence;
    wire [7:0] computeToll;
    wire [7:0] memToll;
    wire [7:0] controlToll;
    wire [7:0] complexPattern;
    wire [15:0] classificationCount;
    wire [7:0] adaptationRate;
    wire classificationValid;
    
    // TEST CONTROL VARIABLES
    reg [31:0] testCycle;
    reg [7:0] currentTestPhase;
    reg [15:0] phaseInstructionCount;
    reg [15:0] totalErrors;
    reg [15:0] totalPasses;
    reg [7:0] expectedWorkloadType;
    reg [7:0] expectedMinConfidence;
    
    // STATISTICS TRACKING
    reg [31:0] totalClassifications;
    reg [31:0] correctClassifications;
    reg [7:0] classificationHistory [0:63];
    reg [5:0] historyIndex;
    reg [15:0] convergenceTime [0:7];
    reg [7:0] stabilityCounter;
    reg [2:0] lastClassification;
    
    // CONSTANTS
    localparam WLUNKNOWN      = 3'b000;
    localparam WLCOMPUTE      = 3'b001;
    localparam WLMEMORY       = 3'b010;
    localparam WLCONTROL      = 3'b011;
    localparam WLMIXED        = 3'b100;
    localparam WLIDLE         = 3'b101;
    localparam WLSTREAMING    = 3'b110;
    localparam WLIRREGULAR    = 3'b111;
    
    localparam OPCODERT     = 7'b0110011;
    localparam OPCODEIT     = 7'b0010011;
    localparam OPCODELOAD   = 7'b0000011;
    localparam OPCODESTORE  = 7'b0100011;
    localparam OPCODEBRANCH = 7'b1100011;
    localparam OPCODEJAL    = 7'b1101111;
    localparam OPCODEJALR   = 7'b1100111;
    
    // TEST PHASES
    localparam PHASEINIT           = 0;
    localparam PHASECOMPUTEPURE    = 1;
    localparam PHASEMEMORYPURE     = 2;
    localparam PHASECONTROLPURE    = 3;
    localparam PHASEMIXEDBALANCED  = 4;
    localparam PHASELOWACTIVITY    = 5;
    localparam PHASESTREAMING      = 6;
    localparam PHASEIRREGULAR      = 7;
    localparam PHASEFINALANALYSIS  = 8;
    
    localparam PERPHASEINSTRUCTIONS = 150;
    
        
    reg [7:0] pseudoRandom;
    integer i;
    integer loopTest;
    integer confidenceTest;
    integer stressTest;
    integer patternFound;
    integer takenBurst;
    integer notTakenBurst;
    integer j;
    reg [7:0] phaseAccuracy;
    reg [7:0] overallAccuracy;
    reg [15:0] avgConvergenceTime;
    reg [7:0] convergenceCount;
    
    // MODULE INSTANTIATION
    workload_classifier uut (
        .clk(clk),
        .reset(reset),
        .instructionValid(instructionValid),
        .opcode(opcode),
        .fun3(fun3),
        .isBranch(isBranch),
        .branchTaken(branchTaken),
        .resultALU(resultALU),
        .activeALU(activeALU),
        .opALU(opALU),
        .regWrite(regWrite),
        .regAddress(regAddress),
        .regData(regData),
        .totalInstructions(totalInstructions),
        .totalOperationsALU(totalOperationsALU),
        .totalRegAccesses(totalRegAccesses),
        .currentPower(currentPower),
        .workloadFormat(workloadFormat),
        .workloadConfidence(workloadConfidence),
        .computeToll(computeToll),
        .memToll(memToll),
        .controlToll(controlToll),
        .complexPattern(complexPattern),
        .classificationCount(classificationCount),
        .adaptationRate(adaptationRate),
        .classificationValid(classificationValid)
    );
    
    // CLOCK GENERATION
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // TEST INITIALIZATION
    initial begin
        // Initialize signals
        reset = 0;
        instructionValid = 0;
        opcode = 7'h0;
        fun3 = 3'h0;
        isBranch = 0;
        branchTaken = 0;
        resultALU = 32'h0;
        activeALU = 0;
        opALU = 4'h0;
        regWrite = 0;
        regAddress = 5'h0;
        regData = 32'h0;
        totalInstructions = 32'h0;
        totalOperationsALU = 32'h0;
        totalRegAccesses = 32'h0;
        currentPower = 8'h80;
        
        // Initialize test variables
        testCycle = 32'h0;
        currentTestPhase = PHASEINIT;
        phaseInstructionCount = 16'h0;
        totalErrors = 16'h0;
        totalPasses = 16'h0;
        expectedWorkloadType = WLUNKNOWN;
        expectedMinConfidence = 4'h6;
        
        // Initialize statistics
        totalClassifications = 32'h0;
        correctClassifications = 32'h0;
        historyIndex = 6'h0;
        stabilityCounter = 8'h0;
        lastClassification = WLUNKNOWN;
        
        // Initialize arrays
        for (i = 0; i < 64; i = i + 1) begin
            classificationHistory[i] = WLUNKNOWN;
        end
        for (i = 0; i < 8; i = i + 1) begin
            convergenceTime[i] = 16'hFFFF;
        end
        
        $display("=== WORKLOAD CLASSIFIER TESTBENCH ===");
        $display("Time: %0t | Starting comprehensive validation", $time);
        
        // Apply reset
        #20;
        reset = 1;
        #40;
        
        $display("Time: %0t | Reset complete, beginning test phases", $time);
    end
    
    // MAIN TEST CONTROL
    always @(posedge clk) begin
        if (reset) begin
            testCycle <= testCycle + 1;

            // Phase management
            if (phaseInstructionCount >= PERPHASEINSTRUCTIONS && currentTestPhase < PHASEFINALANALYSIS) begin
                logPhaseResults();
                currentTestPhase <= currentTestPhase + 1;
                phaseInstructionCount <= 16'h0;
                setPhaseExpectations();
                $display("Time: %0t | Starting Phase %0d", $time, currentTestPhase + 1);
            end

            if (currentTestPhase == PHASEFINALANALYSIS && testCycle > 100) begin
                generateFinalReport();
                $finish;
            end

            // Execute current phase
            case (currentTestPhase)
                PHASEINIT:           executeInitPhase();
                PHASECOMPUTEPURE:    executeComputePurePhase();
                PHASEMEMORYPURE:     executeMemoryPurePhase();
                PHASECONTROLPURE:    executeControlPurePhase();
                PHASEMIXEDBALANCED:  executeMixedBalancedPhase();
                PHASELOWACTIVITY:    executeLowActivityPhase();
                PHASESTREAMING:      executeStreamingPhase();
                PHASEIRREGULAR:      executeIrregularPhase();
                PHASEFINALANALYSIS:  executeFinalAnalysis();
                default:             executeIdle();
            endcase

            // Monitoring: Only check classification every 16 cycles to match classifier cadence
            if ((phaseInstructionCount % 16) == 0 && phaseInstructionCount > 0) begin
                monitorClassification();
            end
            updateStatistics();
        end
    end
    
    // PHASE EXECUTION TASKS
    task executeInitPhase;
    begin
        if (testCycle[3:0] == 4'h0) begin
            instructionValid = 1;
            opcode = OPCODEIT;
            fun3 = 3'b000;
            opALU = 4'b0000;
            activeALU = 1;
            regWrite = 1;
            regAddress = 5'h1;
            regData = 32'h00000001;
            resultALU = regData;
            currentPower = 8'h40;
            phaseInstructionCount = phaseInstructionCount + 1;
            updateCounters();
        end else begin
            instructionValid = 0;
            activeALU = 0;
            regWrite = 0;
            currentPower = 8'h20;
        end
    end
    endtask
    
    task executeComputePurePhase;
    begin
        instructionValid = 1;
        
        case (testCycle[2:0])
            3'b000: begin
                opcode = OPCODERT;
                fun3 = 3'b000; // ADD
                opALU = 4'b0000;
            end
            3'b001: begin
                opcode = OPCODERT;
                fun3 = 3'b001; // SLL
                opALU = 4'b0111;
            end
            3'b010: begin
                opcode = OPCODERT;
                fun3 = 3'b010; // SLT
                opALU = 4'b0101;
            end
            3'b011: begin
                opcode = OPCODEIT;
                fun3 = 3'b000; // ADDI
                opALU = 4'b0000;
            end
            3'b100: begin
                opcode = OPCODERT;
                fun3 = 3'b100; // XOR
                opALU = 4'b0100;
            end
            3'b101: begin
                opcode = OPCODEIT;
                fun3 = 3'b010; // SLTI
                opALU = 4'b0101;
            end
            3'b110: begin
                opcode = OPCODERT;
                fun3 = 3'b110; // OR
                opALU = 4'b0011;
            end
            3'b111: begin
                opcode = OPCODERT;
                fun3 = 3'b001; // SUB
                opALU = 4'b0001;
            end
        endcase
        
        activeALU = 1;
        regWrite = 1;
        isBranch = 0;
        regAddress = testCycle[4:0];
        regData = {testCycle[15:0], testCycle[15:0]};
        resultALU = regData + 32'h12345678;
        currentPower = 8'hC0 + testCycle[3:0];
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeMemoryPurePhase;
    begin
        instructionValid = 1;
        
        if (testCycle[0] == 1'b0) begin
            opcode = OPCODELOAD;
            fun3 = 3'b010; // LW
            activeALU = 0;
            regWrite = 1;
            currentPower = 8'h80 + testCycle[3:0];
        end else begin
            opcode = OPCODESTORE;
            fun3 = 3'b010; // SW
            activeALU = 0;
            regWrite = 0;
            currentPower = 8'h85 + testCycle[3:0];
        end
        
        isBranch = 0;
        regAddress = testCycle[4:0];
        regData = {testCycle[15:0], testCycle[15:0]};
        resultALU = regData;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeControlPurePhase;
    begin
        instructionValid = 1;
        
        case (testCycle[2:0])
            3'b000, 3'b001, 3'b010, 3'b011: begin
                opcode = OPCODEBRANCH;
                fun3 = testCycle[1:0];
                isBranch = 1;
                branchTaken = testCycle[0];
                activeALU = 1;
                opALU = 4'b0001;
                regWrite = 0;
                currentPower = 8'h95 + testCycle[2:0];
            end
            3'b100: begin
                opcode = OPCODEJAL;
                isBranch = 0;
                branchTaken = 0;
                activeALU = 0;
                regWrite = 1;
                currentPower = 8'h70 + testCycle[2:0];
            end
            3'b101: begin
                opcode = OPCODEJALR;
                isBranch = 0;
                branchTaken = 0;
                activeALU = 0;
                regWrite = 1;
                currentPower = 8'h75 + testCycle[2:0];
            end
            default: begin
                opcode = OPCODEBRANCH;
                fun3 = 3'b000;
                isBranch = 1;
                branchTaken = testCycle[1];
                activeALU = 1;
                opALU = 4'b0001;
                regWrite = 0;
                currentPower = 8'h90 + testCycle[2:0];
            end
        endcase
        
        regAddress = testCycle[4:0];
        regData = {testCycle[15:0], ~testCycle[15:0]};
        resultALU = regData;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeMixedBalancedPhase;
    begin
        instructionValid = 1;
        
        case (testCycle[2:0])
            3'b000, 3'b011, 3'b110: begin // Compute
                opcode = OPCODERT;
                fun3 = 3'b000;
                opALU = 4'b0000;
                activeALU = 1;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'hA0;
            end
            3'b001, 3'b100: begin // Memory
                opcode = (testCycle[0] == 1'b0) ? OPCODELOAD : OPCODESTORE;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = (testCycle[0] == 1'b0);
                isBranch = 0;
                currentPower = 8'h85;
            end
            3'b010, 3'b101: begin // Control
                opcode = OPCODEBRANCH;
                fun3 = 3'b000;
                activeALU = 1;
                opALU = 4'b0001;
                regWrite = 0;
                isBranch = 1;
                branchTaken = testCycle[0];
                currentPower = 8'h90;
            end
            3'b111: begin // Memory
                opcode = OPCODELOAD;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h82;
            end
        endcase
        
        regAddress = testCycle[4:0];
        regData = {testCycle[15:0], testCycle[15:0]};
        resultALU = regData;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeLowActivityPhase;
    begin
        if (testCycle[3:0] == 4'h0) begin
            instructionValid = 1;
            opcode = OPCODEIT;
            fun3 = 3'b000;
            opALU = 4'b0000;
            activeALU = 1;
            regWrite = 1;
            regAddress = 5'h1;
            regData = 32'h00000001;
            resultALU = regData;
            isBranch = 0;
            currentPower = 8'h30;
            phaseInstructionCount = phaseInstructionCount + 1;
            updateCounters();
        end else begin
            instructionValid = 0;
            activeALU = 0;
            regWrite = 0;
            isBranch = 0;
            currentPower = 8'h20;
        end
    end
    endtask
    
    task executeStreamingPhase;
    begin
        instructionValid = 1;
        
        case (testCycle[2:0])
            3'b000, 3'b011, 3'b110: begin // Load
                opcode = OPCODELOAD;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 1;
                currentPower = 8'h70;
            end
            3'b001, 3'b100, 3'b111: begin // Process
                opcode = OPCODEIT;
                fun3 = 3'b000;
                opALU = 4'b0000;
                activeALU = 1;
                regWrite = 1;
                currentPower = 8'h75;
            end
            3'b010, 3'b101: begin // Store
                opcode = OPCODESTORE;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 0;
                currentPower = 8'h72;
            end
        endcase
        
        regAddress = (testCycle[6:2] % 8); // Sequential access
        regData = {24'h0, testCycle[7:0]}; // Sequential data
        resultALU = regData + 1;
        isBranch = 0;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeIrregularPhase;
    begin
        instructionValid = 1;
        
        // Pseudo-random pattern
        pseudoRandom = testCycle[7:0] ^ (testCycle[15:8] << 1);
        
        case (pseudoRandom[2:0])
            3'b000: begin
                opcode = OPCODERT;
                fun3 = pseudoRandom[5:3];
                opALU = pseudoRandom[7:4];
                activeALU = 1;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h60 + pseudoRandom[3:0];
            end
            3'b001: begin
                opcode = OPCODELOAD;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h50 + pseudoRandom[3:0];
            end
            3'b010: begin
                opcode = OPCODEBRANCH;
                fun3 = pseudoRandom[4:3];
                activeALU = 1;
                opALU = 4'b0001;
                regWrite = 0;
                isBranch = 1;
                branchTaken = pseudoRandom[0];
                currentPower = 8'h70 + pseudoRandom[3:0];
            end
            default: begin
                opcode = OPCODEIT;
                fun3 = pseudoRandom[5:3];
                opALU = pseudoRandom[7:4];
                activeALU = 1;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h55 + pseudoRandom[3:0];
            end
        endcase
        
        regAddress = pseudoRandom[4:0];
        regData = {pseudoRandom, pseudoRandom, pseudoRandom, pseudoRandom};
        resultALU = regData ^ 32'h55AA55AA;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeFinalAnalysis;
    begin
        instructionValid = 0;
        activeALU = 0;
        regWrite = 0;
        isBranch = 0;
        currentPower = 8'h20;
    end
    endtask
    
    task executeIdle;
    begin
        instructionValid = 0;
        activeALU = 0;
        regWrite = 0;
        isBranch = 0;
        currentPower = 8'h20;
    end
    endtask
    
    // MONITORING TASKS
    task monitorClassification;
    begin
        if (classificationValid && workloadConfidence >= 4) begin
            totalClassifications = totalClassifications + 1;

            classificationHistory[historyIndex] = workloadFormat;
            historyIndex = (historyIndex + 1) % 64;

            if (workloadFormat == expectedWorkloadType) begin
                correctClassifications = correctClassifications + 1;
                totalPasses = totalPasses + 1;

                if (workloadFormat == lastClassification) begin
                    stabilityCounter = stabilityCounter + 1;

                    if (convergenceTime[workloadFormat] == 16'hFFFF && stabilityCounter >= 10) begin
                        convergenceTime[workloadFormat] = testCycle[15:0];
                        $display("Time: %0t | Convergence detected for workload type %0d", 
                                $time, workloadFormat);
                    end
                end else begin
                    stabilityCounter = 8'h0;
                end
                lastClassification = workloadFormat;

            end else begin
                totalErrors = totalErrors + 1;
                stabilityCounter = 8'h0;

                $display("Time: %0t | ERROR: Phase %0d - Expected: %0d, Got: %0d, Confidence: %0d", 
                        $time, currentTestPhase, expectedWorkloadType, workloadFormat, workloadConfidence);
            end

            // Only print summary every 16 instructions
            if ((phaseInstructionCount % 16) == 0) begin
                $display("Time: %0t | Phase %0d: Type=%0d, Conf=%0d, Comp=%0d, Mem=%0d, Ctrl=%0d", 
                        $time, currentTestPhase, workloadFormat, workloadConfidence, 
                        computeToll, memToll, controlToll);
            end
        end
    end
    endtask
    
    task updateStatistics;
    begin
        // Statistics are updated in monitoring task
        // This task can be used for additional statistical analysis
    end
    endtask
    
    task updateCounters;
    begin
        totalInstructions = totalInstructions + 1;
        totalRegAccesses = totalRegAccesses + (regWrite ? 2 : 1);
        if (activeALU) begin
            totalOperationsALU = totalOperationsALU + 1;
        end
    end
    endtask
    
    task setPhaseExpectations;
    begin
        case (currentTestPhase + 1)
            PHASECOMPUTEPURE:    begin expectedWorkloadType = WLCOMPUTE; expectedMinConfidence = 10; end
            PHASEMEMORYPURE:     begin expectedWorkloadType = WLMEMORY; expectedMinConfidence = 10; end
            PHASECONTROLPURE:    begin expectedWorkloadType = WLCONTROL; expectedMinConfidence = 10; end
            PHASEMIXEDBALANCED:  begin expectedWorkloadType = WLMIXED; expectedMinConfidence = 6; end
            PHASELOWACTIVITY:    begin expectedWorkloadType = WLIDLE; expectedMinConfidence = 8; end
            PHASESTREAMING:      begin expectedWorkloadType = WLSTREAMING; expectedMinConfidence = 7; end
            PHASEIRREGULAR:      begin expectedWorkloadType = WLIRREGULAR; expectedMinConfidence = 5; end
            default:             begin expectedWorkloadType = WLUNKNOWN; expectedMinConfidence = 4; end
        endcase
    end
    endtask
    
    task logPhaseResults;
    begin
        if (totalClassifications > 0) begin
            phaseAccuracy = (correctClassifications * 100) / totalClassifications;
        end else begin
            phaseAccuracy = 0;
        end
        
        $display("Time: %0t | Phase %0d Results:", $time, currentTestPhase);
        $display("         Instructions: %0d, Classifications: %0d, Accuracy: %0d%%", 
                phaseInstructionCount, classificationCount, phaseAccuracy);
        $display("         Final Intensities - Compute: %0d, Memory: %0d, Control: %0d", 
                computeToll, memToll, controlToll);
        $display("         Final Classification: Type=%0d, Confidence=%0d", 
                workloadFormat, workloadConfidence);
        $display("");
    end
    endtask
    
    task generateFinalReport;
    begin
        $display("\nWORKLOAD CLASSIFIER FINAL REPORT");
        $display("Test Duration: %0d cycles", testCycle);
        $display("Total Instructions: %0d", totalInstructions);
        
        if (totalClassifications > 0) begin
            overallAccuracy = (correctClassifications * 100) / totalClassifications;
            $display("\nClassification Performance:");
            $display("  Total Classifications: %0d", totalClassifications);
            $display("  Correct Classifications: %0d", correctClassifications);
            $display("  Overall Accuracy: %0d%%", overallAccuracy);
        end
        
        avgConvergenceTime = 0;
        convergenceCount = 0;
        $display("\nConvergence Analysis:");
        for (i = 0; i < 8; i = i + 1) begin
            if (convergenceTime[i] != 16'hFFFF) begin
                $display("  Workload Type %0d: %0d cycles", i, convergenceTime[i]);
                avgConvergenceTime = avgConvergenceTime + convergenceTime[i];
                convergenceCount = convergenceCount + 1;
            end else begin
                $display("  Workload Type %0d: No convergence", i);
            end
        end
        
        if (convergenceCount > 0) begin
            avgConvergenceTime = avgConvergenceTime / convergenceCount;
            $display("  Average Convergence Time: %0d cycles", avgConvergenceTime);
        end
        
        $display("\nFinal Feature Values:");
        $display("  Compute Intensity: %0d", computeToll);
        $display("  Memory Intensity: %0d", memToll);
        $display("  Control Intensity: %0d", controlToll);
        $display("  Pattern Complexity: %0d", complexPattern);
        
        $display("\nTest Summary:");
        $display("  PASS Count: %0d", totalPasses);
        $display("  ERROR Count: %0d", totalErrors);
        
        if (totalErrors == 0 && overallAccuracy >= 85) begin
            $display("  STATUS: EXCELLENT. All tests passed!");
        end else if (totalErrors <= 5 && overallAccuracy >= 75) begin
            $display("  STATUS: GOOD. Tests passed with acceptable accuracy.");
        end else begin
            $display("  STATUS: NEEDS REVIEW. Accuracy below target.");
        end
        
        $display("\n=== TEST COMPLETE ===\n");
    end
    endtask

endmodule