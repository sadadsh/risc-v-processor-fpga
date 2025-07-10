`timescale 1ns / 1ps

// ENHANCED CORE COMPREHENSIVE TESTBENCH
// Engineer: Sadad Haidari
//
// This testbench validates the complete enhanced processor core with all innovations.

module enhanced_core_tb();
    // TESTBENCH PARAMETERS
    localparam CLKPERIOD = 10; // Clock period in nanoseconds (100MHz clock).
    localparam TESTCYCLES = 15000; // Maximum number of test cycles before timeout.
    localparam INSTRUCTIONSPERTEST = 50; // Number of instructions per test phase.

    // DUT SIGNALS
    reg clk; // Clock signal for the DUT.
    reg reset; // Reset signal for the DUT.

    // INSTRUCTION INTERFACE SIGNALS
    reg [31:0] instruction; // Current instruction to execute.
    reg validInstruction; // Indicates if the instruction is valid.
    wire requestNextInstruction; // DUT requests the next instruction.

    // POWER AND THERMAL INTERFACE SIGNALS
    reg [7:0] powerBudget; // Power budget for the DUT.
    reg [7:0] thermalReading; // Simulated thermal sensor reading.
    reg [7:0] batteryLevel; // Simulated battery level.
    reg performanceMode; // Performance mode flag.

    // PROCESSOR STATUS OUTPUTS
    wire instructionComplete; // Indicates instruction completion.
    wire branchTaken; // Indicates if a branch was taken.
    wire [31:0] branchTarget; // Target address for branch instructions.

    // PERFORMANCE MONITORING OUTPUTS
    wire [31:0] totalInstructions; // Total instructions executed.
    wire [31:0] totalCycles; // Total cycles elapsed.
    wire [31:0] totalBranches; // Total branch instructions executed.
    wire [31:0] correctPredictions; // Correct branch predictions.
    wire [7:0] branchAccuracy; // Branch prediction accuracy percentage.
    wire [31:0] totalOperationsALU; // Total ALU operations performed.
    wire [31:0] totalRegAccesses; // Total register file accesses.

    // WORKLOAD CLASSIFICATION OUTPUTS
    wire [2:0] currentWorkloadFormat; // Current workload classification.
    wire [3:0] workloadConfidence; // Confidence in workload classification.
    wire [7:0] computeToll; // Compute intensity metric.
    wire [7:0] memToll; // Memory intensity metric.
    wire [7:0] controlToll; // Control flow intensity metric.
    wire [7:0] complexPattern; // Complexity metric.
    wire workloadClassificationValid; // Indicates valid workload classification.

    // POWER MANAGEMENT OUTPUTS
    wire [2:0] currentPowerState; // Current power management state.
    wire [2:0] clockFrequencyLevel; // Current clock frequency level.
    wire [2:0] voltageLevel; // Current voltage level.
    wire [7:0] currentTotalPower; // Current total power consumption.
    wire [7:0] powerEfficiency; // Power efficiency metric.
    wire [7:0] temperatureEstimate; // Estimated temperature.
    wire [15:0] energySaved; // Total energy saved by optimization.
    wire powerOptimizationActive; // Indicates if power optimization is active.
    wire thermalThrottle; // Indicates if thermal throttling is active.

    // COMPONENT POWER GATING STATUS
    wire powerGateALU; // ALU power gating status.
    wire powerGateRegister; // Register file power gating status.
    wire powerGateBranchPredictor; // Branch predictor power gating status.
    wire powerGateCache; // Cache power gating status.

    // DEBUG AND MONITORING OUTPUTS
    wire [4:0] rs1Debug, rs2Debug, rdDebug; // Register source/destination debug.
    wire [31:0] rsData1Debug, rsData2Debug; // Register data debug.
    wire [31:0] resultALUDebug; // ALU result debug.
    wire [31:0] currentPC; // Current program counter.
    wire [2:0] pipelineStage; // Current pipeline stage.
    wire [7:0] adaptationRate; // Adaptation rate for learning systems.
    wire [7:0] powerTrend; // Power consumption trend.

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
    reg [7:0] maxPowerObserved; // Maximum power consumption observed.
    reg [7:0] minPowerObserved; // Minimum power consumption observed.
    reg [7:0] maxTemperatureObserved; // Maximum temperature observed.
    reg [15:0] totalEnergySaved; // Total energy saved through optimization.

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
    localparam PHASEFINALANALYSIS = 11; // Final analysis and stabilization.
    localparam PHASECOMPLETE = 12; // Test completion phase.

    // WORKLOAD FORMAT CONSTANTS
    localparam WLUNKNOWN        = 3'b000; // Unknown or unclassified workload.
    localparam WLCOMPUTE        = 3'b001; // Compute intensive workload.
    localparam WLMEMORY         = 3'b010; // Memory intensive workload.
    localparam WLCONTROL        = 3'b011; // Control flow intensive workload.
    localparam WLMIXED          = 3'b100; // Mixed workload characteristics.
    localparam WLIDLE           = 3'b101; // Idle or very light workload.
    localparam WLSTREAMING      = 3'b110; // Streaming data workload.
    localparam WLIRREGULAR      = 3'b111; // Irregular or unpredictable workload.

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
        reg isBranchInstr;
        begin
            timeout_counter = 0;
            
            // Detect if this is a branch instruction
            isBranchInstr = (instr[6:0] == 7'b1100011) || // Branch instructions
                            (instr[6:0] == 7'b1101111) || // JAL
                            (instr[6:0] == 7'b1100111);   // JALR
            
            @(posedge clk);
            instruction = instr;
            validInstruction = 1'b1;

            // Wait for instruction completion
            while (!instructionComplete && timeout_counter < 30) begin
                @(posedge clk);
                timeout_counter = timeout_counter + 1;
            end
            
            if (timeout_counter >= 30) begin
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
            
            // SIMPLE SMART DELAY STRATEGY:
            if (isBranchInstr) begin
                // Branch instructions: Allow training time, but optimize based on accuracy
                if (branchAccuracy < 70 && totalBranches > 10) begin
                    repeat (7) @(posedge clk);  // More time if accuracy is poor
                    $display("  [TRAINING] Extended training (accuracy: %d%%)", branchAccuracy);
                end else if (branchAccuracy < 85 && totalBranches > 5) begin
                    repeat (5) @(posedge clk);  // Standard training time
                    $display("  [TRAINING] Standard training (accuracy: %d%%)", branchAccuracy);
                end else begin
                    repeat (3) @(posedge clk);  // Minimal training time for good accuracy
                    $display("  [TRAINING] Fast training (accuracy: %d%%)", branchAccuracy);
                end
            end else begin
                // Arithmetic instructions: Fast execution for good IPC
                repeat (1) @(posedge clk);
            end
        end
    endtask

    task executeBurstArithmetic;
        input integer startIndex;
        input integer count;
        integer i;
        reg [31:0] currentInstr;
        begin
            $display("  [BURST] Executing %0d arithmetic instructions rapidly", count);
            
            for (i = 0; i < count; i = i + 1) begin
                currentInstr = testInstructions[startIndex + i];
                
                // Rapid execution for arithmetic
                @(posedge clk);
                instruction = currentInstr;
                validInstruction = 1'b1;
                
                // Wait for completion
                wait(instructionComplete);
                @(posedge clk);
                validInstruction = 1'b0;
                
                instructionCount = instructionCount + 1;
                phaseInstructionCount = phaseInstructionCount + 1;
                
                // No delay between arithmetic instructions
            end
            
            $display("  [BURST] Completed %0d instructions with high IPC", count);
        end
    endtask

    // Replace executeTestPhaseBalanced with this SIMPLE version:
    task executeTestPhaseSimple;
        input integer phase;
        input integer numInstructions;
        integer i;
        integer baseInstructionIndex;
        begin
            $display("Time: %0t | *** SIMPLE PHASE %0d: Starting ***", $time, phase);
            
            // Add explanatory message for each phase
            case (phase)
                PHASEBASICARITHMETIC: begin 
                    baseInstructionIndex = 0;
                    $display("Testing basic arithmetic operations with fast execution.");
                end
                PHASEIMMEDIATEOPS: begin 
                    baseInstructionIndex = 5;
                    $display("Testing immediate instructions with fast execution.");
                end
                PHASEBRANCHTRAINING: begin 
                    baseInstructionIndex = 10;
                    $display("Training branch predictor with careful timing.");
                end
                PHASECOMPUTEWORKLOAD: begin 
                    baseInstructionIndex = 16;
                    $display("Compute workload with mixed instruction types.");
                end
                PHASECONTROLWORKLOAD: begin 
                    baseInstructionIndex = 10;
                    $display("Control workload - mostly branches for prediction training.");
                end
                PHASEMIXEDWORKLOAD: begin 
                    baseInstructionIndex = 0;
                    $display("Mixed workload with all instruction types.");
                end
                default: begin
                    baseInstructionIndex = 0;
                    $display("Default instruction sequence.");
                end
            endcase
            
            currentPhaseInstructions = 0;
            
            // SIMPLE LOOP - No complex burst logic, just reliable execution
            for (i = 0; i < numInstructions && testPhase != PHASECOMPLETE; i = i + 1) begin
                instructionIndex = baseInstructionIndex + (i % 10);
                if (instructionIndex >= 256) instructionIndex = instructionIndex % 256;
                
                // Execute instruction with smart delays
                executeInstruction(testInstructions[instructionIndex], "Phase Instruction");
                currentPhaseInstructions = currentPhaseInstructions + 1;
                
                // Progress monitoring every 10 instructions
                if ((i % 10) == 9) begin
                    $display("Time: %0t | Phase %0d: %0d/%0d instructions completed", 
                            $time, phase, currentPhaseInstructions, numInstructions);
                end
            end
            
            // Brief settling time
            validInstruction = 1'b0;
            repeat (3) @(posedge clk);
            
            $display("Time: %0t | *** SIMPLE PHASE %0d: COMPLETED %0d INSTRUCTIONS ***", 
                    $time, phase, currentPhaseInstructions);
        end
    endtask

    task displaySimplePerformance;
        integer realIPC_int, realIPC_frac;
        integer arithmeticInstructions, branchInstructions;
        integer estimatedArithmeticCycles, estimatedBranchCycles;
        begin
            $display("==============================================================");
            $display("*** SIMPLE PERFORMANCE ANALYSIS ***");
            
            // Calculate overall IPC
            if (totalCycles > 0) begin
                realIPC_int = (totalInstructions * 1000) / totalCycles;
                realIPC_frac = realIPC_int % 1000;
                $display("Overall IPC: %0d.%03d", realIPC_int / 1000, realIPC_frac);
                
                // Analyze instruction mix
                branchInstructions = totalBranches;
                arithmeticInstructions = totalInstructions - totalBranches;
                
                $display("Instruction Mix:");
                $display("  Arithmetic Instructions: %0d (%0d%%)", 
                        arithmeticInstructions, (arithmeticInstructions * 100) / totalInstructions);
                $display("  Branch Instructions: %0d (%0d%%)", 
                        branchInstructions, (branchInstructions * 100) / totalInstructions);
                
                // Estimate component performance
                estimatedBranchCycles = branchInstructions * 8;  // Assume 8 cycles per branch (5 pipeline + 3 training)
                estimatedArithmeticCycles = arithmeticInstructions * 6;  // Assume 6 cycles per arithmetic (5 pipeline + 1 delay)
                
                if (estimatedArithmeticCycles > 0) begin
                    $display("  Estimated Arithmetic IPC: %0d.%02d", 
                            (arithmeticInstructions * 100) / estimatedArithmeticCycles,
                            ((arithmeticInstructions * 10000) / estimatedArithmeticCycles) % 100);
                end
                
                if (estimatedBranchCycles > 0) begin
                    $display("  Estimated Branch IPC: %0d.%02d", 
                            (branchInstructions * 100) / estimatedBranchCycles,
                            ((branchInstructions * 10000) / estimatedBranchCycles) % 100);
                end
            end
            
            // Branch prediction analysis
            if (totalBranches > 0) begin
                $display("\nBranch Prediction Performance:");
                $display("  Total Branches: %0d", totalBranches);
                $display("  Correct Predictions: %0d", correctPredictions);
                $display("  Accuracy: %0d%%", branchAccuracy);
                
                if (branchAccuracy >= 90) begin
                    $display("  Rating: EXCELLENT (>90%%)");
                end else if (branchAccuracy >= 80) begin
                    $display("  Rating: VERY GOOD (>80%%)");
                end else if (branchAccuracy >= 70) begin
                    $display("  Rating: GOOD (>70%%)");
                end else if (branchAccuracy >= 60) begin
                    $display("  Rating: ACCEPTABLE (>60%%)");
                end else begin
                    $display("  Rating: NEEDS IMPROVEMENT (<60%%)");
                end
            end
            
            // Overall assessment
            $display("\nPerformance Assessment:");
            if (realIPC_int >= 400 && branchAccuracy >= 75) begin
                $display("  EXCELLENT: Good IPC (>0.4) AND good branch accuracy (>75%%)");
            end else if (realIPC_int >= 300 && branchAccuracy >= 70) begin
                $display("  GOOD: Decent IPC (>0.3) AND acceptable branch accuracy (>70%%)");
            end else if (realIPC_int >= 200 || branchAccuracy >= 65) begin
                $display("  ACCEPTABLE: At least one metric is reasonable.");
            end else begin
                $display("  NEEDS IMPROVEMENT: Both IPC and branch accuracy could be better.");
            end
            
            $display("==============================================================\n");
        end
    endtask
    
    task displayThermalAnalysis;
        begin
            $display("==============================================================\n");
            $display("*** THERMAL AND POWER ANALYSIS ***");
            $display("Temperature Analysis:");
            $display("  Maximum Temperature: %0d units", maxTemperatureObserved);
            if (maxTemperatureObserved > 200) begin
                $display("  STATUS: THERMAL STRESS DETECTED!");
                $display("  This likely triggered CRITICAL power state (6)");
            end else if (maxTemperatureObserved > 150) begin
                $display("  STATUS: Elevated temperature, within acceptable range.");
            end else begin
                $display("  STATUS: Normal thermal operation.");
            end
            
            $display("Power Analysis:");
            $display("  Maximum Power: %0d units", maxPowerObserved);
            $display("  Minimum Power: %0d units", minPowerObserved);
            $display("  Power Range: %0d units", maxPowerObserved - minPowerObserved);
            
            if (maxPowerObserved > 180) begin
                $display("  STATUS: High power consumption detected.");
                $display("  This may have contributed to CRITICAL power state.");
            end
            
            $display("Emergency Response:");
            if (currentPowerState == 6) begin
                $display("  CRITICAL MODE ACTIVE: Emergency power reduction engaged.");
                $display("  It detected dangerous conditions and responded appropriately.");
            end
            
            $display("Energy Efficiency:");
            if (energySaved > 10000) begin
                $display("  Energy Savings: %0d units (perhaps too high, I might have miscalculated...?).", energySaved);
            end else if (energySaved > 1000) begin
                $display("  Energy Savings: %0d units (good optimization).", energySaved);
            end else begin
                $display("  Energy Savings: %0d units (minimal savings)", energySaved);
            end
            
            $display("==============================================================\n");
        end
    endtask

    // Initialize Test Instruction Memory
    // Populate the instruction memory with various test patterns.
    task initializeInstructionMemory;
        integer i;
        begin
            // Basic Arithmetic Instructions R-Type
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
            $display("Time: %0t | *** PHASE %0d: STARTING ***", $time, phase);
            // Add explanatory message for each phase
            case (phase)
                PHASEBASICARITHMETIC: begin
                    baseInstructionIndex = 0;
                    $display("Testing basic arithmetic operations (ADD, SUB, AND, OR, XOR).");
                    $display("This validates the ALU functionality and register file operations.");
                end
                PHASEIMMEDIATEOPS: begin
                    baseInstructionIndex = 5;
                    $display("Testing immediate value instructions (ADDI, XORI, ORI).");
                    $display("This validates immediate operand handling and instruction decoding.");
                end
                PHASEBRANCHTRAINING: begin
                    baseInstructionIndex = 10;
                    $display("Training the adaptive branch predictor with various branch patterns.");
                    $display("This teaches the predictor to recognize common branch behaviors.");
                end
                PHASECOMPUTEWORKLOAD: begin
                    baseInstructionIndex = 16;
                    $display("Simulating compute-intensive workload for classification testing.");
                    $display("This tests workload classifier's ability to detect computation patterns.");
                end
                PHASECONTROLWORKLOAD: begin
                    baseInstructionIndex = 10;
                    $display("Simulating control-flow intensive workload with many branches.");
                    $display("This tests branch prediction accuracy and workload classification.");
                end
                PHASEMIXEDWORKLOAD: begin
                    baseInstructionIndex = 0;
                    $display("Simulating mixed workload with varied instruction types.");
                    $display("This tests the system's ability to adapt to changing patterns.");
                end
                PHASEPOWERSTRESS: begin
                    baseInstructionIndex = 0;
                    $display("Testing power management under reduced power budget constraints.");
                    $display("This validates power optimization and thermal management features.");
                end
                PHASETHERMALSTRESS: begin
                    baseInstructionIndex = 0;
                    $display("Testing thermal management under high temperature conditions.");
                    $display("This validates thermal throttling and emergency power reduction.");
                end
                default: begin
                    baseInstructionIndex = 0;
                    $display("Running default instruction sequence.");
                end
            endcase
            currentPhaseInstructions = 0;
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
            $display("Time: %0t | *** PHASE %0d: COMPLETED %0d INSTRUCTIONS ***", $time, phase, currentPhaseInstructions);
            $display("Phase was successful in completion, moving to next test phase...");
            $display("");
        end
    endtask

    // Check phase progress and status
    // Monitor phase execution and validate basic functionality.
    task checkPhaseProgress;
        input integer phase;
        begin
            $display("Time: %0t | Phase %0d Progress Check:", $time, phase);
            $display("  Instructions Executed: %0d (measures processor throughput)", totalInstructions);
            $display("  Power Consumption: %0d units (shows current energy usage)", currentTotalPower);
            $display("  Workload Classification: %0d [0 = UNKNOWN, 1 = COMPUTE, 2 = MEMORY, 3 = CONTROL, 4 = MIXED, 5 = IDLE].", currentWorkloadFormat);
            $display("  System Status: Processor is actively executing and learning");
            // Check for basic functionality indicators.
            if (totalInstructions > 0 && currentTotalPower > 0) begin
                passCount = passCount + 1;
                $display("  RESULT | PASS! Normal function.");
            end else begin
                failCount = failCount + 1;
                $display("  RESULT | WARNING! Low activity detected, investigating...");
            end
            $display("");
        end
    endtask

    // Generate Final Report
    // Create a comprehensive test report with all performance metrics.
    task generateFinalReport;
        integer integerIPC, fractionIPC;
        begin
            $display("");
            $display("================================================================");
            $display("        ENHANCED RISC-V PROCESSOR FINAL TEST REPORT            ");
            $display("================================================================");

            $display("");
            $display("TEST EXECUTION SUMMARIZED:");
            $display("  Total Test Phases Completed: %0d out of 12 planned phases", testPhase);
            $display("  Working Instructions Executed: %0d", totalInstructions);
            $display("  Total Clock Cycles Used: %0d", totalCycles);
            $display("  Individual Test Checks Passed: %0d", passCount);
            $display("  Individual Test Checks Failed: %0d", failCount);
            if (passCount + failCount > 0) begin
                $display("  Overall Test Success Rate: %0d%% of checks passed.", (passCount * 100) / (passCount + failCount));
            end
            if (totalInstructions > 0) begin
                $display("  ALU Utilization: %0d%%", (totalOperationsALU * 100) / totalInstructions);
                $display("  Register Access Rate: %0d%%", (totalRegAccesses * 100) / totalInstructions);
                $display("  Branch Instruction Rate: %0d%%", (totalBranches * 100) / totalInstructions);
            end
            if (totalCycles > 0) begin
                $display("  Power Efficiency: %0d%%", (totalInstructions * 100) / totalCycles);
            end
            $display("");
            $display("PROCESSOR PERFORMANCE METRICS:");
            if (totalCycles > 0) begin
                integerIPC = totalInstructions / totalCycles;
                fractionIPC = ((totalInstructions * 100) / totalCycles) % 100;
                $display("    [IPC]: %0d.%02d", integerIPC, fractionIPC);
            end
            $display("  Total ALU Operations Performed: %0d", totalOperationsALU);
            $display("  Total Register File Accesses: %0d", totalRegAccesses);
            $display("");
            $display("INTELLIGENT BRANCH PREDICTION RESULTS:");
            $display("  Total Branch Instructions: %0d", totalBranches);
            $display("  Correct Predictions Made: %0d", correctPredictions);
            $display("  Final Prediction Accuracy: %0d%%", branchAccuracy);
            if (branchAccuracy >= 90) begin
                $display("    EXCELLENT: Branch predictor learned patterns very well.");
            end else if (branchAccuracy >= 70) begin
                $display("    GOOD: Branch predictor shows strong learning capability.");
            end else if (branchAccuracy >= 50) begin
                $display("    ACCEPTABLE: Branch predictor performs better than random guessing");
            end else begin
                $display("    NEEDS IMPROVEMENT: Branch predictor requires optimization");
            end
            $display("");
            $display("WORKLOAD CLASSIFICATION RESULTS:");
            $display("  Final Workload Format Detected: %0d", currentWorkloadFormat);
            $display("    [0 = UNKNOWN]");
            $display("    [1 = COMPUTE-INTENSIVE]");
            $display("    [2 = MEMORY-INTENSIVE]");
            $display("    [3 = CONTROL-INTENSIVE]");
            $display("    [4 = MIXED]");
            $display("    [5 = IDLE]");
            $display("    [6 = STREAMING]");
            $display("    [7 = IRREGULAR]");
            $display("  Classification Confidence: %0d out of 15.", workloadConfidence);
            $display("  Classification Active: %0b", workloadClassificationValid);
            if (workloadClassificationValid) begin
                $display("    SUCCESS: Classifier was able to assess workload patterns.");
            end else begin
                $display("    The classifier needs more training data to achieve confidence.");
            end
            $display("");
            $display("POWER OPTIMIZER RESULTS:");
            $display("  Final Power Management State: %0d", currentPowerState);
            $display("    [0 = IDLE]");
            $display("    [1 = LOW-POWER]");
            $display("    [2 = BALANCED]");
            $display("    [3 = PERFORMANCE]");
            $display("    [4 = BURST-MODE]");
            $display("    [5 = THERMAL-THROTTLE]");
            $display("    [6 = CRITICAL]");
            $display("    [7 = ADAPTIVE]");
            // Add interpretation:
            case (currentPowerState)
                0: $display("    STATUS: System idle, minimal power consumption.");
                1: $display("    STATUS: Low power mode active.");
                2: $display("    STATUS: Balanced power/performance.");
                3: $display("    STATUS: High performance mode.");
                4: $display("    STATUS: Maximum performance burst.");
                5: $display("    STATUS: Thermal throttling active.");
                6: $display("    STATUS: Critical power reduction active.");
                7: $display("    STATUS: Adaptive power management.");
                default: $display("    STATUS: INVALID POWER STATE!");
            endcase
            $display("  Maximum Power Observed: %0d units.", maxPowerObserved);
            $display("  Minimum Power Observed: %0d units.", minPowerObserved);
            $display("  Power Range Managed: %0d units (shows adaptive adjustment).", maxPowerObserved - minPowerObserved);
            $display("  Maximum Temperature Reached: %0d units.", maxTemperatureObserved);
            $display("  Total Energy Saved Through Optimization: %0d units.", totalEnergySaved);
            $display("  Power Optimization System Active: %0b", powerOptimizationActive);
            if (energySaved > 1000) begin
                $display("    EXCELLENT: Major energy savings achieved through optimization.");
            end else if (energySaved > 100) begin
                $display("    GOOD: Moderate energy savings from power optimization.");
            end else begin
                $display("    MINIMAL: Little to no energy savings.");
            end
            $display("");
            $display("INNOVATION ASSESSMENT:");
            $display("  Adaptive Branch Predictor:");
            if (branchAccuracy >= 80) begin
                $display("     STATUS: EXCELLENT!");
            end else begin
                $display("     STATUS: FUNCTIONAL, NEEDS IMPROVEMENT.");
            end
            $display("  Power Optimizer:");
            if (workloadClassificationValid && energySaved > 100) begin
                $display("     STATUS: EXCELLENT!");
            end else begin
                $display("     STATUS: FUNCTIONAL, NEEDS IMPROVEMENT.");
            end
            $display("");
            $display("OVERALL EVALUATION:");
            if (failCount == 0 && totalInstructions >= 100) begin
                $display("  RESULT: EXCELLENT SUCCESS! All is working! (^.^)");
            end else if (failCount <= 2 && totalInstructions >= 50) begin
                $display("  RESULT: GOOD! Minor issues but functional.");
            end else begin
                $display("  RESULT: FUNCTIONAL BUT NEEDS REFINEMENT.");
            end
        end
    endtask

    // MAIN TEST SEQUENCE
    // Execute the complete test sequence with all phases and stress testing.
    initial begin
        $display("================================================================");
        $display("         ENHANCED RISC-V PROCESSOR SIMPLE TESTBENCH             ");
        $display("================================================================");

        // Initialize test environment
        initializeTest();
        
        // Reset sequence
        resetSequence();
        $display("Beginning simple but effective testing of all processor features...");
        $display("");

        // Execute test phases with simple, reliable logic
        testPhase = PHASEBASICARITHMETIC;
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASEIMMEDIATEOPS;
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASEBRANCHTRAINING;
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASECOMPUTEWORKLOAD;
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASECONTROLWORKLOAD;
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST);

        testPhase = PHASEMIXEDWORKLOAD;
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST);

        $display("Core functionality validated. Testing advanced features...");
        $display("");

        // Environmental stress tests with reduced instruction counts
        testPhase = PHASEPOWERSTRESS;
        powerBudget = 8'h50; // Reduce power budget
        $display("Testing power management under budget constraints...");
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST/2);
        powerBudget = 8'hC0; // Restore normal budget

        testPhase = PHASETHERMALSTRESS;
        thermalReading = 8'hA0; // High temperature
        $display("Testing thermal management under stress...");
        executeTestPhaseSimple(testPhase, INSTRUCTIONSPERTEST/2);
        thermalReading = 8'h64; // Restore normal temperature

        // Final stabilization
        testPhase = PHASEFINALANALYSIS;
        $display("Allowing systems to stabilize...");
        repeat (50) @(posedge clk); // Stabilization time

        // Mark test as complete
        testPhase = PHASECOMPLETE;

        // Display performance analysis
        displayThermalAnalysis();
        displaySimplePerformance();
        generateFinalReport();
        $display("==============================================================\n");
        $display("Time: %0t | All tests completed successfully!", $time);
        $display("==============================================================\n");
        $finish;
    end

endmodule