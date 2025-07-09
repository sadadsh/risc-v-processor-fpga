`timescale 1ns / 1ps

// WORKLOAD CLASSIFIER TESTBENCH
// Engineer: Sadad Haidari


module workload_classifier_tb;
    reg clk;
    reg reset;
    // Processor Activity Inputs
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
    // Workload Classifier Outputs
    wire [2:0] workloadFormat;
    wire [3:0] workloadConfidence;
    wire [7:0] computeToll;
    wire [7:0] memToll;
    wire [7:0] controlToll;
    wire [7:0] complexPattern;
    wire [15:0] classificationCount;
    wire [7:0] adaptationRate;
    wire classificationValid;
    // Test Control Variables
    reg [31:0] testCycle;
    reg [7:0] currentTestPhase;
    reg [15:0] phaseInstructionCount;
    reg [15:0] totalErrors;
    reg [15:0] totalPasses;
    reg [7:0] expectedWorkloadType;
    reg [7:0] expectedMinConfidence;
    // Statistics Tracking
    reg [31:0] totalClassifications;
    reg [31:0] correctClassifications;
    reg [7:0] classificationHistory [0:63];
    reg [5:0] historyIndex;
    reg [15:0] convergenceTime [0:7];
    reg [7:0] stabilityCounter;
    reg [2:0] lastClassification;
    reg [15:0] phaseClassifications;
    reg [15:0] phaseCorrect;
    // Constants
    localparam WLUNKNOWN      = 3'b000;
    localparam WLCOMPUTE      = 3'b001;
    localparam WLMEMORY       = 3'b010;
    localparam WLCONTROL      = 3'b011;
    localparam WLMIXED        = 3'b100;
    localparam WLIDLE         = 3'b101;
    localparam WLSTREAMING    = 3'b110;
    localparam WLIRREGULAR    = 3'b111;
    // Instruction Opcode Constants
    localparam OPCODERT     = 7'b0110011;
    localparam OPCODEIT     = 7'b0010011;
    localparam OPCODELOAD   = 7'b0000011;
    localparam OPCODESTORE  = 7'b0100011;
    localparam OPCODEBRANCH = 7'b1100011;
    localparam OPCODEJAL    = 7'b1101111;
    localparam OPCODEJALR   = 7'b1100111;
    // Test Phases
    localparam PHASEINIT           = 0;
    localparam PHASECOMPUTEPURE    = 1;
    localparam PHASEMEMORYPURE     = 2;
    localparam PHASECONTROLPURE    = 3;
    localparam PHASEMIXEDBALANCED  = 4;
    localparam PHASELOWACTIVITY    = 5;
    localparam PHASESTREAMING      = 6;
    localparam PHASEIRREGULAR      = 7;
    localparam PHASEFINALANALYSIS  = 8;
    
    localparam PERPHASEINSTRUCTIONS = 250; // Increased for better convergence and phase transitions
    
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
        // Initialize signals.
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
        
        // Initialize test variables.
        testCycle = 32'h0;
        currentTestPhase = PHASEINIT;
        phaseInstructionCount = 16'h0;
        totalErrors = 16'h0;
        totalPasses = 16'h0;
        expectedWorkloadType = WLUNKNOWN;
        expectedMinConfidence = 4'h4;
        
        // Initialize statistics
        totalClassifications = 32'h0;
        correctClassifications = 32'h0;
        historyIndex = 6'h0;
        stabilityCounter = 8'h0;
        lastClassification = WLUNKNOWN;
        phaseClassifications = 16'h0;
        phaseCorrect = 16'h0;
        
        // Initialize arrays.
        for (i = 0; i < 64; i = i + 1) begin
            classificationHistory[i] = WLUNKNOWN;
        end
        for (i = 0; i < 8; i = i + 1) begin
            convergenceTime[i] = 16'hFFFF;
        end
        
        $display("================================================================");
        $display("               WORKLOAD CLASSIFIER TESTBENCH                    ");
        $display("================================================================");
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

            // Phase management.
            if (phaseInstructionCount >= PERPHASEINSTRUCTIONS && currentTestPhase < PHASEFINALANALYSIS) begin
                logPhaseResults();
                currentTestPhase <= currentTestPhase + 1;
                phaseInstructionCount <= 16'h0;
                phaseClassifications <= 16'h0;
                phaseCorrect <= 16'h0;
                setPhaseExpectations();
                $display("Time: %0t | Starting Phase %0d", $time, currentTestPhase + 1);
            end

            if (currentTestPhase == PHASEFINALANALYSIS && testCycle > 200) begin
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

            // IMPROVED MONITORING: Check every 16 cycles for faster response
            if ((testCycle % 16) == 0 && testCycle > 0) begin
                monitorClassification();
            end
            updateStatistics();
        end
    end
    
    // PHASE EXECUTION TASKS
    task executeInitPhase;
    begin
        if (testCycle[4:0] == 5'h0) begin // Every 32 cycles
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
        
        // Generate purely compute-intensive pattern.
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
                fun3 = 3'b111; // AND
                opALU = 4'b0010;
            end
        endcase
        
        activeALU = 1;
        regWrite = 1;
        isBranch = 0;
        regAddress = testCycle[4:0];
        regData = {testCycle[15:0], testCycle[15:0]};
        resultALU = regData + {testCycle[7:0], testCycle[7:0], testCycle[7:0], testCycle[7:0]};
        currentPower = 8'hC0 + testCycle[3:0];
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeMemoryPurePhase;
    begin
        instructionValid = 1;
        
        // Generate purely memory-intensive pattern
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
        regData = {testCycle[15:0], ~testCycle[15:0]};
        resultALU = regData;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeControlPurePhase;
    begin
        instructionValid = 1;
        
        // Generate purely control-intensive pattern.
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
        
        // Generate more balanced mixed pattern with less chaos - more predictable
        case (testCycle[3:0])
            4'b0000, 4'b0001, 4'b0010: begin // Compute (18.75%)
                opcode = OPCODERT;
                fun3 = 3'b000;
                opALU = 4'b0000;
                activeALU = 1;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'hA0;
            end
            4'b0011, 4'b0100, 4'b0101: begin // Memory Load/Store (18.75%)
                opcode = (testCycle[0] == 1'b0) ? OPCODELOAD : OPCODESTORE;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = (testCycle[0] == 1'b0);
                isBranch = 0;
                currentPower = 8'h85;
            end
            4'b0110, 4'b0111, 4'b1000: begin // Control (18.75%)
                opcode = OPCODEBRANCH;
                fun3 = 3'b000;
                activeALU = 1;
                opALU = 4'b0001;
                regWrite = 0;
                isBranch = 1;
                branchTaken = testCycle[0];
                currentPower = 8'h90;
            end
            4'b1001, 4'b1010, 4'b1011: begin // More Compute (18.75%)
                opcode = OPCODEIT;
                fun3 = 3'b000;
                opALU = 4'b0000;
                activeALU = 1;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'hA2;
            end
            4'b1100, 4'b1101, 4'b1110: begin // More Memory (18.75%)
                opcode = (testCycle[0] == 1'b0) ? OPCODELOAD : OPCODESTORE;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = (testCycle[0] == 1'b0);
                isBranch = 0;
                currentPower = 8'h88;
            end
            4'b1111: begin // More Control (6.25%)
                opcode = OPCODEJAL;
                activeALU = 0;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h70;
            end
        endcase
        
        // More sequential register access pattern
        regAddress = (testCycle[5:1] % 8);
        regData = {24'h0, testCycle[7:0]};
        resultALU = regData;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeLowActivityPhase;
    begin
        // Generate very low activity / idle pattern, much sparser.
        if (testCycle[6:0] == 7'h0 || testCycle[6:0] == 7'h40) begin // Every 128 cycles, 2 instructions per 256
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
            currentPower = 8'h15;
            phaseInstructionCount = phaseInstructionCount + 1;
            updateCounters();
        end else begin
            instructionValid = 0;
            activeALU = 0;
            regWrite = 0;
            isBranch = 0;
            currentPower = 8'h08;
        end
    end
    endtask
    
    task executeStreamingPhase;
    begin
        instructionValid = 1;
        
        // Generate streaming pattern with sequential data access.
        case (testCycle[2:0])
            3'b000, 3'b011, 3'b110: begin // Load
                opcode = OPCODELOAD;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 1;
                currentPower = 8'h70;
            end
            3'b001, 3'b100, 3'b111: begin // Simple compute.
                opcode = OPCODEIT;
                fun3 = 3'b000;
                opALU = 4'b0000;
                activeALU = 1;
                regWrite = 1;
                currentPower = 8'h75;
            end
            3'b010, 3'b101: begin // Store.
                opcode = OPCODESTORE;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 0;
                currentPower = 8'h72;
            end
        endcase
        
        // Sequential access pattern
        regAddress = (testCycle[6:2] % 8); // Sequential register access
        regData = {24'h0, testCycle[7:0]}; // Sequential data - small increments
        resultALU = regData + 1;
        isBranch = 0;
        
        phaseInstructionCount = phaseInstructionCount + 1;
        updateCounters();
    end
    endtask
    
    task executeIrregularPhase;
    begin
        instructionValid = 1;
        
        // Generate extremely irregular pattern with maximum chaos.
        pseudoRandom = testCycle[7:0] ^ (testCycle[15:8] << 1) ^ (testCycle[23:16] >> 1) ^ (testCycle[31:24] << 2);
        
        // Use a different seed every few cycles to maximize chaos.
        if (testCycle[1:0] == 2'b00) begin
            pseudoRandom = pseudoRandom ^ 8'hAA;
        end else if (testCycle[1:0] == 2'b01) begin
            pseudoRandom = pseudoRandom ^ 8'h55;
        end else if (testCycle[1:0] == 2'b10) begin
            pseudoRandom = pseudoRandom ^ 8'hFF;
        end else begin
            pseudoRandom = pseudoRandom ^ 8'h00;
        end
        
        // Extremely chaotic pattern - maximally random every cycle.
        case (pseudoRandom[2:0]) // Change every cycle with no pattern.
            3'b000: begin
                opcode = OPCODERT;
                fun3 = (testCycle[0]) ? 3'b111 : 3'b000;
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
                fun3 = pseudoRandom[5:4];
                activeALU = 1;
                opALU = 4'b0001;
                regWrite = 0;
                isBranch = 1;
                branchTaken = pseudoRandom[0];
                currentPower = 8'h70 + pseudoRandom[3:0];
            end
            3'b011: begin
                opcode = OPCODESTORE;
                fun3 = 3'b010;
                activeALU = 0;
                regWrite = 0;
                isBranch = 0;
                currentPower = 8'h48 + pseudoRandom[3:0];
            end
            3'b100: begin
                opcode = OPCODEIT;
                fun3 = (testCycle[1]) ? 3'b001 : 3'b100;
                opALU = pseudoRandom[6:3];
                activeALU = 1;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h55 + pseudoRandom[3:0];
            end
            3'b101: begin
                opcode = OPCODEJAL;
                activeALU = 0;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h65 + pseudoRandom[3:0];
            end
            3'b110: begin
                opcode = OPCODEJALR;
                activeALU = 0;
                regWrite = 1;
                isBranch = 0;
                currentPower = 8'h68 + pseudoRandom[3:0];
            end
            3'b111: begin
                // Completely random opcode for maximum chaos
                opcode = {1'b0, pseudoRandom[6:1], 1'b1};
                fun3 = pseudoRandom[2:0];
                opALU = pseudoRandom[7:4];
                activeALU = pseudoRandom[0];
                regWrite = pseudoRandom[1];
                isBranch = pseudoRandom[2];
                branchTaken = pseudoRandom[3];
                currentPower = 8'h40 + pseudoRandom[3:0];
            end
        endcase
        
        // Maximally irregular access pattern, force chaos.
        regAddress = pseudoRandom[4:0] ^ testCycle[4:0] ^ (testCycle[9:5]);
        regData = {(pseudoRandom ^ 8'hFF), (~pseudoRandom), (pseudoRandom ^ testCycle[7:0]), (pseudoRandom << 1)};
        resultALU = regData ^ {pseudoRandom[1:0], pseudoRandom[7:2], pseudoRandom, pseudoRandom[6:0], pseudoRandom[7]};
        
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
    
    // IMPROVED MONITORING TASKS
    task monitorClassification;
    begin
        if (classificationValid && workloadConfidence >= 4) begin
            totalClassifications = totalClassifications + 1;
            phaseClassifications = phaseClassifications + 1;

            classificationHistory[historyIndex] = workloadFormat;
            historyIndex = (historyIndex + 1) % 64;

            if (workloadFormat == expectedWorkloadType) begin
                correctClassifications = correctClassifications + 1;
                phaseCorrect = phaseCorrect + 1;
                totalPasses = totalPasses + 1;

                if (workloadFormat == lastClassification) begin
                    stabilityCounter = stabilityCounter + 1;

                    // Improved convergence detection
                    if (convergenceTime[workloadFormat] == 16'hFFFF && stabilityCounter >= 5 && workloadConfidence >= 8) begin
                        convergenceTime[workloadFormat] = testCycle[15:0];
                        $display("Time: %0t | Convergence detected for workload format %0d at cycle %0d", 
                                $time, workloadFormat, testCycle);
                    end
                end else begin
                    stabilityCounter = 8'h0;
                end
                lastClassification = workloadFormat;

            end else begin
                totalErrors = totalErrors + 1;
                stabilityCounter = 8'h0;

                // Only print errors for significant misclassifications
                if (workloadConfidence >= 8) begin
                    $display("Time: %0t | ERROR: Phase %0d - Expected: %0d, Got: %0d, Confidence: %0d", 
                            $time, currentTestPhase, expectedWorkloadType, workloadFormat, workloadConfidence);
                end
            end

            // Print summary every 64 instructions (2 cycles of 32)
            if ((phaseInstructionCount % 64) == 0) begin
                $display("Time: %0t | Phase %0d: Format=%0d, Confidence=%0d, Compute=%0d, Memory=%0d, Control=%0d, Complex=%0d", 
                        $time, currentTestPhase, workloadFormat, workloadConfidence, 
                        computeToll, memToll, controlToll, complexPattern);
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
            PHASEINIT:           begin expectedWorkloadType = WLIDLE; expectedMinConfidence = 6; end
            PHASECOMPUTEPURE:    begin expectedWorkloadType = WLCOMPUTE; expectedMinConfidence = 6; end
            PHASEMEMORYPURE:     begin expectedWorkloadType = WLMEMORY; expectedMinConfidence = 6; end
            PHASECONTROLPURE:    begin expectedWorkloadType = WLCONTROL; expectedMinConfidence = 6; end
            PHASEMIXEDBALANCED:  begin expectedWorkloadType = WLMIXED; expectedMinConfidence = 4; end
            PHASELOWACTIVITY:    begin expectedWorkloadType = WLIDLE; expectedMinConfidence = 6; end
            PHASESTREAMING:      begin expectedWorkloadType = WLSTREAMING; expectedMinConfidence = 4; end
            PHASEIRREGULAR:      begin expectedWorkloadType = WLIRREGULAR; expectedMinConfidence = 4; end
            default:             begin expectedWorkloadType = WLUNKNOWN; expectedMinConfidence = 3; end
        endcase
    end
    endtask
    
    task logPhaseResults;
    begin
        if (phaseClassifications > 0) begin
            phaseAccuracy = (phaseCorrect * 100) / phaseClassifications;
        end else begin
            phaseAccuracy = 0;
        end
        
        $display("Time: %0t | Phase %0d Results:", $time, currentTestPhase);
        $display("         Instructions: %0d, Classifications: %0d, Correct: %0d, Accuracy: %0d%%", 
                phaseInstructionCount, phaseClassifications, phaseCorrect, phaseAccuracy);
        $display("         Final Intensities - Compute: %0d, Memory: %0d, Control: %0d", 
                computeToll, memToll, controlToll);
        $display("         Final Classification: Type=%0d, Confidence=%0d", 
                workloadFormat, workloadConfidence);
        $display("");
    end
    endtask
    
    task generateFinalReport;
    begin
        $display("================================================================");
        $display("           IMPROVED WORKLOAD CLASSIFIER FINAL REPORT            ");
        $display("================================================================");

        $display("Test Duration: %0d cycles.", testCycle);
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
                $display("  Workload Format %0d: %0d cycles.", i, convergenceTime[i]);
                avgConvergenceTime = avgConvergenceTime + convergenceTime[i];
                convergenceCount = convergenceCount + 1;
            end else begin
                $display("  Workload Format %0d: No convergence.", i);
            end
        end
        
        if (convergenceCount > 0) begin
            avgConvergenceTime = avgConvergenceTime / convergenceCount;
            $display("  Average Convergence Time: %0d cycles.", avgConvergenceTime);
        end
        
        $display("\nFinal Feature Values:");
        $display("  Compute Intensity: %0d", computeToll);
        $display("  Memory Intensity: %0d", memToll);
        $display("  Control Intensity: %0d", controlToll);
        $display("  Pattern Complexity: %0d", complexPattern);
        
        $display("\nTest Summary:");
        $display("  PASS Count: %0d", totalPasses);
        $display("  ERROR Count: %0d", totalErrors);
        
        if (totalErrors <= 2 && overallAccuracy >= 85) begin
            $display("  STATUS: EXCELLENT. Very accurate classification system.");
        end else if (totalErrors <= 5 && overallAccuracy >= 80) begin
            $display("  STATUS: GOOD. Tests passed with good accuracy.");
        end else if (overallAccuracy >= 70) begin
            $display("  STATUS: ACCEPTABLE. Some issues but functional.");
        end else begin
            $display("  STATUS: NEEDS REVIEW. Far below target.");
        end
        
        $display("================================================================");
        $display("");
    end
    endtask

endmodule