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

    // ======================================================================
    // PIPELINE STAGES AND CONTROL SIGNALS
    // ======================================================================
    
    // Pipeline stage definitions for 5-stage RISC-V pipeline.
    localparam STAGE_IDLE      = 3'b000;  // Pipeline idle state
    localparam STAGE_FETCH     = 3'b001;  // Instruction fetch stage
    localparam STAGE_DECODE    = 3'b010;  // Instruction decode stage
    localparam STAGE_EXECUTE   = 3'b011;  // Instruction execute stage
    localparam STAGE_MEMORY    = 3'b100;  // Memory access stage
    localparam STAGE_WRITEBACK = 3'b101;  // Write back stage

    // Pipeline control registers.
    reg [2:0] currentPipelineStage;
    reg [31:0] programCounter;
    reg [31:0] instructionCounter;
    reg [31:0] cycleCounter;
    reg [31:0] branchCounter;
    reg instructionCompleted;
    reg requestInstruction;
    reg pipelineActive;

    // Branch control signals.
    reg branchWasTaken;
    reg branchResolved;
    reg actualBranchTaken;
    reg [31:0] calculatedBranchTarget;
    reg [31:0] resolvedPC;
    reg branchMispredicted;
    reg [2:0] resolvedBranchType;

    // ======================================================================
    // INSTRUCTION DECODING SIGNALS
    // ======================================================================
    
    // Instruction fields decoded by instruction_decoder module.
    wire [6:0] opcode;           // Operation code from instruction
    wire [4:0] rd, rs1, rs2;     // Register addresses for destination and sources
    wire [2:0] fun3;             // Function field 3 for instruction type
    wire [6:0] fun7;             // Function field 7 for extended operations
    wire [31:0] immediateValue;  // Decoded immediate value
    wire enRegWrite, enALU, useImmediate;  // Control signals for register write and ALU operations
    wire [3:0] opALU;            // ALU operation code
    wire isBranch, isJump;       // Branch and jump instruction flags
    wire [2:0] branchT;          // Branch type for conditional branches
    wire staticBranchTaken;      // Static branch prediction result
    wire isRT, isIT, isBT, isJT, isVI;  // Instruction type flags

    // ======================================================================
    // REGISTER FILE SIGNALS
    // ======================================================================
    
    // Register file interface signals for reading/writing registers.
    wire [31:0] rsData1, rsData2;        // Register source data values
    wire [31:0] regAccessCount, regWriteCount;  // Register access statistics
    wire [4:0] regMostUsed;              // Most frequently used register
    wire regPowerActive;                 // Register file power status

    // ======================================================================
    // ALU SIGNALS
    // ======================================================================
    
    // ALU interface signals for arithmetic and logic operations.
    wire [31:0] resultALU;               // ALU computation result
    wire flagZeroALU;                    // Zero flag from ALU operation
    wire [31:0] operationTotalALU;       // Total ALU operations performed
    wire [3:0] operationMostUsedALU;     // Most frequently used ALU operation (changed from [4:0])
    wire [7:0] estimatedPowerALU;        // Estimated ALU power consumption
    wire operationActiveALU;             // ALU operation active status

    // ======================================================================
    // BRANCH PREDICTOR SIGNALS
    // ======================================================================
    
    // Branch predictor interface for adaptive prediction with confidence tracking.
    wire predictTaken;                   // Dynamic branch prediction result
    wire [3:0] predictionConfidence;     // Confidence level of prediction
    wire predictionValid;                // Prediction validity flag
    wire [15:0] totalPredictions, correctPredictionsBP;  // Prediction statistics
    wire [7:0] accuracyPercent;          // Branch prediction accuracy percentage

    // ======================================================================
    // WORKLOAD CLASSIFIER SIGNALS
    // ======================================================================
    
    // Workload classifier interface for intelligent workload analysis.
    wire [2:0] workloadFormat;           // Classified workload type
    wire [3:0] classificationConfidence; // Confidence in workload classification
    wire [7:0] computeTollInternal, memTollInternal, controlTollInternal, complexPatternInternal;  // Workload metrics
    wire [15:0] classificationCount;     // Number of classifications performed
    wire [7:0] classifierAdaptationRate; // Workload classifier adaptation rate
    wire classificationValid;            // Workload classification validity

    // ======================================================================
    // POWER OPTIMIZER SIGNALS
    // ======================================================================
    
    // Power management interface for intelligent power optimization.
    wire [2:0] powerState;               // Current power management state
    wire [2:0] frequencyLevel, voltageLevelInternal;  // Frequency and voltage levels
    wire [7:0] totalPower;               // Total system power consumption
    wire [7:0] efficiency;               // Power efficiency metric
    wire [7:0] temperatureEstimateInternal;  // Temperature estimate
    wire [15:0] savedEnergy;             // Energy saved by optimization
    wire [7:0] optimizationQuality;      // Quality of power optimization
    wire [2:0] predictedWorkloadFormat;  // Predicted future workload format
    wire [7:0] optimizerAdaptationRate;  // Power optimizer adaptation rate
    wire [7:0] powerConsumptionTrend;    // Power consumption trend
    wire optimizationActive;             // Power optimization active status
    wire thermalThrottling;              // Thermal throttling status
    wire powerGateCoreInternal;  // Internal core power gating signal
    wire [3:0] optimizerAdaptationRate4bit;  // 4-bit adaptation rate from power optimizer

    // Power gating control signals.
    wire gateALU, gateRegister, gateBranchPredictor, gateCache;

    // ======================================================================
    // COMPONENT POWER MODELING
    // ======================================================================
    
    // Power consumption modeling for each component based on activity and gating.
    reg [7:0] componentPowerALU;         // ALU component power consumption
    reg [7:0] componentPowerRegister;    // Register file component power consumption
    reg [7:0] componentPowerBranchPredictor;  // Branch predictor component power consumption
    reg [7:0] componentPowerCache;       // Cache component power consumption
    reg [7:0] componentPowerCore;        // Core component power consumption

    // ======================================================================
    // ALU OPERAND SELECTION
    // ======================================================================
    
    // Select operands for ALU based on instruction type and immediate usage.
    wire [31:0] operandA, operandB;
    assign operandA = rsData1;  // First operand always comes from register rs1
    assign operandB = useImmediate ? immediateValue : rsData2;  // Second operand from immediate or rs2

    // ======================================================================
    // REGISTER WRITE CONTROL
    // ======================================================================
    
    // Control register write operations based on pipeline stage and power gating.
    wire regWriteEnable;
    assign regWriteEnable = enRegWrite && pipelineActive &&
                            (currentPipelineStage == STAGE_WRITEBACK) && !gateRegister;

    // ======================================================================
    // POWER CONSUMPTION MODELING
    // ======================================================================
    
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

    // ======================================================================
    // BRANCH TARGET CALCULATION
    // ======================================================================
    
    // Calculate branch target address for branches and jumps.
    always @(*) begin
        if (isBranch || isJump) begin
            calculatedBranchTarget = programCounter + immediateValue;  // Branch target is PC + offset
        end else begin
            calculatedBranchTarget = programCounter + 4;  // Next instruction is PC + 4
        end
    end

    // ======================================================================
    // BRANCH OUTCOME DETERMINATION AND TRAINING
    // ======================================================================
    
    // Determine actual branch outcome and provide training signals to branch predictor.
    always @(posedge clk) begin
        if (!reset) begin
            // Reset branch resolution signals.
            branchResolved <= 1'b0;
            actualBranchTaken <= 1'b0;
            branchMispredicted <= 1'b0;
            resolvedBranchType <= 3'b000;
        end else begin
            branchResolved <= 1'b0; // Default to no resolution
            
            // Branch resolution during execute stage.
            if (isBranch && (currentPipelineStage == STAGE_EXECUTE) && pipelineActive) begin
                // Determine actual branch outcome based on branch type and ALU result.
                case (branchT)
                    3'b000: actualBranchTaken <= flagZeroALU;      // BEQ: branch if equal
                    3'b001: actualBranchTaken <= !flagZeroALU;     // BNE: branch if not equal
                    3'b100: actualBranchTaken <= resultALU[0];     // BLT: branch if less than
                    3'b101: actualBranchTaken <= !resultALU[0];    // BGE: branch if greater or equal
                    3'b110: actualBranchTaken <= resultALU[0];     // BLTU: branch if less than unsigned
                    3'b111: actualBranchTaken <= !resultALU[0];    // BGEU: branch if greater or equal unsigned
                    default: actualBranchTaken <= 1'b0;
                endcase
                resolvedBranchType <= branchT;  // Store resolved branch type
            end
            
            // Set training signal during memory stage (one cycle after execute).
            if (isBranch && (currentPipelineStage == STAGE_MEMORY) && pipelineActive) begin
                branchResolved <= 1'b1;  // Enable branch predictor training
                resolvedPC <= programCounter;  // Store PC for training
                branchMispredicted <= (actualBranchTaken != branchWasTaken);  // Detect misprediction
            end
            
            // Handle jumps (always taken).
            if (isJump && (currentPipelineStage == STAGE_EXECUTE) && pipelineActive) begin
                actualBranchTaken <= 1'b1;  // Jumps are always taken
            end
        end
    end

    // ======================================================================
    // MAIN PROCESSOR CONTROL LOGIC
    // ======================================================================
    
    // Main state machine controlling processor operation and pipeline flow.
    always @(posedge clk) begin
        if (!reset) begin
            // Reset State - Initialize all processor state registers to safe default values.
            programCounter <= 32'h00001000;  // Start at typical RISC-V entry point
            instructionCounter <= 32'h0;     // No instructions executed yet
            cycleCounter <= 32'h0;           // No cycles elapsed yet
            branchCounter <= 32'h0;          // No branches encountered yet
            instructionCompleted <= 1'b0;    // No instruction completed
            requestInstruction <= 1'b0;      // No instruction request
            branchWasTaken <= 1'b0;          // No branch taken
            currentPipelineStage <= STAGE_IDLE;  // Start in idle state
            pipelineActive <= 1'b0;          // Pipeline not active
            branchResolved <= 1'b0;          // No branch resolved
            branchMispredicted <= 1'b0;      // No misprediction
        end else begin
            // Normal Operation - Increment cycle counter for performance tracking.
            cycleCounter <= cycleCounter + 1;
            instructionCompleted <= 1'b0;    // Default to no completion

            // Pipeline State Machine - Control the flow through different pipeline stages.
            case (currentPipelineStage)
                STAGE_IDLE: begin
                    // Wait for a valid instruction to start processing.
                    pipelineActive <= 1'b0;
                    requestInstruction <= 1'b1;  // Request next instruction
                    if (validInstruction && isVI) begin
                        // New valid instruction received, start processing.
                        pipelineActive <= 1'b1;
                        currentPipelineStage <= STAGE_FETCH;
                        requestInstruction <= 1'b0;
                    end
                end

                STAGE_FETCH: begin
                    // Instruction fetch stage - instruction is being fetched.
                    currentPipelineStage <= STAGE_DECODE;
                end

                STAGE_DECODE: begin
                    // Instruction decode stage - decoder breaks apart instruction.
                    // Register file reads source operands from the registers.
                    currentPipelineStage <= STAGE_EXECUTE;
                    
                    // For branch instructions, get prediction from branch predictor.
                    if (isBranch && predictionValid) begin
                        branchWasTaken <= predictTaken;  // Store prediction for later comparison
                    end
                end

                STAGE_EXECUTE: begin
                    // Execute stage - ALU performs computation or branch evaluation.
                    currentPipelineStage <= STAGE_MEMORY;
                    
                    // Update branch statistics if this is a branch instruction.
                    if (isBranch) begin
                        branchCounter <= branchCounter + 1;
                    end
                end

                STAGE_MEMORY: begin
                    // Memory access stage - handle memory operations if needed.
                    currentPipelineStage <= STAGE_WRITEBACK;
                end

                STAGE_WRITEBACK: begin
                    // Write back stage - store result back to register file.
                    currentPipelineStage <= STAGE_IDLE;
                    pipelineActive <= 1'b0;
                    instructionCompleted <= 1'b1;  // Signal instruction completion
                    instructionCounter <= instructionCounter + 1;  // Increment instruction count
                    
                    // Update program counter for next instruction.
                    if (isBranch && actualBranchTaken) begin
                        programCounter <= calculatedBranchTarget;  // Branch taken
                    end else if (isJump) begin
                        programCounter <= calculatedBranchTarget;  // Jump always taken
                    end else begin
                        programCounter <= programCounter + 4;  // Sequential execution
                    end
                end

                default: begin
                    // Safety fallback - return to idle state.
                    currentPipelineStage <= STAGE_IDLE;
                    pipelineActive <= 1'b0;
                end
            endcase
        end
    end

    // ======================================================================
    // MODULE INSTANTIATIONS
    // ======================================================================

    // Instruction Decoder - Decode RISC-V instructions into control signals and operands.
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
    
    // Register File - Manage register file operations and provide access statistics.
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

    // ALU - Perform arithmetic and logical operations with power monitoring.
    alu arithmeticUnit (
        .clk(clk),
        .reset(reset),
        .operandA(operandA),
        .operandB(operandB),
        .op(opALU),
        .enALU(enALU && pipelineActive && (currentPipelineStage == STAGE_EXECUTE) && !gateALU),
        .result(resultALU),
        .flagZero(flagZeroALU),
        .operationTotal(operationTotalALU),
        .operationMostUsed(operationMostUsedALU),
        .estimatedPower(estimatedPowerALU),
        .operationActive(operationActiveALU)
    );

    // Branch Predictor - Adaptive branch prediction with confidence tracking.
    branch_predictor branchPredictorUnit (
        .clk(clk),
        .reset(reset),
        .isBranch(isBranch && pipelineActive && (currentPipelineStage == STAGE_FETCH)),
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

    // Workload Classifier - Analyze instruction patterns to classify workload characteristics.
    workload_classifier classifierUnit (
        .clk(clk),
        .reset(reset),
        .instructionValid(pipelineActive && validInstruction && 
                         ((currentPipelineStage == STAGE_DECODE) || (currentPipelineStage == STAGE_EXECUTE))),
        .opcode(opcode),
        .fun3(fun3),
        .isBranch(isBranch),
        .branchTaken(actualBranchTaken),
        .resultALU(resultALU),
        .activeALU(operationActiveALU && (currentPipelineStage == STAGE_EXECUTE)),
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

    // Power Optimizer - Manage power consumption and optimize based on workload and constraints.
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
        .cacheHitRate(16'h8000),  // Simulated cache hit rate
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
        .powerGateCore(powerGateCoreInternal),  // FIX: Connect missing powerGateCore
        .thermalThrottle(thermalThrottling),
        .currentTotalPower(totalPower),
        .powerEfficiency(efficiency),
        .powerState(powerState),
        .temperatureEstimate(temperatureEstimateInternal),
        .energySaved(savedEnergy),
        .optimizationQuality(optimizationQuality),
        .predictedWorkloadFormat(predictedWorkloadFormat),
        .adaptationRate(optimizerAdaptationRate4bit),  // FIX: Use 4-bit signal
        .powerTrend(powerConsumptionTrend),
        .powerOptimizationActive(optimizationActive)
    );

    // ======================================================================
    // OUTPUT ASSIGNMENTS
    // ======================================================================

    // Processor Status Outputs
    assign requestNextInstruction = requestInstruction;           // Request next instruction
    assign instructionComplete = instructionCompleted;           // Instruction completion signal
    assign branchTaken = branchWasTaken;                        // Branch taken status
    assign branchTarget = calculatedBranchTarget;               // Branch target address

    // Performance Monitoring Outputs
    assign totalInstructions = instructionCounter;              // Total instructions executed
    assign totalCycles = cycleCounter;                          // Total cycles elapsed
    assign totalBranches = branchCounter;                       // Total branch instructions
    assign correctPredictions = correctPredictionsBP;          // Correct branch predictions
    assign branchAccuracy = accuracyPercent;                   // Branch prediction accuracy
    assign totalOperationsALU = operationTotalALU;             // Total ALU operations
    assign totalRegAccesses = regAccessCount;                  // Total register accesses

    // Workload Classification Outputs
    assign currentWorkloadFormat = workloadFormat;             // Current workload type
    assign workloadConfidence = classificationConfidence;      // Workload classification confidence
    assign computeToll = computeTollInternal;                  // Compute intensity metric
    assign memToll = memTollInternal;                          // Memory intensity metric
    assign controlToll = controlTollInternal;                  // Control flow intensity metric
    assign complexPattern = complexPatternInternal;            // Complexity pattern metric
    assign workloadClassificationValid = classificationValid; // Classification validity

    // Power Management Outputs
    assign currentPowerState = powerState;                     // Current power state
    assign clockFrequencyLevel = frequencyLevel;              // Clock frequency level
    assign voltageLevel = voltageLevelInternal;                // Voltage level
    assign currentTotalPower = totalPower;                    // Total power consumption
    assign powerEfficiency = efficiency;                       // Power efficiency
    assign temperatureEstimate = temperatureEstimateInternal; // Temperature estimate
    assign energySaved = savedEnergy;                         // Energy saved
    assign powerOptimizationActive = optimizationActive;      // Power optimization status
    assign thermalThrottle = thermalThrottling;               // Thermal throttling status
    assign optimizerAdaptationRate = {4'b0000, optimizerAdaptationRate4bit};  // Extend to 8 bits

    // Component Power Gating Status
    assign powerGateALU = gateALU;                            // ALU power gating status
    assign powerGateRegister = gateRegister;                  // Register power gating status
    assign powerGateBranchPredictor = gateBranchPredictor;    // Branch predictor power gating status
    assign powerGateCache = gateCache;                        // Cache power gating status

    // Debug and Monitoring Outputs
    assign rs1Debug = rs1;                                    // Source register 1 address
    assign rs2Debug = rs2;                                    // Source register 2 address
    assign rdDebug = rd;                                      // Destination register address
    assign rsData1Debug = rsData1;                            // Source register 1 data
    assign rsData2Debug = rsData2;                            // Source register 2 data
    assign resultALUDebug = resultALU;                        // ALU result value
    assign currentPC = programCounter;                        // Current program counter
    assign pipelineStage = currentPipelineStage;             // Current pipeline stage
    assign adaptationRate = (classifierAdaptationRate + optimizerAdaptationRate) / 2;  // Average adaptation rate
    assign powerTrend = powerConsumptionTrend;                // Power consumption trend

endmodule