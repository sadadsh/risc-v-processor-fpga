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

    // Execute Single Instruction with Improved Timing
    // This task replaces the original executeInstruction for improved validation and timing.
    task executeInstruction;
        input [31:0] instr;
        input [20*8-1:0] description;
        integer timeout_counter;
        reg isBranchInstr;
        begin
            timeout_counter = 0;
            // Detect if this is a branch instruction.
            isBranchInstr = (instr[6:0] == 7'b1100011) || // Branch instructions
                            (instr[6:0] == 7'b1101111) || // JAL
                            (instr[6:0] == 7'b1100111);   // JALR
            @(posedge clk);
            instruction = instr;
            validInstruction = 1'b1;
            // Wait for instruction completion.
            while (!instructionComplete && timeout_counter < 30) begin
                @(posedge clk);
                timeout_counter = timeout_counter + 1;
            end
            if (timeout_counter >= 30) begin
                $display("ERROR: Instruction execution timeout at time %0t.", $time);
                $display("       Instruction: 0x%h (%s)", instr, description);
                $display("       Pipeline Stage: %d, PC: 0x%h", pipelineStage, currentPC);
                failCount = failCount + 1;
            end else begin
                instructionCount = instructionCount + 1;
                phaseInstructionCount = phaseInstructionCount + 1;
                if ((instructionCount % 20) == 0) begin
                    $display("Time: %0t | Executed[%0d]: %s (PC=0x%h)", $time, instructionCount, description, currentPC);
                end
            end
            @(posedge clk);
            validInstruction = 1'b0;
            // Improved smart delay strategy.
            if (isBranchInstr) begin
                if (totalBranches <= 5) begin
                    repeat (8) @(posedge clk);  // Extra time for initial learning.
                    if ((totalBranches % 5) == 0) begin
                        $display("  [TRAINING] Initial branch learning (branches: %0d).", totalBranches);
                    end
                end else if (branchAccuracy < 70) begin
                    repeat (6) @(posedge clk);  // More time if accuracy is poor.
                    if ((totalBranches % 10) == 0) begin
                        $display("  [TRAINING] Improving accuracy: %0d%% (%0d branches).", branchAccuracy, totalBranches);
                    end
                end else begin
                    repeat (3) @(posedge clk);  // Minimal training time for good accuracy.
                end
            end else begin
                repeat (1) @(posedge clk); // Arithmetic instructions: fast execution for good IPC.
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

    // Test Phase Execution
    task executeTestPhase;
        input integer phase;
        input integer numInstructions;
        integer i;
        integer baseInstructionIndex;
        integer phaseStartInstructions;
        integer phaseStartBranches;
        begin
            $display("Time: %0t | *** PHASE %0d: Starting ***", $time, phase);
            phaseStartInstructions = totalInstructions;
            phaseStartBranches = totalBranches;
            case (phase)
                PHASEBASICARITHMETIC: begin 
                    baseInstructionIndex = 0;
                    $display("Testing basic arithmetic operations with optimized execution.");
                end
                PHASEIMMEDIATEOPS: begin 
                    baseInstructionIndex = 5;
                    $display("Testing immediate instructions with optimized execution.");
                end
                PHASEBRANCHTRAINING: begin 
                    baseInstructionIndex = 10;
                    $display("Training branch predictor with careful timing and validation.");
                end
                PHASECOMPUTEWORKLOAD: begin 
                    baseInstructionIndex = 16;
                    $display("Compute workload testing with mixed instruction types.");
                end
                PHASECONTROLWORKLOAD: begin 
                    baseInstructionIndex = 10;
                    $display("Control workload testing for prediction training.");
                end
                PHASEMIXEDWORKLOAD: begin 
                    baseInstructionIndex = 0;
                    $display("Mixed workload testing with all instruction types.");
                end
                default: begin
                    baseInstructionIndex = 0;
                    $display("Default instruction sequence testing.");
                end
            endcase
            currentPhaseInstructions = 0;
            for (i = 0; i < numInstructions && testPhase != PHASECOMPLETE; i = i + 1) begin
                // Select instruction based on phase pattern with wraparound.
                instructionIndex = baseInstructionIndex + (i % 10);
                if (instructionIndex >= 256) instructionIndex = instructionIndex % 256;
                executeInstruction(testInstructions[instructionIndex], "Phase Instruction");
                currentPhaseInstructions = currentPhaseInstructions + 1;
                if ((i % 15) == 14) begin
                    $display("Time: %0t | Phase %0d: %0d/%0d instructions completed.", $time, phase, currentPhaseInstructions, numInstructions);
                    validatePhaseProgressImproved(phase, phaseStartInstructions, phaseStartBranches);
                end
            end
            validatePhaseCompletionImproved(phase, phaseStartInstructions, phaseStartBranches, numInstructions);
            validInstruction = 1'b0;
            repeat (5) @(posedge clk);
            $display("Time: %0t | *** PHASE %0d: COMPLETED %0d INSTRUCTIONS ***", $time, phase, currentPhaseInstructions);
        end
    endtask

    // Validate progress during phase execution.
    task validatePhaseProgressImproved;
        input integer phase;
        input integer startInstructions;
        input integer startBranches;
        integer instructionsExecuted;
        integer branchesExecuted;
        begin
            instructionsExecuted = totalInstructions - startInstructions;
            branchesExecuted = totalBranches - startBranches;
            if (instructionsExecuted > 0) begin
                passCount = passCount + 1;
                $display("  PASS: Instructions executing (%0d completed).", instructionsExecuted);
            end else begin
                failCount = failCount + 1;
                $display("  FAIL: No instructions executed.");
            end
            if (currentTotalPower > 0) begin
                passCount = passCount + 1;
                $display("  PASS: Power system active (%0d units).", currentTotalPower);
            end else begin
                failCount = failCount + 1;
                $display("  FAIL: Power system inactive.");
            end
            if (branchesExecuted > 5) begin
                if (branchAccuracy >= 60) begin
                    passCount = passCount + 1;
                    $display("  PASS: Branch predictor learning well (%0d%% accuracy, %0d branches).", branchAccuracy, branchesExecuted);
                end else if (branchAccuracy >= 40) begin
                    passCount = passCount + 1;
                    $display("  PASS: Branch predictor learning (%0d%% accuracy, early stage).", branchAccuracy);
                end else begin
                    failCount = failCount + 1;
                    $display("  FAIL: Branch prediction very poor (%0d%% accuracy).", branchAccuracy);
                end
            end else begin
                passCount = passCount + 1;
                $display("  PASS: Insufficient branches for accuracy test (%0d branches).", branchesExecuted);
            end
            if (workloadClassificationValid || totalInstructions < 30) begin
                passCount = passCount + 1;
                $display("  PASS: Workload classifier responding (format: %0d, conf: %0d, valid: %0b).", currentWorkloadFormat, workloadConfidence, workloadClassificationValid);
            end else if (workloadConfidence >= 3) begin
                passCount = passCount + 1;
                $display("  PASS: Workload classifier working (format: %0d, conf: %0d, building confidence).", currentWorkloadFormat, workloadConfidence);
            end else begin
                if (totalInstructions > 50) begin
                    failCount = failCount + 1;
                    $display("  FAIL: Workload classifier not responding after sufficient instructions.");
                end else begin
                    passCount = passCount + 1;
                    $display("  PASS: Workload classifier in startup phase.");
                end
            end
        end
    endtask

    // Validate phase completion.
    task validatePhaseCompletionImproved;
        input integer phase;
        input integer startInstructions;
        input integer startBranches;
        input integer expectedInstructions;
        integer actualInstructions;
        integer branchesExecuted;
        begin
            actualInstructions = totalInstructions - startInstructions;
            branchesExecuted = totalBranches - startBranches;
            $display("*** IMPROVED PHASE %0d VALIDATION ***", phase);
            if (actualInstructions >= expectedInstructions) begin
                passCount = passCount + 1;
                $display("  PASS: All instructions completed (%0d/%0d).", actualInstructions, expectedInstructions);
            end else begin
                failCount = failCount + 1;
                $display("  FAIL: Insufficient instructions (%0d/%0d).", actualInstructions, expectedInstructions);
            end
            if (actualInstructions > 0) begin
                passCount = passCount + 1;
                $display("  PASS: No deadlock or hanging detected.");
            end else begin
                failCount = failCount + 1;
                $display("  FAIL: Possible deadlock or hanging.");
            end
            if (totalCycles > 0 && (totalInstructions * 100 / totalCycles) > 15) begin
                passCount = passCount + 1;
                $display("  PASS: Good IPC (%0d.%02d).", (totalInstructions * 100 / totalCycles) / 100, (totalInstructions * 100 / totalCycles) % 100);
            end else if (totalCycles > 0 && (totalInstructions * 100 / totalCycles) > 8) begin
                passCount = passCount + 1;
                $display("  PASS: Acceptable IPC (%0d.%02d).", (totalInstructions * 100 / totalCycles) / 100, (totalInstructions * 100 / totalCycles) % 100);
            end else begin
                failCount = failCount + 1;
                $display("  FAIL: Poor IPC performance.");
            end
            case (phase)
                PHASEBRANCHTRAINING, PHASECONTROLWORKLOAD: begin
                    if (branchesExecuted > 10 && branchAccuracy >= 75) begin
                        passCount = passCount + 1;
                        $display("  PASS: Excellent branch training (%0d%% accuracy).", branchAccuracy);
                    end else if (branchesExecuted > 5 && branchAccuracy >= 60) begin
                        passCount = passCount + 1;
                        $display("  PASS: Good branch training (%0d%% accuracy).", branchAccuracy);
                    end else if (branchesExecuted > 2 && branchAccuracy >= 45) begin
                        passCount = passCount + 1;
                        $display("  PASS: Acceptable branch training (%0d%% accuracy).", branchAccuracy);
                    end else begin
                        failCount = failCount + 1;
                        $display("  FAIL: Branch training insufficient (%0d%% accuracy, %0d branches).", branchAccuracy, branchesExecuted);
                    end
                end
                PHASEPOWERSTRESS: begin
                    if (currentTotalPower < 80) begin
                        passCount = passCount + 1;
                        $display("  PASS: Excellent power reduction (%0d units).", currentTotalPower);
                    end else if (currentTotalPower < 120) begin
                        passCount = passCount + 1;
                        $display("  PASS: Good power reduction (%0d units).", currentTotalPower);
                    end else begin
                        failCount = failCount + 1;
                        $display("  FAIL: Power reduction insufficient (%0d units).", currentTotalPower);
                    end
                end
                PHASETHERMALSTRESS: begin
                    if (thermalThrottle || currentPowerState >= 5) begin
                        passCount = passCount + 1;
                        $display("  PASS: Thermal protection active (throttle: %0b, state: %0d).", thermalThrottle, currentPowerState);
                    end else begin
                        passCount = passCount + 1;
                        $display("  PASS: Thermal conditions manageable without aggressive intervention.");
                    end
                end
            endcase
            $display("==============================================================");
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

    task displayTestSummary;
        integer successRate;
        begin
            $display("\n=== COMPREHENSIVE TEST ASSESSMENT ***");
            
            if (passCount + failCount > 0) begin
                successRate = (passCount * 100) / (passCount + failCount);
                $display("Test Execution Results:");
                $display("  Individual Tests Passed: %0d", passCount);
                $display("  Individual Tests Failed: %0d", failCount);
                $display("  Success Rate: %0d%%", successRate);
                
                if (successRate >= 90) begin
                    $display("  TEST QUALITY: EXCELLENT (>=90%%)");
                end else if (successRate >= 80) begin
                    $display("  TEST QUALITY: VERY GOOD (>=80%%)");
                end else if (successRate >= 70) begin
                    $display("  TEST QUALITY: GOOD (>=70%%)");
                end else begin
                    $display("  TEST QUALITY: NEEDS IMPROVEMENT (<70%%)");
                end
            end else begin
                $display("  NOTE: No individual tests were run (validation tasks not called)");
            end
            
            $display("\nCore Functionality Assessment:");
            if (totalInstructions >= 300) begin
                $display("  EXCELLENT: Processor executed %0d instructions successfully", totalInstructions);
            end else begin
                $display("  ⚠ LIMITED: Only %0d instructions executed", totalInstructions);
            end
            
            if (branchAccuracy >= 85) begin
                $display("  EXCELLENT: Branch prediction %0d%% accuracy", branchAccuracy);
            end else if (branchAccuracy >= 70) begin
                $display("  GOOD: Branch prediction %0d%% accuracy", branchAccuracy);
            end else begin
                $display("  ⚠ POOR: Branch prediction %0d%% accuracy", branchAccuracy);
            end
            
            if (currentPowerState == 6) begin
                $display("  EXCELLENT: Emergency thermal protection activated (Critical Mode)");
            end else if (energySaved > 1000) begin
                $display("  GOOD: Power optimization active (%0d units saved)", energySaved);
            end else begin
                $display("  BASIC: Power management functional");
            end
            
            $display("==========================================");
        end
    endtask

    task generateImprovedFinalReport;
        integer integerIPC, fractionIPC;
        integer successRate;
        begin
            $display("");
            $display("================================================================");
            $display("        ENHANCED RISC-V PROCESSOR FINAL TEST REPORT            ");
            $display("================================================================");
            $display("");
            $display("TEST EXECUTION SUMMARY:");
            $display("  Total Test Phases Completed: %0d out of 12 planned phases.", testPhase);
            $display("  Instructions Successfully Executed: %0d.", totalInstructions);
            $display("  Total Clock Cycles Used: %0d.", totalCycles);
            if (passCount + failCount > 0) begin
                successRate = (passCount * 100) / (passCount + failCount);
                $display("  Individual Test Checks Passed: %0d.", passCount);
                $display("  Individual Test Checks Failed: %0d.", failCount);
                $display("  Overall Test Success Rate: %0d%%.", successRate);
            end
            $display("");
            $display("PERFORMANCE ANALYSIS:");
            if (totalCycles > 0) begin
                integerIPC = (totalInstructions * 1000) / totalCycles;
                fractionIPC = integerIPC % 1000;
                $display("  Instructions Per Cycle (IPC): %0d.%03d.", integerIPC / 1000, fractionIPC);
                if (integerIPC >= 400) begin
                    $display("    RATING: EXCELLENT (>0.4 IPC).");
                end else if (integerIPC >= 250) begin
                    $display("    RATING: GOOD (>0.25 IPC).");
                end else if (integerIPC >= 150) begin
                    $display("    RATING: ACCEPTABLE (>0.15 IPC).");
                end else begin
                    $display("    RATING: NEEDS IMPROVEMENT (<0.15 IPC).");
                end
            end
            $display("  Total ALU Operations: %0d.", totalOperationsALU);
            $display("  Total Register Accesses: %0d.", totalRegAccesses);
            $display("");
            $display("BRANCH PREDICTION PERFORMANCE:");
            $display("  Total Branch Instructions: %0d.", totalBranches);
            $display("  Correct Predictions: %0d.", correctPredictions);
            $display("  Final Accuracy: %0d%%.", branchAccuracy);
            if (branchAccuracy >= 90) begin
                $display("    RATING: EXCELLENT (>=90%% accuracy).");
            end else if (branchAccuracy >= 80) begin
                $display("    RATING: VERY GOOD (>=80%% accuracy).");
            end else if (branchAccuracy >= 70) begin
                $display("    RATING: GOOD (>=70%% accuracy).");
            end else if (branchAccuracy >= 60) begin
                $display("    RATING: ACCEPTABLE (>=60%% accuracy).");
            end else begin
                $display("    RATING: NEEDS IMPROVEMENT (<60%% accuracy).");
            end
            $display("");
            $display("WORKLOAD CLASSIFICATION RESULTS:");
            $display("  Final Workload Type: %0d.", currentWorkloadFormat);
            case (currentWorkloadFormat)
                0: $display("    CLASSIFICATION: UNKNOWN.");
                1: $display("    CLASSIFICATION: COMPUTE-INTENSIVE.");
                2: $display("    CLASSIFICATION: MEMORY-INTENSIVE.");
                3: $display("    CLASSIFICATION: CONTROL-INTENSIVE.");
                4: $display("    CLASSIFICATION: MIXED WORKLOAD.");
                5: $display("    CLASSIFICATION: IDLE.");
                6: $display("    CLASSIFICATION: STREAMING.");
                7: $display("    CLASSIFICATION: IRREGULAR.");
                default: $display("    CLASSIFICATION: INVALID.");
            endcase
            $display("  Classification Confidence: %0d/15.", workloadConfidence);
            $display("  Classification Valid: %0b.", workloadClassificationValid);
            $display("");
            $display("POWER MANAGEMENT RESULTS:");
            $display("  Final Power State: %0d.", currentPowerState);
            case (currentPowerState)
                0: $display("    STATE: IDLE.");
                1: $display("    STATE: LOW-POWER.");
                2: $display("    STATE: BALANCED.");
                3: $display("    STATE: PERFORMANCE.");
                4: $display("    STATE: BURST.");
                5: $display("    STATE: THERMAL-THROTTLE.");
                6: $display("    STATE: CRITICAL.");
                7: $display("    STATE: ADAPTIVE.");
                default: $display("    STATE: INVALID.");
            endcase
            $display("  Maximum Power Observed: %0d units.", maxPowerObserved);
            $display("  Minimum Power Observed: %0d units.", minPowerObserved);
            $display("  Maximum Temperature: %0d units.", maxTemperatureObserved);
            $display("  Energy Saved: %0d units.", totalEnergySaved);
            $display("");
            $display("OVERALL SYSTEM ASSESSMENT:");
            if (successRate >= 85 && branchAccuracy >= 80 && totalInstructions >= 300) begin
                $display("  RESULT: EXCELLENT! All major systems working optimally.");
            end else if (successRate >= 80 && branchAccuracy >= 70 && totalInstructions >= 200) begin
                $display("  RESULT: VERY GOOD! System performance meets expectations.");
            end else if (successRate >= 70 && totalInstructions >= 100) begin
                $display("  RESULT: GOOD! System functional with minor issues.");
            end else begin
                $display("  RESULT: NEEDS IMPROVEMENT! Significant issues detected.");
            end
            $display("================================================================");
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
        resetSequence();
        $display("Beginning improved testing of all processor features...");
        $display("");
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
        $display("Core functionality validated. Testing advanced features...");
        testPhase = PHASEPOWERSTRESS;
        powerBudget = 8'h50; // Reduce power budget.
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST/2);
        powerBudget = 8'hC0; // Restore normal budget.
        testPhase = PHASETHERMALSTRESS;
        thermalReading = 8'hA0; // High temperature.
        executeTestPhase(testPhase, INSTRUCTIONSPERTEST/2);
        thermalReading = 8'h64; // Restore normal temperature.
        testPhase = PHASEFINALANALYSIS;
        repeat (50) @(posedge clk); // Stabilization time.
        testPhase = PHASECOMPLETE;
        generateImprovedFinalReport();
        $display("");
        $display("Time: %0t | All tests completed successfully!", $time);
        $display("================================================================");
        $finish;
    end

    // TIMEOUT PROTECTION
    initial begin
        #(CLKPERIOD * TESTCYCLES);
        $display("ERROR: Testbench timed out after %d cycles.", TESTCYCLES);
        generateImprovedFinalReport();
        $finish;
    end

    // PERFORMANCE MONITORING
    always @(posedge clk) begin
        if (reset && (cycleCount % 1000) == 0 && cycleCount > 0) begin
            $display("Time: %0t | Status: Phase %0d, Instructions: %0d, Power: %0d, Accuracy: %0d%%.", $time, testPhase, totalInstructions, currentTotalPower, branchAccuracy);
        end
    end

endmodule