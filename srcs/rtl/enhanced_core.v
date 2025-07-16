`timescale 1ns / 1ps

// ENHANCED PROCESSOR CORE
// Engineer: Sadad Haidari

module enhanced_core (
    input wire clk,
    input wire reset,

    // Instruction Interface
    input wire [31:0] instruction,
    input wire validInstruction,
    output wire requestNextInstruction,

    // External Power/Thermal Interface
    input wire [7:0] powerBudget,
    input wire [7:0] thermalReading,
    input wire [7:0] batteryLevel,
    input wire performanceMode,

    // Processor Status Outputs
    output wire instructionComplete,
    output wire branchTaken,
    output wire [31:0] branchTarget,

    // Enhanced Performance Monitoring
    output wire [31:0] totalInstructions,
    output wire [31:0] totalCycles,
    output wire [31:0] totalBranches,
    output wire [31:0] correctPredictions,
    output wire [7:0] branchAccuracy,
    output wire [31:0] totalOperationsALU,
    output wire [31:0] totalRegAccesses,

    // Workload Classification Outputs
    output wire [2:0] currentWorkloadFormat,
    output wire [3:0] workloadConfidence,
    output wire [7:0] computeToll,
    output wire [7:0] memToll,
    output wire [7:0] controlToll,
    output wire [7:0] complexPattern,
    output wire workloadClassificationValid,

    // Power Management Outputs
    output wire [2:0] currentPowerState,
    output wire [2:0] clockFrequencyLevel,
    output wire [2:0] voltageLevel,
    output wire [7:0] currentTotalPower,
    output wire [7:0] powerEfficiency,
    output wire [7:0] temperatureEstimate,
    output wire [15:0] energySaved,
    output wire powerOptimizationActive,
    output wire thermalThrottle,

    // Component Power Gating Status
    output wire powerGateALU,
    output wire powerGateRegister,
    output wire powerGateBranchPredictor,
    output wire powerGateCache,

    // Advanced Debug and Monitoring
    output wire [4:0] rs1Debug, rs2Debug, rdDebug,
    output wire [31:0] rsData1Debug, rsData2Debug,
    output wire [31:0] resultALUDebug,
    output wire [31:0] currentPC,
    output wire [2:0] pipelineStage,
    output wire [7:0] adaptationRate,
    output wire [7:0] powerTrend
);

    // INTERNAL WIRE DECLARATIONS
    // Instruction decoding signals from the decoder module.
    wire [6:0] opcode;           // Operation code from instruction.
    wire [4:0] rd, rs1, rs2;     // Register addresses for destination and sources.
    wire [2:0] fun3;             // Function field 3 for instruction type.
    wire [6:0] fun7;             // Function field 7 for extended operations.
    wire [31:0] immediateValue;  // Decoded immediate value.
    wire enRegWrite, enALU, useImmediate;  // Control signals for register write and ALU operations.
    wire [3:0] opALU;            // ALU operation code.
    wire isBranch, isJump;       // Branch and jump instruction flags.
    wire [2:0] branchT;          // Branch type for conditional branches.
    wire staticBranchTaken;      // Static branch prediction result.
    wire isRT, isIT, isBT, isJT, isVI;  // Instruction type flags.

    // Register File Signals
    // Signals for register file operations and monitoring.
    wire [31:0] rsData1, rsData2;        // Register source data values.
    wire [31:0] regAccessCount, regWriteCount;  // Register access statistics.
    wire [4:0] regMostUsed;              // Most frequently used register.
    wire regPowerActive;                 // Register file power status.

    // ALU Signals
    // Signals for arithmetic logic unit operations and monitoring.
    wire [31:0] resultALU;               // ALU computation result.
    wire flagZeroALU;                    // Zero flag from ALU operation.
    wire [31:0] operationTotalALU;       // Total ALU operations performed.
    wire [4:0] operationMostUsedALU;     // Most frequently used ALU operation.
    wire [7:0] estimatedPowerALU;        // Estimated ALU power consumption.
    wire operationActiveALU;             // ALU operation active status.

    // Branch Predictor Signals
    // Signals for branch prediction and accuracy tracking.
    wire predictTaken;                   // Dynamic branch prediction result.
    wire [3:0] predictionConfidence;     // Confidence level of prediction.
    wire predictionValid;                // Prediction validity flag.
    wire [15:0] totalPredictions, correctPredictionsBP;  // Prediction statistics.
    wire [7:0] accuracyPercent;          // Branch prediction accuracy percentage.

    // Workload Classifier Signals
    // Signals for workload classification and analysis.
    wire [2:0] workloadFormat;           // Classified workload type.
    wire [3:0] classificationConfidence; // Confidence in workload classification.
    wire [7:0] computeTollInternal, memTollInternal, controlTollInternal, complexPatternInternal;  // Workload metrics.
    wire [15:0] classificationCount;     // Number of classifications performed.
    wire [7:0] classifierAdaptationRate; // Workload classifier adaptation rate.
    wire classificationValid;            // Workload classification validity.

    // Power Optimizer Signals
    // Signals for power management and optimization.
    wire [2:0] powerState;               // Current power management state.
    wire [2:0] frequencyLevel, voltageLevelInternal;  // Frequency and voltage levels.
    wire [7:0] totalPower, efficiency, temperatureEstimateInternal;  // Power and thermal metrics.
    wire [15:0] savedEnergy;             // Energy saved through optimization.
    wire [7:0] optimizationQuality;      // Quality metric of power optimization.
    wire [2:0] predictedWorkloadFormat;  // Predicted workload for optimization.
    wire [3:0] optimizerAdaptationRate;  // Power optimizer adaptation rate.
    wire [7:0] powerConsumptionTrend;    // Trend in power consumption.
    wire optimizationActive;             // Power optimization active status.
    wire thermalThrottling;              // Thermal throttling status.
    wire gateALU, gateRegister, gateBranchPredictor, gateCache;  // Power gating signals.

    // PROCESSOR CONTROL AND STATE REGISTERS
    // Core processor state and control registers.
    reg [31:0] programCounter;           // Current program counter value.
    reg [31:0] instructionCounter;       // Total instructions executed.
    reg [31:0] cycleCounter;             // Total clock cycles elapsed.
    reg [31:0] branchCounter;            // Total branches encountered.
    reg instructionCompleted;            // Instruction completion flag.
    reg requestInstruction;              // Instruction request signal.
    reg branchWasTaken;                  // Branch taken status.
    reg [31:0] calculatedBranchTarget;   // Calculated branch target address.

    // PIPELINE STATE MANAGEMENT
    // Pipeline control and state tracking registers.
    reg [2:0] currentPipelineStage;     // Current pipeline stage.
    reg pipelineActive;                  // Pipeline active status.

    // BRANCH RESOLUTION AND CONTROL FLOW
    // Branch resolution and control flow management registers.
    reg branchResolved;                  // Branch resolution completion flag.
    reg actualBranchTaken;               // Actual branch outcome.
    reg [31:0] resolvedPC;               // Program counter when branch resolved.
    reg branchMispredicted;              // Branch misprediction flag.
    reg [2:0] resolvedBranchType;        // Type of resolved branch.

    // PERFORMANCE TRACKING
    // Performance monitoring and comparison registers.
    reg [31:0] previousInstructions;     // Previous instruction count for comparison.
    reg [31:0] previousCycles;           // Previous cycle count for comparison.

    // POWER MANAGEMENT INTERFACE
    // Component power consumption modeling registers.
    reg [7:0] componentPowerALU;         // ALU component power consumption.
    reg [7:0] componentPowerRegister;    // Register file component power consumption.
    reg [7:0] componentPowerBranchPredictor;  // Branch predictor component power consumption.
    reg [7:0] componentPowerCache;       // Cache component power consumption.
    reg [7:0] componentPowerCore;        // Core component power consumption.

    // PIPELINE STAGES
    // Constants defining the different pipeline stages.
    localparam STAGEIDLE         = 3'b000;  // Pipeline idle state.
    localparam STAGEFETCH        = 3'b001;  // Instruction fetch stage.
    localparam STAGEDECODE       = 3'b010;  // Instruction decode stage.
    localparam STAGEEXECUTE      = 3'b011;  // Instruction execute stage.
    localparam STAGEMEMORY       = 3'b100;  // Memory access stage.
    localparam STAGEWRITEBACK    = 3'b101;  // Write back stage.

    // ALU OPERAND SELECTION
    // Select operands for ALU based on instruction type.
    wire [31:0] operandA, operandB;
    assign operandA = rsData1;  // First operand always comes from register rs1.
    assign operandB = useImmediate ? immediateValue : rsData2;  // Second operand comes from immediate value or register rs2.

    // REGISTER WRITE CONTROL
    // Control register write operations based on pipeline stage and power gating.
    wire regWriteEnable;
    assign regWriteEnable = enRegWrite && pipelineActive &&
                            (currentPipelineStage == STAGEWRITEBACK) && !gateRegister;

    // POWER CONSUMPTION MODELING
    // Model power consumption for each component based on activity and gating.
    always @(*) begin
        // ALU power consumption based on gating and operation activity.
        componentPowerALU = gateALU ? 8'h02 : 
                        (operationActiveALU ? 8'h40 : 8'h18);
        
        // Register file power consumption based on gating and access activity.
        componentPowerRegister = gateRegister ? 8'h01 : 
                                (regPowerActive ? 8'h25 : 8'h12);
        
        // Branch predictor power consumption based on gating and branch activity.
        componentPowerBranchPredictor = gateBranchPredictor ? 8'h01 : 
                                    (isBranch ? 8'h15 : 8'h08);
        
        // Cache power consumption based on gating and pipeline activity.
        componentPowerCache = gateCache ? 8'h02 : 
                            (pipelineActive ? 8'h30 : 8'h15);
        
        // Core power consumption based on pipeline activity.
        componentPowerCore = pipelineActive ? 8'h25 : 8'h10;
    end

    // BRANCH TARGET CALCULATION
    // Calculate branch target address for branches and jumps.
    always @(*) begin
        if (isBranch || isJump) begin
            calculatedBranchTarget = programCounter + immediateValue;  // Branch target is PC + offset.
        end else begin
            calculatedBranchTarget = programCounter + 4;  // Next instruction is PC + 4.
        end
    end

    // BRANCH OUTCOME DETERMINATION AND TRAINING
    // Determine actual branch outcome and provide training signals to branch predictor.
    always @(posedge clk) begin
        if (!reset) begin
            // Reset branch resolution signals.
            branchResolved <= 1'b0;
            actualBranchTaken <= 1'b0;
            branchMispredicted <= 1'b0;
            resolvedBranchType <= 3'b000;
        end else begin
            branchResolved <= 1'b0; // Default to no resolution.
            
            // Branch resolution during execute stage.
            if (isBranch && (currentPipelineStage == STAGEEXECUTE) && pipelineActive) begin
                // Determine actual branch outcome based on branch type and ALU result.
                case (branchT)
                    3'b000: actualBranchTaken <= flagZeroALU;      // BEQ: branch if equal.
                    3'b001: actualBranchTaken <= !flagZeroALU;     // BNE: branch if not equal.
                    3'b100: actualBranchTaken <= resultALU[0];     // BLT: branch if less than.
                    3'b101: actualBranchTaken <= !resultALU[0];    // BGE: branch if greater or equal.
                    3'b110: actualBranchTaken <= resultALU[0];     // BLTU: branch if less than unsigned.
                    3'b111: actualBranchTaken <= !resultALU[0];    // BGEU: branch if greater or equal unsigned.
                    default: actualBranchTaken <= 1'b0;
                endcase
                resolvedBranchType <= branchT;  // Store resolved branch type.
            end
            
            // Set training signal during memory stage (one cycle after execute).
            if (isBranch && (currentPipelineStage == STAGEMEMORY) && pipelineActive) begin
                branchResolved <= 1'b1;  // Enable branch predictor training.
                resolvedPC <= programCounter;  // Store PC for training.
                branchMispredicted <= (actualBranchTaken != branchWasTaken);  // Detect misprediction.
            end
            
            // Handle jumps (always taken).
            if (isJump && (currentPipelineStage == STAGEEXECUTE) && pipelineActive) begin
                actualBranchTaken <= 1'b1;  // Jumps are always taken.
            end
        end
    end

    // MODULE INSTANTIATIONS

    // Instruction Decoder
    // Decode RISC V instructions into control signals and operands.
    instruction_decoder decoderUnit (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .fun3(fun3),
        .rs1(rs1),
        .rs2(rs2),
        .fun7(fun7),
        .immediateValue(immediateValue),
        .enRegWrite(enRegWrite),
        .enALU(enALU),
        .opALU(opALU),
        .useImmediate(useImmediate),
        .isBranch(isBranch),
        .isJump(isJump),
        .branchT(branchT),
        .branchTaken(staticBranchTaken),
        .isRT(isRT),
        .isIT(isIT),
        .isBT(isBT),
        .isJT(isJT),
        .isVI(isVI)
    );
    
    // Register File
    // Manage register file operations and provide access statistics.
    register registerUnit (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rsData1(rsData1),
        .rsData2(rsData2),
        .enWrite(regWriteEnable),
        .rdData(resultALU),
        .regAccessCount(regAccessCount),
        .regWriteCount(regWriteCount),
        .regMostUsed(regMostUsed),
        .powerActive(regPowerActive)
    );

    // ALU
    // Perform arithmetic and logical operations with power monitoring.
    alu arithmeticUnit (
        .clk(clk),
        .reset(reset),
        .operandA(operandA),
        .operandB(operandB),
        .op(opALU),
        .enALU(enALU && pipelineActive && (currentPipelineStage == STAGEEXECUTE) && !gateALU),
        .result(resultALU),
        .flagZero(flagZeroALU),
        .operationTotal(operationTotalALU),
        .operationMostUsed(operationMostUsedALU),
        .estimatedPower(estimatedPowerALU),
        .operationActive(operationActiveALU)
    );

    // Branch Predictor with proper training signals
    // Predict branch outcomes and learn from actual results.
    branch_predictor branchPredictorUnit (
        .clk(clk),
        .reset(reset),
        .isBranch(isBranch && pipelineActive && (currentPipelineStage == STAGEFETCH)),
        .branchPC(programCounter),
        .branchT(branchT),
        .branchResolved(branchResolved),
        .actualTaken(actualBranchTaken),
        .resolvedPC(resolvedPC),
        .predictTaken(predictTaken),
        .confidence(predictionConfidence),
        .predictionValid(predictionValid),
        .totalPredictions(totalPredictions),
        .correctPredictions(correctPredictionsBP),
        .accuracyPresent(accuracyPercent)
    );

    // Workload Classifier with proper instruction signals
    // Analyze instruction patterns to classify workload characteristics.
    workload_classifier classifierUnit (
        .clk(clk),
        .reset(reset),
        .instructionValid(pipelineActive && validInstruction && 
                         ((currentPipelineStage == STAGEDECODE) || (currentPipelineStage == STAGEEXECUTE))),
        .opcode(opcode),
        .fun3(fun3),
        .isBranch(isBranch),
        .branchTaken(actualBranchTaken),
        .resultALU(resultALU),
        .activeALU(operationActiveALU && (currentPipelineStage == STAGEEXECUTE)),
        .opALU(opALU),
        .regWrite(regWriteEnable),
        .regAddress(rd),
        .regData(resultALU),
        .totalInstructions(instructionCounter),
        .totalOperationsALU(operationTotalALU),
        .totalRegAccesses(regAccessCount),
        .currentPower(totalPower),
        .workloadFormat(workloadFormat),
        .workloadConfidence(classificationConfidence),
        .computeToll(computeTollInternal),
        .memToll(memTollInternal),
        .controlToll(controlTollInternal),
        .complexPattern(complexPatternInternal),
        .classificationCount(classificationCount),
        .adaptationRate(classifierAdaptationRate),
        .classificationValid(classificationValid)
    );

    // Power Optimizer
    // Manage power consumption and optimize based on workload and constraints.
    power_optimizer powerOptimizerUnit (
        .clk(clk),
        .reset(reset),
        .workloadFormat(workloadFormat),
        .workloadConfidence(classificationConfidence),
        .computeToll(computeTollInternal),
        .memToll(memTollInternal),
        .controlToll(controlTollInternal),
        .complexPattern(complexPatternInternal),
        .classificationValid(classificationValid),
        .powerALU(componentPowerALU),
        .powerRegister(componentPowerRegister),
        .powerBranchPredictor(componentPowerBranchPredictor),
        .powerCache(componentPowerCache),
        .powerCore(componentPowerCore),
        .totalInstructions(instructionCounter),
        .totalCycles(cycleCounter),
        .branchAccuracy(accuracyPercent),
        .cacheHitRate(16'h8000),
        .activeProcessor(pipelineActive),
        .powerBudget(powerBudget),
        .thermalReading(thermalReading),
        .batteryLevel(batteryLevel),
        .performanceMode(performanceMode),
        .clockFrequencyLevel(frequencyLevel),
        .voltageLevel(voltageLevelInternal),
        .powerGateALU(gateALU),
        .powerGateRegister(gateRegister),
        .powerGateBranchPredictor(gateBranchPredictor),
        .powerGateCache(gateCache),
        .thermalThrottle(thermalThrottling),
        .currentTotalPower(totalPower),
        .powerEfficiency(efficiency),
        .temperatureEstimate(temperatureEstimateInternal),
        .energySaved(savedEnergy),
        .optimizationQuality(optimizationQuality),
        .predictedWorkloadFormat(predictedWorkloadFormat),
        .adaptationRate(optimizerAdaptationRate),
        .powerTrend(powerConsumptionTrend),
        .powerOptimizationActive(optimizationActive),
        .powerState(powerState)
    );

    // MAIN PROCESSOR CONTROL LOGIC
    // Main state machine controlling processor operation and pipeline flow.
    always @(posedge clk) begin
        if (!reset) begin
            // Reset State
            // Initialize all processor state registers to safe default values.
            programCounter <= 32'h00001000;  // Start at typical RISC V entry point.
            instructionCounter <= 32'h0;     // No instructions executed yet.
            cycleCounter <= 32'h0;           // No cycles elapsed yet.
            branchCounter <= 32'h0;          // No branches encountered yet.
            instructionCompleted <= 1'b0;    // No instruction completed.
            requestInstruction <= 1'b0;      // No instruction request.
            branchWasTaken <= 1'b0;          // No branch taken.
            currentPipelineStage <= STAGEIDLE;  // Start in idle state.
            pipelineActive <= 1'b0;          // Pipeline not active.
            branchResolved <= 1'b0;          // No branch resolved.
            branchMispredicted <= 1'b0;      // No misprediction.
        end else begin
            // Normal Operation
            // Increment cycle counter for performance tracking.
            cycleCounter <= cycleCounter + 1;
            
            // Default values for control signals.
            instructionCompleted <= 1'b0;
            
            // Pipeline State Machine
            // Control the flow of instructions through the pipeline stages.
            case (currentPipelineStage)
                STAGEIDLE: begin
                    // Idle stage: request new instruction when ready.
                    requestInstruction <= 1'b1;
                    
                    if (validInstruction && isVI) begin
                        // Valid instruction received, activate pipeline.
                        pipelineActive <= 1'b1;
                        currentPipelineStage <= STAGEFETCH;
                        requestInstruction <= 1'b0;
                    end
                end
                
                STAGEFETCH: begin
                    // Fetch stage: perform branch prediction and count branches.
                    if (isBranch || isJump) begin
                        branchCounter <= branchCounter + 1;  // Count branches.
                        branchWasTaken <= predictTaken;      // Use dynamic prediction.
                    end
                    currentPipelineStage <= STAGEDECODE;     // Move to decode stage.
                end
                
                STAGEDECODE: begin
                    // Decode stage: instruction decoding happens combinationally.
                    currentPipelineStage <= STAGEEXECUTE;    // Move to execute stage.
                end
                
                STAGEEXECUTE: begin
                    // Execute stage: ALU operations and branch resolution.
                    currentPipelineStage <= STAGEMEMORY;     // Move to memory stage.
                end
                
                STAGEMEMORY: begin
                    // Memory stage: memory operations and branch training.
                    currentPipelineStage <= STAGEWRITEBACK;  // Move to write back stage.
                end
                
                STAGEWRITEBACK: begin
                    // Write back stage: complete instruction and update state.
                    instructionCompleted <= 1'b1;            // Mark instruction complete.
                    instructionCounter <= instructionCounter + 1;  // Count completed instruction.
                    
                    // Update program counter based on branch outcome.
                    if ((isBranch && actualBranchTaken) || isJump) begin
                        programCounter <= calculatedBranchTarget;  // Branch taken, use target.
                    end else begin
                        programCounter <= programCounter + 4;      // No branch, increment PC.
                    end
                    
                    // Check for next instruction availability.
                    if (validInstruction && isVI) begin
                        currentPipelineStage <= STAGEFETCH;  // Continue with next instruction.
                    end else begin
                        pipelineActive <= 1'b0;              // Deactivate pipeline.
                        currentPipelineStage <= STAGEIDLE;   // Return to idle.
                    end
                end
                
                default: begin
                    // Default case: return to idle state.
                    currentPipelineStage <= STAGEIDLE;
                    pipelineActive <= 1'b0;
                end
            endcase

            // Performance tracking
            // Update performance comparison values periodically.
            if (cycleCounter[7:0] == 8'h0) begin
                previousInstructions <= instructionCounter;  // Store for comparison.
                previousCycles <= cycleCounter;              // Store for comparison.
            end
        end
    end
    
    // OUTPUT ASSIGNMENTS
    // Connect internal signals to module outputs for external monitoring.

    // Basic processor status outputs
    assign instructionComplete = instructionCompleted;       // Instruction completion status.
    assign requestNextInstruction = requestInstruction;      // Instruction request signal.
    assign branchTaken = branchWasTaken && instructionCompleted;  // Branch taken with completion.
    assign branchTarget = calculatedBranchTarget;           // Calculated branch target address.

    // Performance Monitoring
    // Output performance statistics for external monitoring.
    assign totalInstructions = instructionCounter;          // Total instructions executed.
    assign totalCycles = cycleCounter;                      // Total cycles elapsed.
    assign totalBranches = branchCounter;                   // Total branches encountered.
    assign correctPredictions = correctPredictionsBP;       // Correct branch predictions.
    assign branchAccuracy = accuracyPercent;                // Branch prediction accuracy.
    assign totalOperationsALU = operationTotalALU;          // Total ALU operations.
    assign totalRegAccesses = regAccessCount;               // Total register accesses.

    // Workload Classification
    // Output workload analysis results for external monitoring.
    assign currentWorkloadFormat = workloadFormat;          // Current workload type.
    assign workloadConfidence = classificationConfidence;   // Classification confidence.
    assign computeToll = computeTollInternal;               // Compute intensity metric.
    assign memToll = memTollInternal;                       // Memory intensity metric.
    assign controlToll = controlTollInternal;               // Control flow intensity metric.
    assign complexPattern = complexPatternInternal;         // Pattern complexity metric.
    assign workloadClassificationValid = classificationValid;  // Classification validity.

    // Power Management
    // Output power management status and metrics.
    assign currentPowerState = powerState;                  // Current power state.
    assign clockFrequencyLevel = frequencyLevel;            // Current frequency level.
    assign voltageLevel = voltageLevelInternal;             // Current voltage level.
    assign currentTotalPower = totalPower;                  // Total power consumption.
    assign powerEfficiency = efficiency;                    // Power efficiency metric.
    assign temperatureEstimate = temperatureEstimateInternal;  // Estimated temperature.
    assign energySaved = savedEnergy;                       // Energy saved through optimization.
    assign powerOptimizationActive = optimizationActive;    // Power optimization status.
    assign thermalThrottle = thermalThrottling;             // Thermal throttling status.

    // Power Gating Status
    // Output power gating status for each component.
    assign powerGateALU = gateALU;                          // ALU power gating status.
    assign powerGateRegister = gateRegister;                // Register power gating status.
    assign powerGateBranchPredictor = gateBranchPredictor;  // Branch predictor power gating status.
    assign powerGateCache = gateCache;                      // Cache power gating status.

    // Debug and Monitoring
    // Output debug information for development and testing.
    assign rs1Debug = rs1;                                  // Source register 1 address.
    assign rs2Debug = rs2;                                  // Source register 2 address.
    assign rdDebug = rd;                                    // Destination register address.
    assign rsData1Debug = rsData1;                          // Source register 1 data.
    assign rsData2Debug = rsData2;                          // Source register 2 data.
    assign resultALUDebug = resultALU;                      // ALU result value.
    assign currentPC = programCounter;                      // Current program counter.
    assign pipelineStage = currentPipelineStage;            // Current pipeline stage.
    assign adaptationRate = (classifierAdaptationRate + optimizerAdaptationRate) / 2;  // Average adaptation rate.
    assign powerTrend = powerConsumptionTrend;              // Power consumption trend.

endmodule