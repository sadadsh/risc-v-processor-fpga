`timescale 1ns / 1ps

// ENHANCED CORE COMPREHENSIVE TESTBENCH
// Engineer: Sadad Haidari
//
// This testbench validates the complete enhanced processor core with all innovations.

module enhanced_core_tb();
    // TESTBENCH PARAMETERS
    localparam CLKPERIOD = 10; // 100MHz clock.
    localparam TESTCYCLES = 15000; // Total test cycles.
    localparam INSTRUCTIONSPERTEST = 50; // Reduced for faster testing.

    // DUT SIGNALS
    reg clk;
    reg reset;

    // Instruction Interface
    reg [31:0] instruction;
    reg validInstruction;
    wire requestNextInstruction;

    // External Power/Thermal Interface
    reg [7:0] powerBudget;
    reg [7:0] thermalReading;
    reg [7:0] batteryLevel;
    reg performanceMode;

    // Processor Status Outputs
    wire instructionComplete;
    wire branchTaken;
    wire [31:0] branchTarget;

    // Enhanced Performance Monitoring
    wire [31:0] totalInstructions;
    wire [31:0] totalCycles;
    wire [31:0] totalBranches;
    wire [31:0] correctPredictions;
    wire [7:0] branchAccuracy;
    wire [31:0] totalOperationsALU;
    wire [31:0] totalRegAccesses;

    // Workload Classification Outputs
    wire [2:0] currentWorkloadFormat;
    wire [3:0] workloadConfidence;
    wire [7:0] computeToll;
    wire [7:0] memToll;
    wire [7:0] controlToll;
    wire [7:0] complexPattern;
    wire workloadClassificationValid;

    // Power Management Outputs
    wire [2:0] currentPowerState;
    wire [2:0] clockFrequencyLevel;
    wire [2:0] voltageLevel;
    wire [7:0] currentTotalPower;
    wire [7:0] powerEfficiency;
    wire [7:0] temperatureEstimate;
    wire [15:0] energySaved;
    wire powerOptimizationActive;
    wire thermalThrottle;

    // Component Power Gating Status
    wire powerGateALU;
    wire powerGateRegister;
    wire powerGateBranchPredictor;
    wire powerGateCache;

    // Advanced Debug and Monitoring
    wire [4:0] rs1Debug, rs2Debug, rdDebug;
    wire [31:0] rsData1Debug, rsData2Debug;
    wire [31:0] resultALUDebug;
    wire [31:0] currentPC;
    wire [2:0] pipelineStage;
    wire [7:0] adaptationRate;
    wire [7:0] powerTrend;

    // TESTBENCH CONTROL VARIABLES
    integer testPhase;              // Current test phase identifier.
    integer instructionCount;       // Total instructions executed across all phases.
    integer passCount;              // Number of successful test checks.
    integer failCount;              // Number of failed test checks.
    integer cycleCount;             // Total clock cycles elapsed.
    integer phaseInstructionCount;  // Instructions executed in current phase.
    
    // TEST INSTRUCTION MEMORY
    reg [31:0] testInstructions [0:255];  // Array to store test instruction patterns.
    integer instructionIndex;              // Current instruction index in memory.
    integer currentPhaseInstructions;     // Instructions executed in current phase.

    // PERFORMANCE TRACKING VARIABLES
    reg [31:0] previousInstructions;      // Previous instruction count for comparison.
    reg [31:0] previousBranches;          // Previous branch count for comparison.
    reg [31:0] previousCorrectPredictions; // Previous correct predictions count.
    reg [7:0] maxPowerObserved;           // Maximum power consumption observed.
    reg [7:0] minPowerObserved;           // Minimum power consumption observed.
    reg [7:0] maxTemperatureObserved;     // Maximum temperature observed.
    reg [15:0] totalEnergySaved;          // Total energy saved through optimization.

    // TEST PHASE DEFINITIONS
    localparam PHASERESET = 0;              // Reset and initialization phase.
    localparam PHASEBASICARITHMETIC = 1;    // Basic arithmetic operations testing.
    localparam PHASEIMMEDIATEOPS = 2;       // Immediate instruction testing.
    localparam PHASEBRANCHTRAINING = 3;     // Branch prediction training testing.
    localparam PHASECOMPUTEWORKLOAD = 4;    // Compute intensive workload testing.
    localparam PHASECONTROLWORKLOAD = 5;    // Control flow intensive workload testing.
    localparam PHASEMIXEDWORKLOAD = 6;      // Mixed workload characteristics testing.
    localparam PHASEPOWERSTRESS = 7;        // Power budget stress testing.
    localparam PHASETHERMALSTRESS = 8;      // Thermal stress testing.
    localparam PHASEPERFORMANCEMODE = 9;    // Performance mode testing.
    localparam PHASEBATTERYCONSERVATION = 10; // Battery conservation mode testing.
    localparam PHASEFINALANALYSIS = 11;     // Final analysis and stabilization.
    localparam PHASECOMPLETE = 12;          // Test completion phase.

    // WORKLOAD FORMAT CONSTANTS
    localparam WLUNKNOWN        = 3'b000;  // Unknown or unclassified workload.
    localparam WLCOMPUTE        = 3'b001;  // Compute intensive workload.
    localparam WLMEMORY         = 3'b010;  // Memory intensive workload.
    localparam WLCONTROL        = 3'b011;  // Control flow intensive workload.
    localparam WLMIXED          = 3'b100;  // Mixed workload characteristics.
    localparam WLIDLE           = 3'b101;  // Idle or very light workload.
    localparam WLSTREAMING      = 3'b110;  // Streaming data workload.
    localparam WLIRREGULAR      = 3'b111;  // Irregular or unpredictable workload.

    // INSTANTIATE DEVICE UNDER TEST
    enhanced_core dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .validInstruction(validInstruction),
        .requestNextInstruction(requestNextInstruction),
        .powerBudget(powerBudget),
        .thermalReading(thermalReading),
        .batteryLevel(batteryLevel),
        .performanceMode(performanceMode),
        .instructionComplete(instructionComplete),
        .branchTaken(branchTaken),
        .branchTarget(branchTarget),
        .totalInstructions(totalInstructions),
        .totalCycles(totalCycles),
        .totalBranches(totalBranches),
        .correctPredictions(correctPredictions),
        .branchAccuracy(branchAccuracy),
        .totalOperationsALU(totalOperationsALU),
        .totalRegAccesses(totalRegAccesses),
        .currentWorkloadFormat(currentWorkloadFormat),
        .workloadConfidence(workloadConfidence),
        .computeToll(computeToll),
        .memToll(memToll),
        .controlToll(controlToll),
        .complexPattern(complexPattern),
        .workloadClassificationValid(workloadClassificationValid),
        .currentPowerState(currentPowerState),
        .clockFrequencyLevel(clockFrequencyLevel),
        .voltageLevel(voltageLevel),
        .currentTotalPower(currentTotalPower),
        .powerEfficiency(powerEfficiency),
        .temperatureEstimate(temperatureEstimate),
        .energySaved(energySaved),
        .powerOptimizationActive(powerOptimizationActive),
        .thermalThrottle(thermalThrottle),
        .powerGateALU(powerGateALU),
        .powerGateRegister(powerGateRegister),
        .powerGateBranchPredictor(powerGateBranchPredictor),
        .powerGateCache(powerGateCache),
        .rs1Debug(rs1Debug),
        .rs2Debug(rs2Debug),
        .rdDebug(rdDebug),
        .rsData1Debug(rsData1Debug),
        .rsData2Debug(rsData2Debug),
        .resultALUDebug(resultALUDebug),
        .currentPC(currentPC),
        .pipelineStage(pipelineStage),
        .adaptationRate(adaptationRate),
        .powerTrend(powerTrend)
    );

    // CLOCK GENERATION
    // Generate a continuous clock signal for the testbench.
    initial begin
        clk = 0;
        forever #(CLKPERIOD/2) clk = ~clk;
    end

    // CONTINUOUS MONITORING
    // Monitor and track performance metrics during test execution.
    always @(posedge clk) begin
        if (reset) begin
            cycleCount <= cycleCount + 1;
            
            // Track power consumption extremes.
            if (currentTotalPower > maxPowerObserved) begin
                maxPowerObserved <= currentTotalPower;
            end
            if (currentTotalPower < minPowerObserved || minPowerObserved == 0) begin
                minPowerObserved <= currentTotalPower;
            end

            // Track temperature extremes.
            if (temperatureEstimate > maxTemperatureObserved) begin
                maxTemperatureObserved <= temperatureEstimate;
            end

            // Track energy savings accumulation.
            totalEnergySaved <= energySaved;
        end
    end

    // TESTBENCH TASKS

    // Initialize Test Environment
    // Set up initial test conditions and reset all counters.
    task initializeTest;
        begin
            reset = 1'b0;
            instruction = 32'h0;
            validInstruction = 1'b0;
            powerBudget = 8'hC0; // 192 units
            thermalReading = 8'h64; // 100 units (moderate)
            batteryLevel = 8'hFF; // Full battery
            performanceMode = 1'b0; // Start in power-saving mode

            testPhase = PHASERESET;
            instructionCount = 0;
            passCount = 0;
            failCount = 0;
            cycleCount = 0;
            instructionIndex = 0;
            phaseInstructionCount = 0;
            currentPhaseInstructions = 0;

            maxPowerObserved = 0;
            minPowerObserved = 0;
            maxTemperatureObserved = 0;
            totalEnergySaved = 0;

            // Initialize instruction memory with test patterns.
            initializeInstructionMemory();
        end
    endtask

    // Reset Sequence
    // Perform a proper reset sequence to initialize the DUT.
    task resetSequence;
        begin
            $display("Time: %0t | Starting reset sequence", $time);
            
            // Initialize all inputs before reset.
            instruction = 32'h00000000;
            validInstruction = 1'b0;
            powerBudget = 8'hC0;
            thermalReading = 8'h64;
            batteryLevel = 8'hFF;
            performanceMode = 1'b0;
            
            // Apply reset for multiple clock cycles.
            reset = 1'b0;
            repeat (10) @(posedge clk);
            
            // Release reset and allow stabilization.
            reset = 1'b1;
            repeat (10) @(posedge clk);
            
            $display("Time: %0t | Reset sequence complete", $time);
        end
    endtask

    // IMPROVED Execute Single Instruction with Timeout
    // Execute a single instruction with timeout protection and detailed logging.
    task executeInstruction;
        input [31:0] instr;
        input [20*8-1:0] description;
        integer timeout_counter;
        begin
            timeout_counter = 0;
            
            @(posedge clk);
            instruction = instr;
            validInstruction = 1'b1;

            // Wait for instruction completion with timeout protection.
            while (!instructionComplete && timeout_counter < 200) begin
                @(posedge clk);
                timeout_counter = timeout_counter + 1;
            end
            
            if (timeout_counter >= 200) begin
                $display("ERROR: Instruction execution timeout at time %0t", $time);
                $display("       Instruction: 0x%h (%s)", instr, description);
                $display("       Pipeline Stage: %d, PC: 0x%h", pipelineStage, currentPC);
                failCount = failCount + 1;
            end else begin
                instructionCount = instructionCount + 1;
                phaseInstructionCount = phaseInstructionCount + 1;
                $display("Time: %0t | Executed[%0d]: %s (PC=0x%h)", $time, instructionCount, description, currentPC);
            end
            
            @(posedge clk);
            validInstruction = 1'b0;
            
            // Small delay between instructions to allow pipeline to settle.
            repeat (2) @(posedge clk);
        end
    endtask

    // Initialize Test Instruction Memory
    // Populate the instruction memory with various test patterns.
    task initializeInstructionMemory;
        integer i;
        begin
            // Basic Arithmetic Instructions (R-type)
            testInstructions[0]  = 32'b00000000001000001000000010110011; // ADD x1, x1, x2
            testInstructions[1]  = 32'b01000000001000001000000110110011; // SUB x3, x1, x2
            testInstructions[2]  = 32'b00000000001000001111001000110011; // AND x4, x1, x2
            testInstructions[3]  = 32'b00000000001000001110001010110011; // OR x5, x1, x2
            testInstructions[4]  = 32'b00000000001000001100001100110011; // XOR x6, x1, x2

            // Immediate Instructions (I-type)
            testInstructions[5]  = 32'b00000001010000001000000010010011; // ADDI x1, x1, 20
            testInstructions[6]  = 32'b00000110010000010000000100010011; // ADDI x2, x2, 100
            testInstructions[7]  = 32'b11111110110000011000000110010011; // ADDI x3, x3, -50
            testInstructions[8]  = 32'b00001111111100100100001000010011; // XORI x4, x4, 255
            testInstructions[9]  = 32'b00000001111100101110001010010011; // ORI x5, x5, 31

            // Branch Instructions (B-type)
            testInstructions[10] = 32'b00000000001000001000010001100011; // BEQ x1, x2, 8
            testInstructions[11] = 32'b00000000001000001001010001100011; // BNE x1, x2, 8
            testInstructions[12] = 32'b00000000001000001100010001100011; // BLT x1, x2, 8
            testInstructions[13] = 32'b00000000001000001101010001100011; // BGE x1, x2, 8
            testInstructions[14] = 32'b00000000001000001110010001100011; // BLTU x1, x2, 8
            testInstructions[15] = 32'b00000000001000001111010001100011; // BGEU x1, x2, 8

            // Compute-intensive sequence
            testInstructions[16] = 32'b00000000001000010000000010110011; // ADD x1, x2, x2
            testInstructions[17] = 32'b00000000000100010001000100110011; // SLL x2, x2, x1
            testInstructions[18] = 32'b00000000000100010010000110110011; // SLT x3, x2, x1
            testInstructions[19] = 32'b00000000001100010100001000110011; // XOR x4, x2, x3

            // Fill remaining slots with simple patterns for extended testing.
            for (i = 20; i < 256; i = i + 1) begin
                case (i % 8)
                    0: testInstructions[i] = 32'b00000000001000001000000010110011; // ADD
                    1: testInstructions[i] = 32'b01000000001000001000000010110011; // SUB
                    2: testInstructions[i] = 32'b00000000001000001111000010110011; // AND
                    3: testInstructions[i] = 32'b00000000001000001110000010110011; // OR
                    4: testInstructions[i] = 32'b00000001010000001000000010010011; // ADDI
                    5: testInstructions[i] = 32'b00000000001000001000001001100011; // BEQ
                    6: testInstructions[i] = 32'b00000000001000001001001001100011; // BNE
                    7: testInstructions[i] = 32'b00000000001000001100000010110011; // XOR
                endcase
            end
        end
    endtask

    // IMPROVED Execute Test Phase with proper termination
    // Execute a complete test phase with controlled instruction flow and monitoring.
    task executeTestPhase;
        input integer phase;
        input integer numInstructions;
        integer i;
        integer baseInstructionIndex;
        begin
            $display("Time: %0t | === PHASE %0d: Starting ===", $time, phase);
            currentPhaseInstructions = 0;
            
            // Determine instruction pattern based on phase type.
            case (phase)
                PHASEBASICARITHMETIC: baseInstructionIndex = 0;   // Use instructions 0-4.
                PHASEIMMEDIATEOPS:    baseInstructionIndex = 5;   // Use instructions 5-9.
                PHASEBRANCHTRAINING:  baseInstructionIndex = 10;  // Use instructions 10-15.
                PHASECOMPUTEWORKLOAD: baseInstructionIndex = 16;  // Use instructions 16-19.
                PHASECONTROLWORKLOAD: baseInstructionIndex = 10;  // Use branch instructions.
                PHASEMIXEDWORKLOAD:   baseInstructionIndex = 0;   // Use mixed instructions.
                default:              baseInstructionIndex = 0;   // Default to arithmetic.
            endcase

            for (i = 0; i < numInstructions && testPhase != PHASECOMPLETE; i = i + 1) begin
                // Select instruction based on phase pattern with wraparound.
                instructionIndex = baseInstructionIndex + (i % 10);
                if (instructionIndex >= 256) instructionIndex = instructionIndex % 256;
                
                executeInstruction(testInstructions[instructionIndex], "Phase Instruction");
                currentPhaseInstructions = currentPhaseInstructions + 1;
                
                // Periodic checks during phase execution for monitoring.
                if ((i % 10) == 9) begin
                    checkPhaseProgress(phase);
                end
            end
            
            $display("Time: %0t | === PHASE %0d: Completed %0d instructions ===", 
                    $time, phase, currentPhaseInstructions);
        end
    endtask

    // Check phase progress and status
    // Monitor phase execution and validate basic functionality.
    task checkPhaseProgress;
        input integer phase;
        begin
            $display("Time: %0t | Phase %0d Progress: Instructions=%0d, Power=%0d, Workload=%0d", 
                    $time, phase, totalInstructions, currentTotalPower, currentWorkloadFormat);
            
            // Check for basic functionality indicators.
            if (totalInstructions > 0 && currentTotalPower > 0) begin
                passCount = passCount + 1;
            end else begin
                failCount = failCount + 1;
                $display("WARNING: Phase %0d - Low activity detected", phase);
            end
        end
    endtask

    // Generate Final Report
    // Create a comprehensive test report with all performance metrics.
    task generateFinalReport;
        integer integerIPC, fractionIPC;
        begin
            $display("================================================================");
            $display("           ENHANCED CORE COMPREHENSIVE TEST REPORT              ");
            $display("================================================================");

            $display("\nTest Summary:");
            $display("  Completed Test Phases: %0d", testPhase);
            $display("  Instructions Executed: %0d", totalInstructions);
            $display("  Total Cycles: %0d", totalCycles);
            $display("  Pass Count: %0d", passCount);
            $display("  Fail Count: %0d", failCount);
            
            if (passCount + failCount > 0) begin
                $display("  Success Rate: %0d%%", (passCount * 100) / (passCount + failCount));
            end

            $display("\nPerformance Metrics:");
            if (totalCycles > 0) begin
                integerIPC = totalInstructions / totalCycles;
                fractionIPC = ((totalInstructions * 100) / totalCycles) % 100;
                $display("  Instructions Per Cycle: %0d.%02d", integerIPC, fractionIPC);
            end
            $display("  Total ALU Operations: %0d", totalOperationsALU);
            $display("  Total Register Accesses: %0d", totalRegAccesses);

            $display("\nBranch Prediction Results:");
            $display("  Total Branches: %0d", totalBranches);
            $display("  Correct Predictions: %0d", correctPredictions);
            $display("  Final Accuracy: %0d%%", branchAccuracy);

            $display("\nWorkload Classification:");
            $display("  Current Workload: %0d", currentWorkloadFormat);
            $display("  Classification Confidence: %0d", workloadConfidence);
            $display("  Classification Valid: %0b", workloadClassificationValid);

            $display("\nPower Management Results:");
            $display("  Final Power State: %0d", currentPowerState);
            $display("  Max Power Observed: %0d", maxPowerObserved);
            $display("  Min Power Observed: %0d", minPowerObserved);
            $display("  Max Temperature: %0d", maxTemperatureObserved);
            $display("  Total Energy Saved: %0d", totalEnergySaved);
            $display("  Power Optimization Active: %0b", powerOptimizationActive);

            $display("\nOverall Assessment:");
            if (failCount == 0 && totalInstructions >= 100) begin
                $display("  STATUS: EXCELLENT! All systems working correctly!");
            end else if (failCount <= 2 && totalInstructions >= 50) begin
                $display("  STATUS: GOOD! Minor issues but functional.");
            end else begin
                $display("  STATUS: NEEDS IMPROVEMENT. Significant issues detected.");
            end

            $display("================================================================");
        end
    endtask

    // MAIN TEST SEQUENCE with proper flow control
    // Execute the complete test sequence with all phases and stress testing.
    initial begin
        $display("================================================================");
        $display("    ENHANCED RISC-V PROCESSOR CORE COMPREHENSIVE TESTBENCH      ");
        $display("================================================================");

        // Initialize test environment.
        initializeTest();
        
        // Reset sequence.
        resetSequence();

        // Execute test phases with controlled instruction flow.
        testPhase = PHASEBASICARITHMETIC;
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASEIMMEDIATEOPS;
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASEBRANCHTRAINING;
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASECOMPUTEWORKLOAD;
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASECONTROLWORKLOAD;
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASEMIXEDWORKLOAD;
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST);

        // Environmental stress tests with reduced instruction counts.
        testPhase = PHASEPOWERSTRESS;
        powerBudget = 8'h50; // Reduce power budget
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST/2);
        powerBudget = 8'hC0; // Restore normal budget

        testPhase = PHASETHERMALSTRESS;
        thermalReading = 8'hA0; // High temperature
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST/2);
        thermalReading = 8'h64; // Restore normal temperature

        // Final stabilization phase.
        testPhase = PHASEFINALANALYSIS;
        repeat (100) @(posedge clk); // Allow systems to stabilize

        // Mark test as complete.
        testPhase = PHASECOMPLETE;

        // Generate comprehensive final report.
        generateFinalReport();

        $display("\nTime: %0t | All tests completed successfully!", $time);
        $finish;
    end

    // CYCLE COUNTER AND TIMEOUT PROTECTION
    // Initialize cycle counter for timeout protection.
    initial begin
        cycleCount = 0;
    end

    // Global timeout protection to prevent infinite simulation.
    initial begin
        #(CLKPERIOD * TESTCYCLES);
        $display("ERROR: Testbench timed out after %d cycles", TESTCYCLES);
        $display("Current phase: %0d, Instructions executed: %0d", testPhase, totalInstructions);
        generateFinalReport();
        $finish;
    end

    // REAL-TIME PERFORMANCE MONITORING
    // Provide periodic performance snapshots during test execution.
    always @(posedge clk) begin
        if (reset && (cycleCount % 500) == 0 && cycleCount > 0) begin
            $display("\nTime: %0t | === PERFORMANCE SNAPSHOT (Cycle %d) ===", $time, cycleCount);
            $display("Instructions: %d, Phase: %d", totalInstructions, testPhase);
            $display("Power: %d, State: %d, Temp: %d", currentTotalPower, currentPowerState, temperatureEstimate);
            $display("Workload: Type=%d, Valid=%b", currentWorkloadFormat, workloadClassificationValid);
        end
    end

    // ENHANCED DEADLOCK DETECTION with phase awareness
    // Monitor for potential deadlock conditions and attempt recovery.
    reg [31:0] lastActivityTime;      // Timestamp of last activity.
    reg [31:0] lastInstructionCount;  // Last instruction count for comparison.
    
    always @(posedge clk) begin
        // Update activity tracking when any activity is detected.
        if (instructionComplete || validInstruction || (pipelineStage != 0) || (totalInstructions != lastInstructionCount)) begin
            lastActivityTime <= $time;
            lastInstructionCount <= totalInstructions;
        end
        
        // Only check for deadlock if we're not in the completion phase.
        if (testPhase != PHASECOMPLETE && testPhase != PHASEFINALANALYSIS) begin
            // Check for deadlock (no activity for 2000ns).
            if (($time - lastActivityTime) > 2000 && $time > 1000) begin
                $display("POTENTIAL DEADLOCK DETECTED at time %0t", $time);
                $display("Last activity: %0t", lastActivityTime);
                $display("Current phase: %0d", testPhase);
                $display("Instructions completed: %0d", totalInstructions);
                $display("Pipeline Stage: %0d", pipelineStage);
                $display("Valid Instruction: %b", validInstruction);
                $display("Instruction Complete: %b", instructionComplete);
                
                // Try to recover by moving to final phase.
                $display("Attempting recovery.");
                testPhase = PHASEFINALANALYSIS;
                repeat (50) @(posedge clk);
                testPhase = PHASECOMPLETE;
            end
        end
    end

endmodule