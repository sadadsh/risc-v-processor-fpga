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
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] fun3;
    wire [6:0] fun7;
    wire [31:0] immediateValue;
    wire enRegWrite, enALU, useImmediate;
    wire [3:0] opALU;
    wire isBranch, isJump;
    wire [2:0] branchT;
    wire staticBranchTaken;
    wire isRT, isIT, isBT, isJT, isVI;

    // Register File Signals
    wire [31:0] rsData1, rsData2;
    wire [31:0] regAccessCount, regWriteCount;
    wire [4:0] regMostUsed;
    wire regPowerActive;

    // ALU Signals
    wire [31:0] resultALU;
    wire flagZeroALU;
    wire [31:0] operationTotalALU;
    wire [4:0] operationMostUsedALU;
    wire [7:0] estimatedPowerALU;
    wire operationActiveALU;

    // Branch Predictor Signals
    wire predictTaken;
    wire [3:0] predictionConfidence;
    wire predictionValid;
    wire [15:0] totalPredictions, correctPredictionsBP;
    wire [7:0] accuracyPercent;

    // Workload Classifier Signals
    wire [2:0] workloadFormat;
    wire [3:0] classificationConfidence;
    wire [7:0] computeTollInternal, memTollInternal, controlTollInternal, complexPatternInternal;
    wire [15:0] classificationCount;
    wire [7:0] classifierAdaptationRate;
    wire classificationValid;

    // Power Optimizer Signals
    wire [2:0] powerState;
    wire [2:0] frequencyLevel, voltageLevelInternal;
    wire [7:0] totalPower, efficiency, temperatureEstimateInternal;
    wire [15:0] savedEnergy;
    wire [7:0] optimizationQuality;
    wire [2:0] predictedWorkloadFormat;
    wire [3:0] optimizerAdaptationRate;
    wire [7:0] powerConsumptionTrend;
    wire optimizationActive;
    wire thermalThrottling;
    wire gateALU, gateRegister, gateBranchPredictor, gateCache;

    // PROCESSOR CONTROL AND STATE REGISTERS
    reg [31:0] programCounter;
    reg [31:0] instructionCounter;
    reg [31:0] cycleCounter;
    reg [31:0] branchCounter;
    reg instructionCompleted;
    reg requestInstruction;
    reg branchWasTaken;
    reg [31:0] calculatedBranchTarget;

    // PIPELINE STATE MANAGEMENT
    reg [2:0] currentPipelineStage;
    reg pipelineActive;

    // BRANCH RESOLUTION AND CONTROL FLOW
    reg branchResolved;
    reg actualBranchTaken;
    reg [31:0] resolvedPC;
    reg branchMispredicted;
    reg [2:0] resolvedBranchType;

    // PERFORMANCE TRACKING
    reg [31:0] previousInstructions;
    reg [31:0] previousCycles;

    // POWER MANAGEMENT INTERFACE
    reg [7:0] componentPowerALU;
    reg [7:0] componentPowerRegister;
    reg [7:0] componentPowerBranchPredictor;
    reg [7:0] componentPowerCache;
    reg [7:0] componentPowerCore;

    // PIPELINE STAGES
    localparam STAGEIDLE         = 3'b000;
    localparam STAGEFETCH        = 3'b001;
    localparam STAGEDECODE       = 3'b010;
    localparam STAGEEXECUTE      = 3'b011;
    localparam STAGEMEMORY       = 3'b100;
    localparam STAGEWRITEBACK    = 3'b101;

    // ALU OPERAND SELECTION
    wire [31:0] operandA, operandB;
    assign operandA = rsData1;
    assign operandB = useImmediate ? immediateValue : rsData2;

    // REGISTER WRITE CONTROL
    wire regWriteEnable;
    assign regWriteEnable = enRegWrite && pipelineActive &&
                            (currentPipelineStage == STAGEWRITEBACK) && !gateRegister;

    // POWER CONSUMPTION MODELING
    always @(*) begin
        componentPowerALU = gateALU ? 8'h02 : 
                        (operationActiveALU ? 8'h40 : 8'h18);
        
        componentPowerRegister = gateRegister ? 8'h01 : 
                                (regPowerActive ? 8'h25 : 8'h12);
        
        componentPowerBranchPredictor = gateBranchPredictor ? 8'h01 : 
                                    (isBranch ? 8'h15 : 8'h08);
        
        componentPowerCache = gateCache ? 8'h02 : 
                            (pipelineActive ? 8'h30 : 8'h15);
        
        componentPowerCore = pipelineActive ? 8'h25 : 8'h10;
    end

    // BRANCH TARGET CALCULATION
    always @(*) begin
        if (isBranch || isJump) begin
            calculatedBranchTarget = programCounter + immediateValue;
        end else begin
            calculatedBranchTarget = programCounter + 4;
        end
    end

    // BRANCH OUTCOME DETERMINATION AND TRAINING
    always @(posedge clk) begin
        if (!reset) begin
            branchResolved <= 1'b0;
            actualBranchTaken <= 1'b0;
            branchMispredicted <= 1'b0;
            resolvedBranchType <= 3'b000;
        end else begin
            branchResolved <= 1'b0; // Default
            
            // Branch resolution during execute stage
            if (isBranch && (currentPipelineStage == STAGEEXECUTE) && pipelineActive) begin
                case (branchT)
                    3'b000: actualBranchTaken <= flagZeroALU;      // BEQ
                    3'b001: actualBranchTaken <= !flagZeroALU;     // BNE
                    3'b100: actualBranchTaken <= resultALU[0];     // BLT
                    3'b101: actualBranchTaken <= !resultALU[0];    // BGE
                    3'b110: actualBranchTaken <= resultALU[0];     // BLTU
                    3'b111: actualBranchTaken <= !resultALU[0];    // BGEU
                    default: actualBranchTaken <= 1'b0;
                endcase
                resolvedBranchType <= branchT;
            end
            
            // Set training signal during memory stage (one cycle after execute).
            if (isBranch && (currentPipelineStage == STAGEMEMORY) && pipelineActive) begin
                branchResolved <= 1'b1;  // Enable training
                resolvedPC <= programCounter;
                branchMispredicted <= (actualBranchTaken != branchWasTaken);
            end
            
            // Handle jumps (always taken)
            if (isJump && (currentPipelineStage == STAGEEXECUTE) && pipelineActive) begin
                actualBranchTaken <= 1'b1;
            end
        end
    end

    // MODULE INSTANTIATIONS

    // Instruction Decoder
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

    // Branch Predictor with proper training signals.
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

    // Workload Classifier with proper instruction signals.
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
        .powerOptimizationActive(optimizationActive)
    );

    // MAIN PROCESSOR CONTROL LOGIC
    always @(posedge clk) begin
        if (!reset) begin
            // Reset State
            programCounter <= 32'h00001000;
            instructionCounter <= 32'h0;
            cycleCounter <= 32'h0;
            branchCounter <= 32'h0;
            instructionCompleted <= 1'b0;
            requestInstruction <= 1'b0;
            branchWasTaken <= 1'b0;
            currentPipelineStage <= STAGEIDLE;
            pipelineActive <= 1'b0;
            branchResolved <= 1'b0;
            branchMispredicted <= 1'b0;
        end else begin
            // Increment cycle counter
            cycleCounter <= cycleCounter + 1;
            
            // Default values
            instructionCompleted <= 1'b0;
            
            // Pipeline State Machine
            case (currentPipelineStage)
                STAGEIDLE: begin
                    requestInstruction <= 1'b1;
                    
                    if (validInstruction && isVI) begin
                        pipelineActive <= 1'b1;
                        currentPipelineStage <= STAGEFETCH;
                        requestInstruction <= 1'b0;
                    end
                end
                
                STAGEFETCH: begin
                    // Branch prediction happens here with proper signals.
                    if (isBranch || isJump) begin
                        branchCounter <= branchCounter + 1;
                        branchWasTaken <= predictTaken; // Use dynamic prediction.
                    end
                    currentPipelineStage <= STAGEDECODE;
                end
                
                STAGEDECODE: begin
                    // Decoding happens combinationally
                    currentPipelineStage <= STAGEEXECUTE;
                end
                
                STAGEEXECUTE: begin
                    // ALU operations and branch resolution happen here
                    currentPipelineStage <= STAGEMEMORY;
                end
                
                STAGEMEMORY: begin
                    // Memory operations and branch training happen here
                    currentPipelineStage <= STAGEWRITEBACK;
                end
                
                STAGEWRITEBACK: begin
                    instructionCompleted <= 1'b1;
                    instructionCounter <= instructionCounter + 1;
                    
                    // Update program counter
                    if ((isBranch && actualBranchTaken) || isJump) begin
                        programCounter <= calculatedBranchTarget;
                    end else begin
                        programCounter <= programCounter + 4;
                    end
                    
                    // Check for next instruction
                    if (validInstruction && isVI) begin
                        currentPipelineStage <= STAGEFETCH;
                    end else begin
                        pipelineActive <= 1'b0;
                        currentPipelineStage <= STAGEIDLE;
                    end
                end
                
                default: begin
                    currentPipelineStage <= STAGEIDLE;
                    pipelineActive <= 1'b0;
                end
            endcase

            // Performance tracking
            if (cycleCounter[7:0] == 8'h0) begin
                previousInstructions <= instructionCounter;
                previousCycles <= cycleCounter;
            end
        end
    end
    
    // OUTPUT ASSIGNMENTS
    assign instructionComplete = instructionCompleted;
    assign requestNextInstruction = requestInstruction;
    assign branchTaken = branchWasTaken && instructionCompleted;
    assign branchTarget = calculatedBranchTarget;

    // Performance Monitoring
    assign totalInstructions = instructionCounter;
    assign totalCycles = cycleCounter;
    assign totalBranches = branchCounter;
    assign correctPredictions = correctPredictionsBP;
    assign branchAccuracy = accuracyPercent;
    assign totalOperationsALU = operationTotalALU;
    assign totalRegAccesses = regAccessCount;

    // Workload Classification
    assign currentWorkloadFormat = workloadFormat;
    assign workloadConfidence = classificationConfidence;
    assign computeToll = computeTollInternal;
    assign memToll = memTollInternal;
    assign controlToll = controlTollInternal;
    assign complexPattern = complexPatternInternal;
    assign workloadClassificationValid = classificationValid;

    // Power Management
    assign currentPowerState = powerState;
    assign clockFrequencyLevel = frequencyLevel;
    assign voltageLevel = voltageLevelInternal;
    assign currentTotalPower = totalPower;
    assign powerEfficiency = efficiency;
    assign temperatureEstimate = temperatureEstimateInternal;
    assign energySaved = savedEnergy;
    assign powerOptimizationActive = optimizationActive;
    assign thermalThrottle = thermalThrottling;

    // Power Gating Status
    assign powerGateALU = gateALU;
    assign powerGateRegister = gateRegister;
    assign powerGateBranchPredictor = gateBranchPredictor;
    assign powerGateCache = gateCache;

    // Debug and Monitoring
    assign rs1Debug = rs1;
    assign rs2Debug = rs2;
    assign rdDebug = rd;
    assign rsData1Debug = rsData1;
    assign rsData2Debug = rsData2;
    assign resultALUDebug = resultALU;
    assign currentPC = programCounter;
    assign pipelineStage = currentPipelineStage;
    assign adaptationRate = (classifierAdaptationRate + optimizerAdaptationRate) / 2;
    assign powerTrend = powerConsumptionTrend;

endmodule