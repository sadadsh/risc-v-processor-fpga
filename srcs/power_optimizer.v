`timescale 1ns / 1ps

// FIXED POWER OPTIMIZER - ELIMINATES COMBINATIONAL LOOPS
// Engineer: Sadad Haidari

module power_optimizer(
    input wire clk,
    input wire reset,

    // INPUTS
    // Workload Classification Inputs
    input wire [2:0] workloadFormat,
    input wire [3:0] workloadConfidence,
    input wire [7:0] computeToll,
    input wire [7:0] memToll,
    input wire [7:0] controlToll,
    input wire [7:0] complexPattern,
    input wire classificationValid,

    // Component Power Consumption Inputs
    input wire [7:0] powerALU,
    input wire [7:0] powerRegister,
    input wire [7:0] powerBranchPredictor,
    input wire [7:0] powerCache,
    input wire [7:0] powerCore,

    // Performance Metrics Inputs
    input wire [31:0] totalInstructions,
    input wire [31:0] totalCycles,
    input wire [7:0] branchAccuracy,
    input wire [15:0] cacheHitRate,
    input wire activeProcessor,

    // External Constraints
    input wire [7:0] powerBudget,
    input wire [7:0] thermalReading,
    input wire [7:0] batteryLevel,
    input wire performanceMode,

    // OUTPUTS
    output reg [2:0] clockFrequencyLevel,
    output reg [2:0] voltageLevel,
    output reg powerGateALU,
    output reg powerGateRegister,
    output reg powerGateBranchPredictor,
    output reg powerGateCache,
    output reg powerGateCore,
    output reg thermalThrottle,

    // Status Outputs
    output reg [7:0] currentTotalPower,
    output reg [7:0] powerEfficiency,
    output reg [2:0] powerState,
    output reg [7:0] temperatureEstimate,
    output reg [15:0] energySaved,
    output wire [7:0] optimizationQuality,

    // Predictive Optimization Outputs
    output reg [2:0] predictedWorkloadFormat,
    output reg [3:0] adaptationRate,
    output reg [7:0] powerTrend,
    output wire powerOptimizationActive
);

    // POWER MANAGEMENT STATES
    localparam POWERIDLE        = 3'b000;
    localparam POWERLOW         = 3'b001;
    localparam POWERBALANCED    = 3'b010;
    localparam POWERPERFORMANCE = 3'b011;
    localparam POWERBURST       = 3'b100;
    localparam POWERTHERMAL     = 3'b101;
    localparam POWERCRITICAL    = 3'b110;
    localparam POWERADAPTIVE    = 3'b111;

    // WORKLOAD FORMAT CONSTANTS
    localparam WLUNKNOWN        = 3'b000;
    localparam WLCOMPUTE        = 3'b001;
    localparam WLMEMORY         = 3'b010;
    localparam WLCONTROL        = 3'b011;
    localparam WLMIXED          = 3'b100;
    localparam WLIDLE           = 3'b101;
    localparam WLSTREAMING      = 3'b110;
    localparam WLIRREGULAR      = 3'b111;

    // OPTIMIZATION PARAMETERS
    localparam THERMALWARNING = 8'd150;
    localparam THERMALCRITICAL = 8'd180;
    localparam POWERBUDGETMARGIN = 8'd20;
    localparam EFFICIENCYTARGET = 8'd180;

    // INTERNAL STATE REGISTERS - ALL CLOCKED TO AVOID COMBINATIONAL LOOPS
    reg [7:0] totalPowerConsumption;
    reg [7:0] averagePowerConsumption;
    reg [15:0] powerHistory [0:15];
    reg [3:0] powerHistoryIndex;
    reg [31:0] cycleCounter;
    reg [7:0] thermalHistory [0:7];
    reg [2:0] thermalHistoryIndex;

    // WORKLOAD PREDICTION AND ADAPTATION
    reg [2:0] workloadHistory [0:15];
    reg [3:0] workloadHistoryIndex;
    reg [7:0] workloadStability;
    reg [7:0] learningRate;
    reg [31:0] adaptationCounter;

    // PERFORMANCE TRACKING
    reg [31:0] instructionsPC;
    reg [7:0] performanceScore;
    reg [31:0] previousInstructions;
    reg [31:0] previousCycles;

    // POWER GATING CONTROL
    reg [7:0] gatingTimer;
    reg [7:0] wakeupPrediction;
    reg powerGatingActive;

    // DVFS CONTROL REGISTERS
    reg [7:0] timerDVFS;
    reg [2:0] targetFrequencyLevel;
    reg [2:0] targetVoltageLevel;
    reg [7:0] transitionDelay;

    // PREDICTIVE OPTIMIZATION
    reg [7:0] workloadPredictionAccuracy;
    reg [7:0] powerPredictionError;
    reg [31:0] optimizationDecisions;

    // EFFICIENCY CALCULATION
    reg [15:0] efficiencyAccumulator;
    reg [7:0] efficiencyWindow;

    // EMERGENCY MANAGEMENT
    reg [3:0] emergencyLevel;
    reg [7:0] emergencyTimer;
    reg emergencyRecovery;

    // INTERMEDIATE CALCULATION REGISTERS - CLOCKED TO BREAK LOOPS
    reg [7:0] basePowerConsumption;
    reg [7:0] scaledPowerConsumption;
    reg [7:0] finalPowerConsumption;

    integer i;

    // INITIALIZATION
    initial begin
        powerState = POWERBALANCED;
        clockFrequencyLevel = 3'b011;
        voltageLevel = 3'b011;
        powerGateALU = 1'b0;
        powerGateRegister = 1'b0;
        powerGateBranchPredictor = 1'b0;
        powerGateCache = 1'b0;
        powerGateCore = 1'b0;
        thermalThrottle = 1'b0;

        currentTotalPower = 8'h50;  // Start with reasonable default
        powerEfficiency = 8'h80;
        temperatureEstimate = 8'd100;
        energySaved = 16'h0;

        predictedWorkloadFormat = WLUNKNOWN;
        adaptationRate = 4'h8;
        powerTrend = 8'h80;

        totalPowerConsumption = 8'h50;  // Initialize to avoid X states
        averagePowerConsumption = 8'h50;
        powerHistoryIndex = 4'h0;
        cycleCounter = 32'h0;
        thermalHistoryIndex = 3'h0;

        workloadHistoryIndex = 4'h0;
        workloadStability = 8'h80;
        learningRate = 8'h10;
        adaptationCounter = 32'h0;

        instructionsPC = 32'h0;
        performanceScore = 8'h80;
        previousInstructions = 32'h0;
        previousCycles = 32'h0;

        gatingTimer = 8'h0;
        wakeupPrediction = 8'h0;
        powerGatingActive = 1'b0;

        timerDVFS = 8'h0;
        targetFrequencyLevel = 3'b011;
        targetVoltageLevel = 3'b011;
        transitionDelay = 8'h0;

        workloadPredictionAccuracy = 8'h80;
        powerPredictionError = 8'h0;
        optimizationDecisions = 32'h0;

        efficiencyAccumulator = 16'h0;
        efficiencyWindow = 8'h0;

        emergencyLevel = 4'h0;
        emergencyTimer = 8'h0;
        emergencyRecovery = 1'b0;

        // Initialize intermediate calculation registers
        basePowerConsumption = 8'h50;
        scaledPowerConsumption = 8'h50;
        finalPowerConsumption = 8'h50;

        // Initialize Arrays
        for (i = 0; i < 16; i = i + 1) begin
            powerHistory[i] = 16'h0050;  // Initialize with reasonable default
            workloadHistory[i] = 3'h0;
        end
        
        for (i = 0; i < 8; i = i + 1) begin
            thermalHistory[i] = 8'd100;
        end
    end

    // COMBINATIONAL LOGIC - BROKEN INTO SEPARATE NON-FEEDBACK BLOCKS

    // WORKLOAD PREDICTION (Pure combinational, no feedback)
    always @(*) begin
        if (workloadHistoryIndex >= 4) begin
            if (workloadHistory[(workloadHistoryIndex - 1) % 16] ==
                workloadHistory[(workloadHistoryIndex - 3) % 16]) begin
                predictedWorkloadFormat = workloadHistory[(workloadHistoryIndex - 2) % 16];
            end 
            else if (workloadHistory[(workloadHistoryIndex - 1) % 16] ==
                     workloadHistory[(workloadHistoryIndex - 2) % 16]) begin
                predictedWorkloadFormat = workloadHistory[(workloadHistoryIndex - 1) % 16];
            end 
            else begin
                predictedWorkloadFormat = workloadFormat;
            end
        end else begin
            predictedWorkloadFormat = workloadFormat;
        end
    end

    // MAIN SEQUENTIAL LOGIC - ALL CALCULATIONS MOVED HERE TO AVOID LOOPS
    always @(posedge clk) begin
        if (!reset) begin
            // Reset all registers
            powerState <= POWERBALANCED;
            clockFrequencyLevel <= 3'b011;
            voltageLevel <= 3'b011;
            powerGateALU <= 1'b0;
            powerGateRegister <= 1'b0;
            powerGateBranchPredictor <= 1'b0;
            powerGateCache <= 1'b0;
            powerGateCore <= 1'b0;
            thermalThrottle <= 1'b0;

            currentTotalPower <= 8'h50;
            powerEfficiency <= 8'h80;
            temperatureEstimate <= 8'd100;
            energySaved <= 16'h0;

            adaptationRate <= 4'h8;
            powerTrend <= 8'h80;

            totalPowerConsumption <= 8'h50;
            averagePowerConsumption <= 8'h50;
            powerHistoryIndex <= 4'h0;
            cycleCounter <= 32'h0;
            thermalHistoryIndex <= 3'h0;

            workloadHistoryIndex <= 4'h0;
            workloadStability <= 8'h80;
            learningRate <= 8'h10;
            adaptationCounter <= 32'h0;

            instructionsPC <= 32'h0;
            performanceScore <= 8'h80;
            previousInstructions <= 32'h0;
            previousCycles <= 32'h0;

            gatingTimer <= 8'h0;
            wakeupPrediction <= 8'h0;
            powerGatingActive <= 1'b0;

            timerDVFS <= 8'h0;
            targetFrequencyLevel <= 3'b011;
            targetVoltageLevel <= 3'b011;
            transitionDelay <= 8'h0;

            workloadPredictionAccuracy <= 8'h80;
            powerPredictionError <= 8'h0;
            optimizationDecisions <= 32'h0;

            efficiencyAccumulator <= 16'h0;
            efficiencyWindow <= 8'h0;

            emergencyLevel <= 4'h0;
            emergencyTimer <= 8'h0;
            emergencyRecovery <= 1'b0;

            basePowerConsumption <= 8'h50;
            scaledPowerConsumption <= 8'h50;
            finalPowerConsumption <= 8'h50;

            // Initialize Arrays
            for (i = 0; i < 16; i = i + 1) begin
                powerHistory[i] <= 16'h0050;
                workloadHistory[i] <= 3'h0;
            end
            
            for (i = 0; i < 8; i = i + 1) begin
                thermalHistory[i] <= 8'd100;
            end
        end else begin
            // Increment counters
            cycleCounter <= cycleCounter + 1;
            adaptationCounter <= adaptationCounter + 1;

            // STEP 1: Calculate base power consumption (component sum)
            basePowerConsumption <= powerALU + powerRegister + powerBranchPredictor + powerCache + powerCore;

            // STEP 2: Add state-based power overhead
            case (powerState)
                POWERIDLE:        scaledPowerConsumption <= basePowerConsumption + 8'd5;
                POWERLOW:         scaledPowerConsumption <= basePowerConsumption + 8'd10;
                POWERBALANCED:    scaledPowerConsumption <= basePowerConsumption + 8'd15;
                POWERPERFORMANCE: scaledPowerConsumption <= basePowerConsumption + 8'd25;
                POWERBURST:       scaledPowerConsumption <= basePowerConsumption + 8'd35;
                default:          scaledPowerConsumption <= basePowerConsumption + 8'd20;
            endcase

            // STEP 3: Apply DVFS scaling
            case (clockFrequencyLevel)
                3'b000: finalPowerConsumption <= (scaledPowerConsumption * 30) / 100;
                3'b001: finalPowerConsumption <= (scaledPowerConsumption * 45) / 100;
                3'b010: finalPowerConsumption <= (scaledPowerConsumption * 60) / 100;
                3'b011: finalPowerConsumption <= (scaledPowerConsumption * 80) / 100;
                3'b100: finalPowerConsumption <= scaledPowerConsumption;
                3'b101: finalPowerConsumption <= (scaledPowerConsumption * 120) / 100;
                3'b110: finalPowerConsumption <= (scaledPowerConsumption * 145) / 100;
                3'b111: finalPowerConsumption <= (scaledPowerConsumption * 175) / 100;
            endcase

            // STEP 4: Apply power gating savings
            totalPowerConsumption <= finalPowerConsumption;
            if (powerGateALU && finalPowerConsumption >= 8'd15) 
                totalPowerConsumption <= finalPowerConsumption - 8'd15;
            if (powerGateRegister && totalPowerConsumption >= 8'd8) 
                totalPowerConsumption <= totalPowerConsumption - 8'd8;
            if (powerGateBranchPredictor && totalPowerConsumption >= 8'd5) 
                totalPowerConsumption <= totalPowerConsumption - 8'd5;
            if (powerGateCache && totalPowerConsumption >= 8'd12) 
                totalPowerConsumption <= totalPowerConsumption - 8'd12;

            // STEP 5: Update current total power output
            currentTotalPower <= totalPowerConsumption;

            // STEP 6: Calculate temperature estimate
            temperatureEstimate <= 8'd80 + (totalPowerConsumption / 3) + (thermalReading / 4);
            if (thermalThrottle) begin
                temperatureEstimate <= temperatureEstimate - 8'd20;
            end
            if (thermalReading > 8'd100) begin
                temperatureEstimate <= temperatureEstimate + 8'd15;
            end else if (thermalReading < 8'd100) begin
                temperatureEstimate <= temperatureEstimate - 8'd10;
            end
            if (temperatureEstimate > 8'd255) 
                temperatureEstimate <= 8'd255;

            // STEP 7: Calculate efficiency
            if (totalPowerConsumption > 8'd10 && totalCycles > previousCycles && totalInstructions > previousInstructions) begin
                instructionsPC <= ((totalInstructions - previousInstructions) * 1000) / (totalCycles - previousCycles);
                if (instructionsPC > 0) begin
                    powerEfficiency <= (instructionsPC[9:0] * 10) / totalPowerConsumption;
                    if (powerEfficiency > 8'd255) 
                        powerEfficiency <= 8'd255;
                end else begin
                    powerEfficiency <= 8'd1;
                end
            end else begin
                powerEfficiency <= 8'd50;
            end

            // STEP 8: Determine power state based on current conditions
            if (emergencyLevel > 0) begin
                powerState <= POWERCRITICAL;
            end else if (!activeProcessor) begin
                powerState <= POWERIDLE;
            end else if (totalPowerConsumption < 8'd40) begin
                powerState <= POWERLOW;
            end else if (totalPowerConsumption < 8'd100) begin
                powerState <= POWERBALANCED;
            end else if (totalPowerConsumption < 8'd150) begin
                powerState <= POWERPERFORMANCE;
            end else begin
                powerState <= POWERBURST;
            end

            // History and adaptation logic (every 16 cycles)
            if (cycleCounter[3:0] === 4'h0) begin
                powerHistory[powerHistoryIndex] <= {8'h0, totalPowerConsumption};
                powerHistoryIndex <= (powerHistoryIndex + 1) % 16;

                if (classificationValid) begin
                    workloadHistory[workloadHistoryIndex] <= workloadFormat;
                    workloadHistoryIndex <= (workloadHistoryIndex + 1) % 16;
                end

                thermalHistory[thermalHistoryIndex] <= thermalReading;
                thermalHistoryIndex <= (thermalHistoryIndex + 1) % 8;
            end
            
            // Moving averages (every 32 cycles)
            if (cycleCounter[4:0] == 5'h0) begin
                averagePowerConsumption <= (powerHistory[0][7:0] + powerHistory[1][7:0] +
                                            powerHistory[2][7:0] + powerHistory[3][7:0] +
                                            powerHistory[4][7:0] + powerHistory[5][7:0] +
                                            powerHistory[6][7:0] + powerHistory[7][7:0]) / 8;
                previousInstructions <= totalInstructions;
                previousCycles <= totalCycles;
            end

            // Emergency management
            if (temperatureEstimate > THERMALCRITICAL || totalPowerConsumption > (powerBudget + POWERBUDGETMARGIN)) begin
                emergencyLevel <= 4'hF;
                emergencyTimer <= 8'hFF;
                thermalThrottle <= 1'b1;
                clockFrequencyLevel <= 3'b000;
                voltageLevel <= 3'b000;
                powerGateALU <= !activeProcessor;
                powerGateCache <= 1'b1;
                powerGateBranchPredictor <= 1'b1;
            end else if (emergencyLevel > 0) begin
                emergencyLevel <= emergencyLevel - 1;
                emergencyTimer <= emergencyTimer - 1;
                emergencyRecovery <= 1'b1;
                if (emergencyLevel == 1) begin
                    emergencyRecovery <= 1'b0;
                end
            end else begin
                // Normal operation
                emergencyRecovery <= 1'b0;
                
                // Thermal management
                if (temperatureEstimate > THERMALWARNING) begin
                    thermalThrottle <= 1'b1;
                    if (clockFrequencyLevel > 3'b001) begin
                        clockFrequencyLevel <= clockFrequencyLevel - 1;
                        voltageLevel <= voltageLevel - 1;
                    end
                end else if (temperatureEstimate < (THERMALWARNING - 8'd30)) begin
                    thermalThrottle <= 1'b0;
                end

                // Workload-aware power management
                if (classificationValid && workloadConfidence >= 4'h6) begin
                    case (workloadFormat)
                        WLIDLE: begin
                            targetFrequencyLevel <= 3'b001;
                            targetVoltageLevel <= 3'b001;
                            if (!activeProcessor) begin
                                powerGateALU <= 1'b1;
                                powerGateCache <= 1'b1;
                                powerGateBranchPredictor <= 1'b1;
                            end
                        end
                        WLCOMPUTE: begin
                            if (performanceMode) begin
                                targetFrequencyLevel <= 3'b110;
                                targetVoltageLevel <= 3'b110;
                            end else begin
                                targetFrequencyLevel <= 3'b100;
                                targetVoltageLevel <= 3'b100;
                            end
                            powerGateALU <= 1'b0;
                            powerGateCache <= 1'b0;
                        end
                        WLMEMORY: begin
                            targetFrequencyLevel <= 3'b011;
                            targetVoltageLevel <= 3'b011;
                            powerGateBranchPredictor <= 1'b0;
                            powerGateALU <= !activeProcessor;
                        end
                        WLMIXED: begin
                            targetFrequencyLevel <= 3'b011;
                            targetVoltageLevel <= 3'b011;
                            powerGateALU <= 1'b0;
                            powerGateCache <= 1'b0;
                        end
                        WLSTREAMING: begin
                            targetFrequencyLevel <= 3'b100;
                            targetVoltageLevel <= 3'b100;
                            powerGateCache <= 1'b0;
                            powerGateALU <= !activeProcessor;
                        end
                        default: begin
                            targetFrequencyLevel <= 3'b011;
                            targetVoltageLevel <= 3'b011;
                        end
                    endcase
                end

                // DVFS transitions
                timerDVFS <= timerDVFS + 1;
                if (timerDVFS[2:0] == 3'h0 && transitionDelay == 0) begin
                    if (clockFrequencyLevel < targetFrequencyLevel && !thermalThrottle) begin
                        clockFrequencyLevel <= clockFrequencyLevel + 1;
                        voltageLevel <= voltageLevel + 1;
                        transitionDelay <= 8'h4;
                    end else if (clockFrequencyLevel > targetFrequencyLevel) begin
                        clockFrequencyLevel <= clockFrequencyLevel - 1;
                        voltageLevel <= voltageLevel - 1;
                        transitionDelay <= 8'h4;
                    end
                end
                
                if (transitionDelay > 0) begin
                    transitionDelay <= transitionDelay - 1;
                end

                // Power budget management
                if (totalPowerConsumption > powerBudget) begin
                    if (clockFrequencyLevel > 3'b000) begin
                        targetFrequencyLevel <= clockFrequencyLevel - 1;
                        targetVoltageLevel <= voltageLevel - 1;
                    end
                    if (!activeProcessor) begin
                        powerGateALU <= 1'b1;
                        powerGateCache <= 1'b1;
                    end
                end

                // Adaptive learning (every 32 cycles)
                if (adaptationCounter[4:0] == 5'h0) begin
                    if (workloadPredictionAccuracy > 8'd200) begin
                        learningRate <= (learningRate > 8'h04) ? learningRate - 8'h04 : 8'h04;
                    end else if (workloadPredictionAccuracy < 8'd100) begin
                        learningRate <= (learningRate < 8'h20) ? learningRate + 8'h04 : 8'h20;
                    end
                    adaptationRate <= (learningRate >> 1) & 4'hF;
                    
                    if (averagePowerConsumption > 0) begin
                        energySaved <= energySaved + (averagePowerConsumption - totalPowerConsumption);
                    end
                end

                optimizationDecisions <= optimizationDecisions + 1;
            end

            // Predictive wake-up for power gating
            gatingTimer <= gatingTimer + 1;
            if (gatingTimer[3:0] == 4'h0) begin
                case (predictedWorkloadFormat)
                    WLCOMPUTE: wakeupPrediction <= 8'h08;
                    WLMEMORY: wakeupPrediction <= 8'h10;
                    WLCONTROL: wakeupPrediction <= 8'h06;
                    default: wakeupPrediction <= 8'h20;
                endcase

                if (wakeupPrediction <= 8'h04) begin
                    powerGateALU <= 1'b0;
                    powerGateCache <= 1'b0;
                    powerGateBranchPredictor <= 1'b0;
                end

                if (wakeupPrediction > 0) 
                    wakeupPrediction <= wakeupPrediction - 1;
            end

            // Power trend analysis (every 128 cycles)
            if (cycleCounter[6:0] == 7'h0) begin
                if (totalPowerConsumption > averagePowerConsumption + 8'h10) begin
                    powerTrend <= (powerTrend < 8'd240) ? powerTrend + 8'h10 : 8'd255;
                end else if (totalPowerConsumption < averagePowerConsumption - 8'h10) begin
                    powerTrend <= (powerTrend > 8'h10) ? powerTrend - 8'h10 : 8'h00;
                end else begin
                    powerTrend <= 8'h80;
                end
            end
        end
    end

    // OUTPUT ASSIGNMENTS
    assign optimizationQuality = (powerEfficiency > EFFICIENCYTARGET) ?
                                  8'd255 : (powerEfficiency * 255) / EFFICIENCYTARGET;
    assign powerOptimizationActive = (powerState != POWERCRITICAL) &&
                                    (emergencyLevel == 0) && classificationValid;

endmodule