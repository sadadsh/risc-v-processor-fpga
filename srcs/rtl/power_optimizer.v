`timescale 1ns / 1ps

// POWER OPTIMIZER
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
    // These states define different operating modes for power management
    localparam POWERIDLE        = 3'b000;  // Processor is idle, minimal power consumption
    localparam POWERLOW         = 3'b001;  // Low power mode for light workloads
    localparam POWERBALANCED    = 3'b010;  // Balanced performance and power consumption
    localparam POWERPERFORMANCE = 3'b011;  // Performance oriented mode
    localparam POWERBURST       = 3'b100;  // Maximum performance mode
    localparam POWERTHERMAL     = 3'b101;  // Thermal throttling mode
    localparam POWERCRITICAL    = 3'b110;  // Critical emergency mode
    localparam POWERADAPTIVE    = 3'b111;  // Adaptive learning mode

    // WORKLOAD FORMAT CONSTANTS
    // These constants identify different types of workload patterns
    localparam WLUNKNOWN        = 3'b000;  // Unknown or unclassified workload
    localparam WLCOMPUTE        = 3'b001;  // Compute intensive workload
    localparam WLMEMORY         = 3'b010;  // Memory intensive workload
    localparam WLCONTROL        = 3'b011;  // Control flow intensive workload
    localparam WLMIXED          = 3'b100;  // Mixed workload characteristics
    localparam WLIDLE           = 3'b101;  // Idle or very light workload
    localparam WLSTREAMING      = 3'b110;  // Streaming data workload
    localparam WLIRREGULAR      = 3'b111;  // Irregular or unpredictable workload

    // OPTIMIZATION PARAMETERS
    // Threshold values for thermal and power management decisions
    localparam THERMALWARNING = 8'd150;    // Temperature threshold for warning state
    localparam THERMALCRITICAL = 8'd180;   // Temperature threshold for critical state
    localparam POWERBUDGETMARGIN = 8'd20;  // Safety margin for power budget
    localparam EFFICIENCYTARGET = 8'd180;  // Target efficiency value

    // INTERNAL STATE REGISTERS
    // All registers are clocked to avoid combinational feedback loops
    reg [7:0] totalPowerConsumption;       // Current total power consumption
    reg [7:0] averagePowerConsumption;     // Moving average of power consumption
    reg [15:0] powerHistory [0:15];        // Circular buffer for power history
    reg [3:0] powerHistoryIndex;           // Index for power history buffer
    reg [31:0] cycleCounter;               // Global cycle counter
    reg [7:0] thermalHistory [0:7];        // Circular buffer for thermal history
    reg [2:0] thermalHistoryIndex;         // Index for thermal history buffer

    // WORKLOAD PREDICTION AND ADAPTATION
    // Registers for workload prediction and learning algorithms
    reg [2:0] workloadHistory [0:15];      // Circular buffer for workload history
    reg [3:0] workloadHistoryIndex;        // Index for workload history buffer
    reg [7:0] workloadStability;           // Measure of workload pattern stability
    reg [7:0] learningRate;                // Adaptive learning rate
    reg [31:0] adaptationCounter;          // Counter for adaptation timing

    // PERFORMANCE TRACKING
    // Registers for monitoring performance metrics
    reg [31:0] instructionsPC;             // Instructions per cycle calculation
    reg [7:0] performanceScore;            // Overall performance score
    reg [31:0] previousInstructions;       // Previous instruction count
    reg [31:0] previousCycles;             // Previous cycle count

    // POWER GATING CONTROL
    // Registers for managing power gating decisions
    reg [7:0] gatingTimer;                 // Timer for power gating decisions
    reg [7:0] wakeupPrediction;            // Predicted wakeup time
    reg powerGatingActive;                 // Power gating status flag

    // DVFS CONTROL REGISTERS
    // Registers for Dynamic Voltage and Frequency Scaling
    reg [7:0] timerDVFS;                   // Timer for DVFS transitions
    reg [2:0] targetFrequencyLevel;        // Target frequency level
    reg [2:0] targetVoltageLevel;          // Target voltage level
    reg [7:0] transitionDelay;             // Delay for smooth transitions

    // PREDICTIVE OPTIMIZATION
    // Registers for predictive optimization algorithms
    reg [7:0] workloadPredictionAccuracy;  // Accuracy of workload predictions
    reg [7:0] powerPredictionError;        // Error in power consumption predictions
    reg [31:0] optimizationDecisions;      // Counter for optimization decisions

    // EFFICIENCY CALCULATION
    // Registers for efficiency calculations
    reg [15:0] efficiencyAccumulator;      // Accumulator for efficiency calculations
    reg [7:0] efficiencyWindow;            // Window size for efficiency averaging

    // EMERGENCY MANAGEMENT
    // Registers for handling emergency conditions
    reg [3:0] emergencyLevel;              // Current emergency level
    reg [7:0] emergencyTimer;              // Timer for emergency recovery
    reg emergencyRecovery;                 // Emergency recovery status

    // INTERMEDIATE CALCULATION REGISTERS
    // Clocked registers to break combinational feedback loops
    reg [7:0] basePowerConsumption;        // Base power without scaling
    reg [7:0] scaledPowerConsumption;      // Power after state scaling
    reg [7:0] finalPowerConsumption;       // Final power after all adjustments

    integer i;  // Loop variable for array initialization

    // INITIALIZATION
    // Set all registers to safe default values on startup
    initial begin
        // Initialize power management outputs
        powerState = POWERBALANCED;
        clockFrequencyLevel = 3'b011;
        voltageLevel = 3'b011;
        powerGateALU = 1'b0;
        powerGateRegister = 1'b0;
        powerGateBranchPredictor = 1'b0;
        powerGateCache = 1'b0;
        powerGateCore = 1'b0;
        thermalThrottle = 1'b0;

        // Initialize status outputs with reasonable defaults
        currentTotalPower = 8'h50;  // Start with moderate power consumption
        powerEfficiency = 8'h80;    // Start with good efficiency
        temperatureEstimate = 8'd100;  // Start with normal temperature
        energySaved = 16'h0;        // No energy saved initially

        // Initialize predictive optimization outputs
        predictedWorkloadFormat = WLUNKNOWN;
        adaptationRate = 4'h8;
        powerTrend = 8'h80;

        // Initialize internal state registers
        totalPowerConsumption = 8'h50;
        averagePowerConsumption = 8'h50;
        powerHistoryIndex = 4'h0;
        cycleCounter = 32'h0;
        thermalHistoryIndex = 3'h0;

        // Initialize workload prediction registers
        workloadHistoryIndex = 4'h0;
        workloadStability = 8'h80;
        learningRate = 8'h10;
        adaptationCounter = 32'h0;

        // Initialize performance tracking registers
        instructionsPC = 32'h0;
        performanceScore = 8'h80;
        previousInstructions = 32'h0;
        previousCycles = 32'h0;

        // Initialize power gating control registers
        gatingTimer = 8'h0;
        wakeupPrediction = 8'h0;
        powerGatingActive = 1'b0;

        // Initialize DVFS control registers
        timerDVFS = 8'h0;
        targetFrequencyLevel = 3'b011;
        targetVoltageLevel = 3'b011;
        transitionDelay = 8'h0;

        // Initialize predictive optimization registers
        workloadPredictionAccuracy = 8'h80;
        powerPredictionError = 8'h0;
        optimizationDecisions = 32'h0;

        // Initialize efficiency calculation registers
        efficiencyAccumulator = 16'h0;
        efficiencyWindow = 8'h0;

        // Initialize emergency management registers
        emergencyLevel = 4'h0;
        emergencyTimer = 8'h0;
        emergencyRecovery = 1'b0;

        // Initialize intermediate calculation registers
        basePowerConsumption = 8'h50;
        scaledPowerConsumption = 8'h50;
        finalPowerConsumption = 8'h50;

        // Initialize power history array with reasonable defaults
        for (i = 0; i < 16; i = i + 1) begin
            powerHistory[i] = 16'h0050;
            workloadHistory[i] = 3'h0;
        end
        
        // Initialize thermal history array with normal temperature
        for (i = 0; i < 8; i = i + 1) begin
            thermalHistory[i] = 8'd100;
        end
    end

    // WORKLOAD PREDICTION LOGIC
    // Pure combinational logic with no feedback to avoid loops
    always @(*) begin
        // Predict workload format based on recent history patterns
        if (workloadHistoryIndex >= 4) begin
            // Check for repeating patterns in workload history
            if (workloadHistory[(workloadHistoryIndex - 1) % 16] ==
                workloadHistory[(workloadHistoryIndex - 3) % 16]) begin
                // Pattern repeats every 2 cycles, predict next workload
                predictedWorkloadFormat = workloadHistory[(workloadHistoryIndex - 2) % 16];
            end 
            else if (workloadHistory[(workloadHistoryIndex - 1) % 16] ==
                     workloadHistory[(workloadHistoryIndex - 2) % 16]) begin
                // Pattern repeats every cycle, predict same workload
                predictedWorkloadFormat = workloadHistory[(workloadHistoryIndex - 1) % 16];
            end 
            else begin
                // No clear pattern, use current workload
                predictedWorkloadFormat = workloadFormat;
            end
        end else begin
            // Not enough history, use current workload
            predictedWorkloadFormat = workloadFormat;
        end
    end

    // MAIN SEQUENTIAL LOGIC
    // All calculations moved to sequential block to avoid combinational loops
    always @(posedge clk) begin
        if (!reset) begin
            // RESET LOGIC
            // Reset all registers to safe default values
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

            // Reset arrays to default values
            for (i = 0; i < 16; i = i + 1) begin
                powerHistory[i] <= 16'h0050;
                workloadHistory[i] <= 3'h0;
            end
            
            for (i = 0; i < 8; i = i + 1) begin
                thermalHistory[i] <= 8'd100;
            end
        end else begin
            // NORMAL OPERATION LOGIC
            // Increment global counters
            cycleCounter <= cycleCounter + 1;
            adaptationCounter <= adaptationCounter + 1;

            // STEP 1: CALCULATE BASE POWER CONSUMPTION
            // Sum all component power consumptions
            basePowerConsumption <= powerALU + powerRegister + powerBranchPredictor + powerCache + powerCore;

            // STEP 2: APPLY STATE BASED POWER OVERHEAD
            // Add overhead based on current power management state
            case (powerState)
                POWERIDLE:        scaledPowerConsumption <= basePowerConsumption + 8'd5;   // Minimal overhead for idle
                POWERLOW:         scaledPowerConsumption <= basePowerConsumption + 8'd10;  // Low overhead for low power
                POWERBALANCED:    scaledPowerConsumption <= basePowerConsumption + 8'd15;  // Balanced overhead
                POWERPERFORMANCE: scaledPowerConsumption <= basePowerConsumption + 8'd25;  // Performance overhead
                POWERBURST:       scaledPowerConsumption <= basePowerConsumption + 8'd35;  // Maximum overhead
                default:          scaledPowerConsumption <= basePowerConsumption + 8'd20;  // Default overhead
            endcase

            // STEP 3: APPLY DVFS SCALING
            // Scale power consumption based on clock frequency level
            case (clockFrequencyLevel)
                3'b000: finalPowerConsumption <= (scaledPowerConsumption * 30) / 100;  // 30% power at lowest frequency
                3'b001: finalPowerConsumption <= (scaledPowerConsumption * 45) / 100;  // 45% power
                3'b010: finalPowerConsumption <= (scaledPowerConsumption * 60) / 100;  // 60% power
                3'b011: finalPowerConsumption <= (scaledPowerConsumption * 80) / 100;  // 80% power
                3'b100: finalPowerConsumption <= scaledPowerConsumption;                // 100% power
                3'b101: finalPowerConsumption <= (scaledPowerConsumption * 120) / 100; // 120% power
                3'b110: finalPowerConsumption <= (scaledPowerConsumption * 145) / 100; // 145% power
                3'b111: finalPowerConsumption <= (scaledPowerConsumption * 175) / 100; // 175% power at highest frequency
            endcase

            // STEP 4: APPLY POWER GATING SAVINGS
            // Reduce power consumption based on power gating decisions
            totalPowerConsumption <= finalPowerConsumption;
            if (powerGateALU && finalPowerConsumption >= 8'd15) 
                totalPowerConsumption <= finalPowerConsumption - 8'd15;  // Save 15 units by gating ALU
            if (powerGateRegister && totalPowerConsumption >= 8'd8) 
                totalPowerConsumption <= totalPowerConsumption - 8'd8;   // Save 8 units by gating registers
            if (powerGateBranchPredictor && totalPowerConsumption >= 8'd5) 
                totalPowerConsumption <= totalPowerConsumption - 8'd5;   // Save 5 units by gating branch predictor
            if (powerGateCache && totalPowerConsumption >= 8'd12) 
                totalPowerConsumption <= totalPowerConsumption - 8'd12;  // Save 12 units by gating cache

            // STEP 5: UPDATE CURRENT TOTAL POWER OUTPUT
            // Set the output to current calculated power consumption
            currentTotalPower <= totalPowerConsumption;

            // STEP 6: CALCULATE TEMPERATURE ESTIMATE
            // Estimate temperature based on power consumption and thermal readings
            temperatureEstimate <= 8'd80 + (totalPowerConsumption / 3) + (thermalReading / 4);
            if (thermalThrottle) begin
                temperatureEstimate <= temperatureEstimate - 8'd20;  // Reduce estimate if throttling active
            end
            if (thermalReading > 8'd100) begin
                temperatureEstimate <= temperatureEstimate + 8'd15;  // Increase estimate if thermal reading high
            end else if (thermalReading < 8'd100) begin
                temperatureEstimate <= temperatureEstimate - 8'd10;  // Decrease estimate if thermal reading low
            end
            if (temperatureEstimate > 8'd255) 
                temperatureEstimate <= 8'd255;  // Clamp to maximum value

            // STEP 7: CALCULATE EFFICIENCY
            // Calculate power efficiency as instructions per cycle per power unit
            if (totalPowerConsumption > 8'd10 && totalCycles > previousCycles && totalInstructions > previousInstructions) begin
                instructionsPC <= ((totalInstructions - previousInstructions) * 1000) / (totalCycles - previousCycles);
                if (instructionsPC > 0) begin
                    powerEfficiency <= (instructionsPC[9:0] * 10) / totalPowerConsumption;
                    if (powerEfficiency > 8'd255) 
                        powerEfficiency <= 8'd255;  // Clamp to maximum value
                end else begin
                    powerEfficiency <= 8'd1;  // Minimum efficiency value
                end
            end else begin
                powerEfficiency <= 8'd50;  // Default efficiency when no valid data
            end

            // STEP 8: DETERMINE POWER STATE
            // Select power management state based on current conditions
            if (emergencyLevel > 0) begin
                powerState <= POWERCRITICAL;  // Emergency state takes priority
            end else if (!activeProcessor) begin
                powerState <= POWERIDLE;      // Idle state when processor inactive
            end else if (totalPowerConsumption < 8'd40) begin
                powerState <= POWERLOW;       // Low power state for low consumption
            end else if (totalPowerConsumption < 8'd100) begin
                powerState <= POWERBALANCED;  // Balanced state for moderate consumption
            end else if (totalPowerConsumption < 8'd150) begin
                powerState <= POWERPERFORMANCE;  // Performance state for high consumption
            end else begin
                powerState <= POWERBURST;     // Burst state for maximum consumption
            end

            // HISTORY AND ADAPTATION LOGIC
            // Update history buffers every 16 cycles
            if (cycleCounter[3:0] === 4'h0) begin
                // Store current power consumption in history buffer
                powerHistory[powerHistoryIndex] <= {8'h0, totalPowerConsumption};
                powerHistoryIndex <= (powerHistoryIndex + 1) % 16;

                // Store workload format if classification is valid
                if (classificationValid) begin
                    workloadHistory[workloadHistoryIndex] <= workloadFormat;
                    workloadHistoryIndex <= (workloadHistoryIndex + 1) % 16;
                end

                // Store thermal reading in history buffer
                thermalHistory[thermalHistoryIndex] <= thermalReading;
                thermalHistoryIndex <= (thermalHistoryIndex + 1) % 8;
            end
            
            // MOVING AVERAGES CALCULATION
            // Calculate moving averages every 32 cycles
            if (cycleCounter[4:0] == 5'h0) begin
                // Calculate 8 point moving average of power consumption
                averagePowerConsumption <= (powerHistory[0][7:0] + powerHistory[1][7:0] +
                                            powerHistory[2][7:0] + powerHistory[3][7:0] +
                                            powerHistory[4][7:0] + powerHistory[5][7:0] +
                                            powerHistory[6][7:0] + powerHistory[7][7:0]) / 8;
                // Store current values for next cycle comparison
                previousInstructions <= totalInstructions;
                previousCycles <= totalCycles;
            end

            // EMERGENCY MANAGEMENT
            // Handle critical conditions that require immediate action
            if (temperatureEstimate > THERMALCRITICAL || totalPowerConsumption > (powerBudget + POWERBUDGETMARGIN)) begin
                // Enter emergency mode when temperature or power exceeds critical thresholds
                emergencyLevel <= 4'hF;
                emergencyTimer <= 8'hFF;
                thermalThrottle <= 1'b1;
                clockFrequencyLevel <= 3'b000;  // Set to minimum frequency
                voltageLevel <= 3'b000;          // Set to minimum voltage
                powerGateALU <= !activeProcessor;  // Gate ALU if processor inactive
                powerGateCache <= 1'b1;          // Gate cache to reduce power
                powerGateBranchPredictor <= 1'b1;  // Gate branch predictor
            end else if (emergencyLevel > 0) begin
                // Gradual recovery from emergency state
                emergencyLevel <= emergencyLevel - 1;
                emergencyTimer <= emergencyTimer - 1;
                emergencyRecovery <= 1'b1;
                if (emergencyLevel == 1) begin
                    emergencyRecovery <= 1'b0;  // Exit recovery mode
                end
            end else begin
                // NORMAL OPERATION CONTINUES
                emergencyRecovery <= 1'b0;
                
                // THERMAL MANAGEMENT
                // Adjust frequency and voltage based on temperature
                if (temperatureEstimate > THERMALWARNING) begin
                    thermalThrottle <= 1'b1;
                    if (clockFrequencyLevel > 3'b001) begin
                        clockFrequencyLevel <= clockFrequencyLevel - 1;  // Reduce frequency
                        voltageLevel <= voltageLevel - 1;                // Reduce voltage
                    end
                end else if (temperatureEstimate < (THERMALWARNING - 8'd30)) begin
                    thermalThrottle <= 1'b0;  // Disable thermal throttling
                end

                // WORKLOAD AWARE POWER MANAGEMENT
                // Adjust power settings based on workload classification
                if (classificationValid && workloadConfidence >= 4'h6) begin
                    case (workloadFormat)
                        WLIDLE: begin
                            // Idle workload: minimize power consumption
                            targetFrequencyLevel <= 3'b001;
                            targetVoltageLevel <= 3'b001;
                            if (!activeProcessor) begin
                                powerGateALU <= 1'b1;
                                powerGateCache <= 1'b1;
                                powerGateBranchPredictor <= 1'b1;
                            end
                        end
                        WLCOMPUTE: begin
                            // Compute intensive workload: optimize for performance
                            if (performanceMode) begin
                                targetFrequencyLevel <= 3'b110;
                                targetVoltageLevel <= 3'b110;
                            end else begin
                                targetFrequencyLevel <= 3'b100;
                                targetVoltageLevel <= 3'b100;
                            end
                            powerGateALU <= 1'b0;  // Keep ALU active
                            powerGateCache <= 1'b0;  // Keep cache active
                        end
                        WLMEMORY: begin
                            // Memory intensive workload: moderate frequency
                            targetFrequencyLevel <= 3'b011;
                            targetVoltageLevel <= 3'b011;
                            powerGateBranchPredictor <= 1'b0;  // Keep branch predictor active
                            powerGateALU <= !activeProcessor;   // Gate ALU if not needed
                        end
                        WLMIXED: begin
                            // Mixed workload: balanced settings
                            targetFrequencyLevel <= 3'b011;
                            targetVoltageLevel <= 3'b011;
                            powerGateALU <= 1'b0;
                            powerGateCache <= 1'b0;
                        end
                        WLSTREAMING: begin
                            // Streaming workload: high frequency for throughput
                            targetFrequencyLevel <= 3'b100;
                            targetVoltageLevel <= 3'b100;
                            powerGateCache <= 1'b0;  // Keep cache active
                            powerGateALU <= !activeProcessor;  // Gate ALU if not needed
                        end
                        default: begin
                            // Default balanced settings
                            targetFrequencyLevel <= 3'b011;
                            targetVoltageLevel <= 3'b011;
                        end
                    endcase
                end

                // DVFS TRANSITIONS
                // Smooth transitions between frequency and voltage levels
                timerDVFS <= timerDVFS + 1;
                if (timerDVFS[2:0] == 3'h0 && transitionDelay == 0) begin
                    if (clockFrequencyLevel < targetFrequencyLevel && !thermalThrottle) begin
                        // Increase frequency and voltage gradually
                        clockFrequencyLevel <= clockFrequencyLevel + 1;
                        voltageLevel <= voltageLevel + 1;
                        transitionDelay <= 8'h4;  // Set transition delay
                    end else if (clockFrequencyLevel > targetFrequencyLevel) begin
                        // Decrease frequency and voltage gradually
                        clockFrequencyLevel <= clockFrequencyLevel - 1;
                        voltageLevel <= voltageLevel - 1;
                        transitionDelay <= 8'h4;  // Set transition delay
                    end
                end
                
                // Decrement transition delay counter
                if (transitionDelay > 0) begin
                    transitionDelay <= transitionDelay - 1;
                end

                // POWER BUDGET MANAGEMENT
                // Ensure power consumption stays within budget
                if (totalPowerConsumption > powerBudget) begin
                    if (clockFrequencyLevel > 3'b000) begin
                        // Reduce frequency and voltage to stay within budget
                        targetFrequencyLevel <= clockFrequencyLevel - 1;
                        targetVoltageLevel <= voltageLevel - 1;
                    end
                    if (!activeProcessor) begin
                        // Gate components if processor is inactive
                        powerGateALU <= 1'b1;
                        powerGateCache <= 1'b1;
                    end
                end

                // ADAPTIVE LEARNING
                // Adjust learning parameters based on prediction accuracy
                if (adaptationCounter[4:0] == 5'h0) begin
                    if (workloadPredictionAccuracy > 8'd200) begin
                        // Reduce learning rate if predictions are very accurate
                        learningRate <= (learningRate > 8'h04) ? learningRate - 8'h04 : 8'h04;
                    end else if (workloadPredictionAccuracy < 8'd100) begin
                        // Increase learning rate if predictions are poor
                        learningRate <= (learningRate < 8'h20) ? learningRate + 8'h04 : 8'h20;
                    end
                    adaptationRate <= (learningRate >> 1) & 4'hF;  // Set adaptation rate
                    
                    // Calculate energy savings
                    if (averagePowerConsumption > 0) begin
                        energySaved <= energySaved + (averagePowerConsumption - totalPowerConsumption);
                    end
                end

                optimizationDecisions <= optimizationDecisions + 1;  // Track optimization decisions
            end

            // PREDICTIVE WAKE UP FOR POWER GATING
            // Predict when to wake up gated components based on workload
            gatingTimer <= gatingTimer + 1;
            if (gatingTimer[3:0] == 4'h0) begin
                // Set wakeup prediction based on predicted workload type
                case (predictedWorkloadFormat)
                    WLCOMPUTE: wakeupPrediction <= 8'h08;   // Quick wakeup for compute workload
                    WLMEMORY: wakeupPrediction <= 8'h10;    // Medium wakeup for memory workload
                    WLCONTROL: wakeupPrediction <= 8'h06;   // Quick wakeup for control workload
                    default: wakeupPrediction <= 8'h20;     // Slow wakeup for unknown workload
                endcase

                // Wake up components if prediction timer expires
                if (wakeupPrediction <= 8'h04) begin
                    powerGateALU <= 1'b0;
                    powerGateCache <= 1'b0;
                    powerGateBranchPredictor <= 1'b0;
                end

                // Decrement wakeup prediction timer
                if (wakeupPrediction > 0) 
                    wakeupPrediction <= wakeupPrediction - 1;
            end

            // POWER TREND ANALYSIS
            // Analyze power consumption trends every 128 cycles
            if (cycleCounter[6:0] == 7'h0) begin
                if (totalPowerConsumption > averagePowerConsumption + 8'h10) begin
                    // Power consumption is increasing
                    powerTrend <= (powerTrend < 8'd240) ? powerTrend + 8'h10 : 8'd255;
                end else if (totalPowerConsumption < averagePowerConsumption - 8'h10) begin
                    // Power consumption is decreasing
                    powerTrend <= (powerTrend > 8'h10) ? powerTrend - 8'h10 : 8'h00;
                end else begin
                    // Power consumption is stable
                    powerTrend <= 8'h80;
                end
            end
        end
    end

    // OUTPUT ASSIGNMENTS
    // Combinational logic for output signals
    assign optimizationQuality = (powerEfficiency > EFFICIENCYTARGET) ?
                                  8'd255 : (powerEfficiency * 255) / EFFICIENCYTARGET;  // Calculate optimization quality
    assign powerOptimizationActive = (powerState != POWERCRITICAL) &&
                                    (emergencyLevel == 0) && classificationValid;  // Indicate if optimization is active

endmodule