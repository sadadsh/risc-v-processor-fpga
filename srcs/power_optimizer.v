`timescale 1ns / 1ps

// POWER OPTIMIZER
// Engineer: Sadad Haidari
//
// This module uses power management techniques inspired from modern CPUs.
// It uses machine learning concepts for predictive power optimization, dynamic voltage and
// frequency scaling (DVFS), intelligent power gating, and thermal management.
//
// Innovation Features:
// -> Workload-Aware Power Management: Uses workload classification for predictive power optimization.
// -> DVFS: Real-time adjustment based on performance needs.
// -> Intelligent Power Gating: Selective component shutdown with fast wake-up prediction.
// -> Thermal-Aware Management: Proactive thermal throttling and optimization.
// -> Performance-Power Tradeoff Optimization: Pareto-optimal operation point selection (P-V curves).
// -> Power Budget Management: Adaptive power allocation within constraints.
// -> Machine Learning-Inspired Adaptation: Learning from past power-performance patterns.

// For each section, I will attempt to explain the logic and the reasoning behind it.

module power_optimizer(
    input wire clk,
    input wire reset,

    // INPUTS
    // Workload Classification Inputs
    // We need inputs from the workload classifier to make our decisions.
    input wire [2:0] workloadFormat, // The current workload format [compute, control, idle, etc.].
    input wire [3:0] workloadConfidence, // Confidence in the classification.
    input wire [7:0] computeToll, // Compute intensity (0-255).
    input wire [7:0] memToll, // Memory intensity (0-255).
    input wire [7:0] controlToll, // Control intensity (0-255).
    input wire [7:0] complexPattern, // Pattern complexity metric.
    input wire classificationValid, // Is workload classification reliable?

    // Component Power Consumption Inputs
    // Real-time power consumption from various processor components.
    input wire [7:0] powerALU, // Power consumption of the arithmetic logic unit.
    input wire [7:0] powerRegister, // Power consumption of the register file.
    input wire [7:0] powerBranchPredictor, // Power consumption of the branch predictor.
    input wire [7:0] powerCache, // Power consumption of the cache (simulated).
    input wire [7:0] powerCore, // Core logic power consumption.

    // Performance Metrics Inputs
    // Performance data to make power-performance tradeoff decisions.
    input wire [31:0] totalInstructions, // Total instructions executed.
    input wire [31:0] totalCycles, // Total clock cycles.
    input wire [7:0] branchAccuracy, // Branch prediction accuracy.
    input wire [15:0] cacheHitRate, // Cach hit rate (simulated).
    input wire activeProcessor, // Is the processor executing something?

    // External Constraints
    // External power and thermal constraints.
    input wire [7:0] powerBudget, // Maximum power consumption allowed.
    input wire [7:0] thermalReading, // Temperature sensor reading (0-255 and scaled).
    input wire [7:0] batteryLevel, // Battery level for mobile applications (0-255).
    input wire performanceMode, // 0 = power-saving, 1 = performance-mode.

    // OUTPUTS
    // Power Management Outputs
    // Control signals for dynamic power management.
    output reg [2:0] clockFrequencyLevel, // Clock frequency level (0-7, 7 = highest).
    output reg [2:0] voltageLevel, // Voltage level (0-7, 7 = highest).
    output reg powerGateALU, // Power gate the arithmetic logic unit when not needed.
    output reg powerGateRegister, // Power gate the register file when not needed.
    output reg powerGateBranchPredictor, // Power gate the branch predictor when not needed.
    output reg powerGateCache, // Power gate the cache when not needed.
    output reg powerGateCore, // Power gate the core logic when not needed.
    output reg thermalThrottle, // Enable thermal throttling.

    // Optimization Status Outputs
    // Status monitoring information.
    output reg [7:0] currentTotalPower, // Current total power consumption.
    output reg [7:0] powerEfficiency, // Power efficiency metric (performance/power).
    output reg [2:0] powerState, // Current power management state.
    output reg [7:0] temperatureEstimate, // Estimated processor temperature.
    output reg [15:0] energySaved, // Cumulative energy saved.
    output wire [7:0] optimizationQuality, // Quality of the optimization (0-255).

    // Predictive Optimization Outputs
    // Future-looking optimization decisions.
    output reg [2:0] predictedWorkloadFormat, // Predicted next workload format.
    output reg [3:0] adaptationRate, // How fast optimizer is learning.
    output reg [7:0] powerTrend, // Power consumption trend prediction.
    output wire powerOptimizationActive // Is power optimization running right now?
);

    // POWER MANAGEMENT STATES
    // We need to define the states for power management because it allows us to make decisions based on the current state.
    localparam POWERIDLE        = 3'b000; // Minimal activity, maximum power savings.
    localparam POWERLOW         = 3'b001; // Low activity, moderate power savings.
    localparam POWERBALANCED    = 3'b010; // Balanced performance-power operation.
    localparam POWERPERFORMANCE = 3'b011; // High performance, minimal power savings.
    localparam POWERBURST       = 3'b100; // Maximum performance for short bursts.
    localparam POWERTHERMAL     = 3'b101; // Thermal throttling to prevent overheating [EMERGENCY MODE].
    localparam POWERCRITICAL    = 3'b110; // Critical power/thermal situation.
    localparam POWERADAPTIVE    = 3'b111; // Adaptive power management based on workload.

    // WORKLOAD FORMAT CONSTANTS
    // We need to define the workload formats because it allows us to make decisions based on the current workload.
    localparam WLUNKNOWN        = 3'b000; // Unknown workload format.
    localparam WLCOMPUTE        = 3'b001; // Compute-intensive workload.
    localparam WLMEMORY         = 3'b010; // Memory-intensive workload.
    localparam WLCONTROL        = 3'b011; // Control-intensive workload.
    localparam WLMIXED          = 3'b100; // Mixed workload.
    localparam WLIDLE           = 3'b101; // Idle workload.
    localparam WLSTREAMING      = 3'b110; // Streaming workload.
    localparam WLIRREGULAR      = 3'b111; // Irregular workload.

    // OPTIMIZATION PARAMETERS
    // We need to define the parameters for optimization because it allows us to make decisions based on the current state.
    localparam THERMALWARNING = 8'd150; // Warning temperature.
    localparam THERMALCRITICAL = 8'd180; // Critical temperature.
    localparam POWERBUDGETMARGIN = 8'd20; // Power budget margin.
    localparam ADAPTATIONWINDOW = 6'd32; // Learning window size.
    localparam EFFICIENCYTARGET = 8'd180; // Target efficiency score.

    // INTERNAL STATE REGISTERS
    // These registers store the internal state required for power and thermal management.
    reg [7:0] totalPowerConsumption; // Current total power consumption.
    reg [7:0] averagePowerConsumption; // Moving average power.
    reg [15:0] powerHistory [0:15]; // Power consumption history.
    reg [3:0] powerHistoryIndex; // Index for power history.
    reg [31:0] cycleCounter; // Cycle counter for timing.
    reg [7:0] thermalHistory [0:7]; // Thermal history for trend analysis.
    reg [2:0] thermalHistoryIndex; // Index for thermal history.

    // WORKLOAD PREDICTION AND ADAPTATION
    reg [2:0] workloadHistory [0:15]; // Recent workload patterns.
    reg [3:0] workloadHistoryIndex; // Index for workload history.
    reg [7:0] workloadStability; // How stable is the workload?
    reg [7:0] learningRate; // Adaptive learning rate.
    reg [31:0] adaptationCounter; // Adaptation timing counter.

    // PERFORMANCE TRACKING
    reg [31:0] instructionsPC; // IPC calculation (instructions per cycle).
    reg [7:0] performanceScore; // Overall performance metric.
    reg [31:0] previousInstructions; // Previous instructions executed for IPC.
    reg [31:0] previousCycles; // Previous clock cycles for IPC.

    // POWER GATING CONTROL
    reg [7:0] gatingTimer; // Timer for power gating decisions.
    reg [7:0] wakeupPrediction; // Predicted cycles until next use.
    reg powerGatingActive; // Is power gating currently active?

    // DVFS CONTROL REGISTERS
    // These registers control the dynamic voltage and frequency scaling.
    reg [7:0] timerDVFS; // DVFS decision timer.
    reg [2:0] targetFrequencyLevel; // Target frequency level.
    reg [2:0] targetVoltageLevel; // Target voltage level.
    reg [7:0] transitionDelay; // DVFS transition delay.

    // PREDICTIVE OPTIMIZATION
    // These registers control the predictive optimization.
    reg [7:0] workloadPredictionAccuracy; // Accuracy of workload prediction.
    reg [7:0] powerPredictionError; // Error in power predictions.
    reg [31:0] optimizationDecisions; // Total optimization decisions made.

    // EFFICIENCY CALCULATION
    reg [15:0] efficiencyAccumulator; // For efficiency calculations.
    reg [7:0] efficiencyWindow; // Efficiency calculation window.

    // EMERGENCY MANAGEMENT
    // Emergency management is required to prevent overheating and critical power/thermal situations.
    reg [3:0] emergencyLevel; // Current emergency level (0 = none, 15 = critical).
    reg [7:0] emergencyTimer; // Emergency state timer.
    reg emergencyRecovery; // Is system recovering from emergency?

    integer i; // Loop variable.

    // INITIALIZATION
    initial begin
        clockFrequencyLevel = 3'b011; // Default to balanced performance-power operation.
        voltageLevel = 3'b011; // Default to balanced performance-power operation.
        powerGateALU = 1'b0; // Default to enable ALU (PG disabled).
        powerGateRegister = 1'b0; // Default to enable register file (PG disabled).
        powerGateBranchPredictor = 1'b0; // Default to enable branch predictor (PG disabled).
        powerGateCache = 1'b0; // Default to enable cache (PG disabled).
        powerGateCore = 1'b0; // Default to enable core logic (PG disabled).
        thermalThrottle = 1'b0; // Disable thermal throttling on default.

        currentTotalPower = 8'h0; // Initialize total power consumption to 0.
        powerEfficiency = 8'h80; // Initialize power efficiency to 50% (default).
        powerState = POWERBALANCED; // Default to balanced performance-power operation.
        temperatureEstimate = 8'd100; // Start at moderate temperature.
        energySaved = 16'h0; // Initialize energy saved to 0.

        predictedWorkloadFormat = WLUNKNOWN; // Unknown workload format.
        adaptationRate = 4'h1; // Default to moderate learning rate, will be updated during operation.
        powerTrend = 8'h80; // Initialize power trend indicator to neutral (midpoint) for tracking power usage direction.

        totalPowerConsumption = 8'h0; // Initialize total power consumption to 0.
        averagePowerConsumption = 8'h0; // Initialize average power consumption to 0.
        powerHistoryIndex = 4'h0; // Initialize power history index to 0.
        cycleCounter = 32'h0; // Initialize cycle counter to 0.
        thermalHistoryIndex = 3'h0; // Initialize thermal history index to 0.

        workloadHistoryIndex = 4'h0; // Initialize workload history index to 0.
        workloadStability = 8'h80; // Initialize workload stability to neutral (midpoint) for tracking workload consistency.
        learningRate = 8'h10; // Initialize learning rate to 10% (default).
        adaptationCounter = 32'h0; // Initialize adaptation counter to 0.

        instructionsPC = 32'h0; // Initialize instructions per cycle to 0.
        performanceScore = 8'h80; // Initialize performance score to neutral (midpoint) for tracking performance direction.
        previousInstructions = 32'h0; // Initialize previous instructions to 0.
        previousCycles = 32'h0; // Initialize previous clock cycles to 0.

        gatingTimer = 8'h0; // Initialize power gating timer to 0.
        wakeupPrediction = 8'h0; // Initialize wakeup prediction to 0.
        powerGatingActive = 1'b0; // Initialize power gating active to 0.

        timerDVFS = 8'h0; // Initialize DVFS timer to 0.
        targetFrequencyLevel = 3'b011; // Default to balanced performance-power operation.
        targetVoltageLevel = 3'b011; // Default to balanced performance-power operation.
        transitionDelay = 8'h0; // Initialize transition delay to 0.

        workloadPredictionAccuracy = 8'h80; // Workload accuracy starts at 50% (neutral).
        powerPredictionError = 8'h0; // Initialize power prediction error to 0.
        optimizationDecisions = 32'h0; // Initialize optimization decisions to 0.

        efficiencyAccumulator = 16'h0; // Initialize efficiency accumulator to 0.
        efficiencyWindow = 8'h0; // Initialize efficiency window to 0 cycles.

        emergencyLevel = 4'h0; // Initialize emergency level to 0.
        emergencyTimer = 8'h0; // Initialize emergency timer to 0.
        emergencyRecovery = 1'b0; // Initialize emergency recovery to 0.

        // Initialize Arrays
        for (i = 0; i < 16; i = i + 1) begin
            powerHistory[i] = 16'h0; // Initialize power history to 0.
            workloadHistory[i] = 3'h0; // Initialize workload history to 0.
        end
        
        for (i = 0; i < 8; i = i + 1) begin
            thermalHistory[i] = 8'd100; // Use 100 as a moderate initial temperature to avoid biasing early decisions
        end
    end

    // MAIN PROCESS

    // TOTAL POWER CALCULATION
    // We need to continuously calculate total power consumption from all components of the processor.
    always @(*) begin
        totalPowerConsumption = powerALU + powerRegister + powerBranchPredictor + powerCache + powerCore;
        // We add up the power consumption of all components to get the total power consumption.

        // Add base power consumption depending on the current power state.
        // This models the static or baseline power draw of the system in each mode,
        // regardless of dynamic activity from the processor components.
        case (powerState)
            POWERIDLE:        totalPowerConsumption = 8'd5;   // Minimal power in idle state. Represents leakage and always-on logic only.
            POWERLOW:         totalPowerConsumption = 8'd10;  // Low-power mode baseline. Slightly higher due to some active blocks.
            POWERBALANCED:    totalPowerConsumption = 8'd15;  // Balanced mode baseline. Typical for moderate activity and average voltage/frequency.
            POWERPERFORMANCE: totalPowerConsumption = 8'd25;  // High-performance mode baseline. More subsystems are active, higher voltage/frequency.
            POWERBURST:       totalPowerConsumption = 8'd35;  // Maximum power for burst mode. All units active at highest voltage/frequency for peak throughput.
            default:          totalPowerConsumption = totalPowerConsumption + 8'd20; // Fallback: add extra to current total. Ensures we never underestimate power in undefined states.
        endcase

        // Adjust for DVFS Settings
        // Adjust total power consumption based on the current dynamic clock frequency level.
        // This models the effect of Dynamic Voltage and Frequency Scaling (DVFS) in our processor,
        // where running at lower frequencies reduces power (for energy savings), and higher frequencies
        // increase power (for performance bursts). Each level represents a typical scaling factor
        // for a modern processor's DVFS response.
        case (clockFrequencyLevel)
            3'b000: totalPowerConsumption = (totalPowerConsumption * 30) / 100;  // 30% power at minimum frequency.
            3'b001: totalPowerConsumption = (totalPowerConsumption * 45) / 100;  // 45% power at low frequency.
            3'b010: totalPowerConsumption = (totalPowerConsumption * 60) / 100;  // 60% power at medium frequency.
            3'b011: totalPowerConsumption = (totalPowerConsumption * 80) / 100;  // 80% power at balanced frequency.
            3'b100: totalPowerConsumption = totalPowerConsumption;               // 100% power at nominal frequency.
            3'b101: totalPowerConsumption = (totalPowerConsumption * 120) / 100; // 120% power at high frequency.
            3'b110: totalPowerConsumption = (totalPowerConsumption * 145) / 100; // 145% power at super high frequency.
            3'b111: totalPowerConsumption = (totalPowerConsumption * 175) / 100; // 175% power at maximum frequency.
        endcase

        // Add Power Gating Savings
        // The following section applies power gating savings to the total power consumption.
        // Power gating is a technique used to reduce power usage by turning off the power supply to specific processor components when they are not needed.
        // For each component that is power gated, we subtract its typical power draw from the total power consumption.
        // IMPORTANT: Prevent underflow by checking if we have enough power to subtract.
        if (powerGateALU && totalPowerConsumption >= 8'd15) 
            totalPowerConsumption = totalPowerConsumption - 8'd15;            // Subtract ALU power when ALU is power gated.
        if (powerGateRegister && totalPowerConsumption >= 8'd8) 
            totalPowerConsumption = totalPowerConsumption - 8'd8;             // Subtract register file power when registers are power gated.
        if (powerGateBranchPredictor && totalPowerConsumption >= 8'd5) 
            totalPowerConsumption = totalPowerConsumption - 8'd5;             // Subtract branch predictor power when it is power gated.
        if (powerGateCache && totalPowerConsumption >= 8'd12) 
            totalPowerConsumption = totalPowerConsumption - 8'd12;            // Subtract cache power when cache is power gated.

        currentTotalPower = totalPowerConsumption; // Update the current total power consumption.
    end

    // TEMPERATURE ESTIMATION
    // This always block estimates the processor's temperature based on current power usage,
    // recent thermal history, and environmental/operational factors.
    always @(*) begin
        // Start with a base temperature of 80C, which represents a baseline value.
        // Add a portion of the current total power consumption (divided by 3) to model the heat generated by active power usage.
        temperatureEstimate = 8'd80 + (totalPowerConsumption / 3);

        // Add a fraction (1/4) of the previous thermal reading to simulate thermal inertia,
        // meaning the chip's temperature doesn't change instantly but is influenced by recent history.
        temperatureEstimate = temperatureEstimate + (thermalReading / 4);

        // If thermal throttling is active, subtract 20C to reflect the effect of throttling mechanisms
        // (such as clock gating or voltage reduction) that reduce heat output.
        if (thermalThrottle) begin
            temperatureEstimate = temperatureEstimate - 8'd20;
        end

        // Environmental Adjustment
        // If the external/ambient temperature (thermalReading) is high (>100C), add 15C to the estimate,
        // simulating a hot environment making it harder for the chip to cool.
        // If the environment is cool (<100C), subtract 10C to reflect easier heat dissipation.
        if (thermalReading > 8'd100) begin
            temperatureEstimate = temperatureEstimate + 8'd15; // Hot environment increases chip temperature.
        end else if (thermalReading < 8'd100) begin
            temperatureEstimate = temperatureEstimate - 8'd10; // Cool environment decreases chip temperature.
        end

        // Clamp the temperature estimate to a maximum of 255C to prevent overflow or unrealistic values.
        if (temperatureEstimate > 8'd255) temperatureEstimate = 8'd255;
    end

    // EFFICIENCY CALCULATION
    // This always block computes the processor's power efficiency, defined as performance per watt.
    always @(*) begin
        // Only calculate efficiency if the processor is active (power consumption is above 10)
        // and there has been progress in cycles (to avoid division by zero).
        if (totalPowerConsumption > 8'd10 && totalCycles > previousCycles) begin
            // Calculate the scaled Instructions Per Cycle (IPC).
            // This is done by taking the difference in total instructions since the last measurement,
            // multiplying by 100 for scaling, and dividing by the number of cycles elapsed.
            instructionsPC = ((totalInstructions - previousInstructions) * 100) / (totalCycles - previousCycles);
            
            // Calculate power efficiency as the scaled IPC per unit of power consumption.
            // The lower 8 bits of instructionsPC are used, multiplied by 100 for further scaling,
            // and then divided by the current total power consumption.
            powerEfficiency = (instructionsPC[7:0] * 100) / totalPowerConsumption;

            // Clamp the efficiency value to a maximum of 255 to prevent overflow.
            if (powerEfficiency > 8'd255) powerEfficiency = 8'd255;
        end else begin
            // If the processor is not active or there is no progress, set efficiency to a low default value.
            powerEfficiency = 8'd50; // Indicates low efficiency when idle or inactive.
        end
    end

    // WORKLOAD PREDICTION
    // Predict future workload based on historical patterns.
    always @(*) begin
        // Only attempt pattern-based prediction if we have at least 4 history entries.
        if (workloadHistoryIndex >= 4) begin
            // Check if the workload from 1 cycle ago matches the workload from 3 cycles ago.
            // This suggests a repeating pattern, so we predict the value that would continue the pattern
            // which is the value from 2 cycles ago.
            if (workloadHistory[(workloadHistoryIndex - 1) % 16] ==
                workloadHistory[(workloadHistoryIndex - 3) % 16]) begin
                predictedWorkloadFormat = workloadHistory[(workloadHistoryIndex - 2) % 16];
            end 
            // If the last two workloads are the same, assume the workload is stable and will continue.
            else if (workloadHistory[(workloadHistoryIndex - 1) % 16] ==
                     workloadHistory[(workloadHistoryIndex - 2) % 16]) begin
                // Stable workload, predict continuation of the same format.
                predictedWorkloadFormat = workloadHistory[(workloadHistoryIndex - 1) % 16];
            end 
            else begin
                // If no clear pattern is found, default to the current workload format.
                // This acts as a fallback to avoid making a poor prediction.
                predictedWorkloadFormat = workloadFormat;
            end
        end else begin
            // If there is not enough history, default to the current workload format.
            predictedWorkloadFormat = workloadFormat;
        end
    end

    // MAIN POWER OPTIMIZATION LOGIC
    always @(posedge clk) begin
        if (!reset) begin
            clockFrequencyLevel <= 3'b011; // Default to balanced performance-power operation.
            voltageLevel <= 3'b011; // Default to balanced performance-power operation.
            powerGateALU <= 1'b0; // Default to enable ALU (PG disabled).
            powerGateRegister <= 1'b0; // Default to enable register file (PG disabled).
            powerGateBranchPredictor <= 1'b0; // Default to enable branch predictor (PG disabled).
            powerGateCache <= 1'b0; // Default to enable cache (PG disabled).
            powerGateCore <= 1'b0; // Default to enable core logic (PG disabled).
            thermalThrottle <= 1'b0; // Disable thermal throttling on default.

            currentTotalPower <= 8'h0; // Initialize total power consumption to 0.
            powerEfficiency <= 8'h80; // Initialize power efficiency to 50% (default).
            powerState <= POWERBALANCED; // Default to balanced performance-power operation.
            temperatureEstimate <= 8'd100; // Start at moderate temperature.
            energySaved <= 16'h0; // Initialize energy saved to 0.

            predictedWorkloadFormat <= WLUNKNOWN; // Unknown workload format.
            adaptationRate <= 4'h1; // Default to moderate learning rate.
            powerTrend <= 8'h80; // Initialize power trend indicator to neutral (midpoint) for tracking power usage direction.

            totalPowerConsumption <= 8'h0; // Initialize total power consumption to 0.
            averagePowerConsumption <= 8'h0; // Initialize average power consumption to 0.
            powerHistoryIndex <= 4'h0; // Initialize power history index to 0.
            cycleCounter <= 32'h0; // Initialize cycle counter to 0.
            thermalHistoryIndex <= 3'h0; // Initialize thermal history index to 0.

            workloadHistoryIndex <= 4'h0; // Initialize workload history index to 0.
            workloadStability <= 8'h80; // Initialize workload stability to neutral (midpoint) for tracking workload consistency.
            learningRate <= 8'h10; // Initialize learning rate to 10% (default).
            adaptationCounter <= 32'h0; // Initialize adaptation counter to 0.

            instructionsPC <= 32'h0; // Initialize instructions per cycle to 0.
            performanceScore <= 8'h80; // Initialize performance score to neutral (midpoint) for tracking performance direction.
            previousInstructions <= 32'h0; // Initialize previous instructions to 0.
            previousCycles <= 32'h0; // Initialize previous clock cycles to 0.

            gatingTimer <= 8'h0; // Initialize power gating timer to 0.
            wakeupPrediction <= 8'h0; // Initialize wakeup prediction to 0.
            powerGatingActive <= 1'b0; // Initialize power gating active to 0.

            timerDVFS <= 8'h0; // Initialize DVFS timer to 0.
            targetFrequencyLevel <= 3'b011; // Default to balanced performance-power operation.
            targetVoltageLevel <= 3'b011; // Default to balanced performance-power operation.
            transitionDelay <= 8'h0; // Initialize transition delay to 0.

            workloadPredictionAccuracy <= 8'h80; // Workload accuracy starts at 50% (neutral).
            powerPredictionError <= 8'h0; // Initialize power prediction error to 0.
            optimizationDecisions <= 32'h0; // Initialize optimization decisions to 0.

            efficiencyAccumulator <= 16'h0; // Initialize efficiency accumulator to 0.
            efficiencyWindow <= 8'h0; // Initialize efficiency window to 0 cycles.

            emergencyLevel <= 4'h0; // Initialize emergency level to 0.
            emergencyTimer <= 8'h0; // Initialize emergency timer to 0.
            emergencyRecovery <= 1'b0; // Initialize emergency recovery to 0.

            // Initialize Arrays
            for (i = 0; i < 16; i = i + 1) begin
                powerHistory[i] <= 16'h0; // Initialize power history to 0.
                workloadHistory[i] <= 3'h0; // Initialize workload history to 0.
            end
            
            for (i = 0; i < 8; i = i + 1) begin
                thermalHistory[i] <= 8'd100; // Use 100 as a moderate initial temperature to avoid biasing early decisions
            end
        end else begin
            // Increment the cycle counter on every clock cycle. This tracks the total number of cycles elapsed.
            cycleCounter <= cycleCounter + 1;
            // Increment the adaptation counter, which is used for tracking adaptation or learning intervals.
            adaptationCounter <= adaptationCounter + 1;

            // Check if 16 cycles have passed. The lower 4 bits of cycleCounter will be zero every 16 cycles.
            if (cycleCounter[3:0] === 4'h0) begin
                // Store the current total power consumption in the powerHistory array.
                // The upper 8 bits are set to zero, and the lower 8 bits hold the totalPowerConsumption value.
                powerHistory[powerHistoryIndex] <= {8'h0, totalPowerConsumption};
                // Increment the powerHistoryIndex and wrap it around to 0 after reaching 15, ensuring a circular buffer.
                powerHistoryIndex <= (powerHistoryIndex + 1) % 16;

                // If the workload classification is valid, update the workloadHistory array.
                if (classificationValid) begin
                    // Store the current workload format in the workloadHistory array at the current index.
                    workloadHistory[workloadHistoryIndex] <= workloadFormat;
                    // Increment the workloadHistoryIndex and wrap it around to 0 after reaching 15.
                    workloadHistoryIndex <= (workloadHistoryIndex + 1) % 16;
                end

                // Store the current thermal reading in the thermalHistory array at the current index.
                thermalHistory[thermalHistoryIndex] <= thermalReading;
                // Increment the thermalHistoryIndex and wrap it around to 0 after reaching 7.
                thermalHistoryIndex <= (thermalHistoryIndex + 1) % 8;
            end
            
            // Calculate Moving Averages Every 32 Cycles
            if (cycleCounter[4:0] == 5'h0) begin
                // Update average power consumption.
                // The following line calculates the average power consumption over the last 8 samples.
                // Each entry in powerHistory stores a 16-bit value, but only the lower 8 bits [7:0] are used for the power value.
                // We sum the lower 8 bits of the most recent 8 entries (powerHistory[0] to powerHistory[7])
                // and then divide by 8 to get the moving average. This provides a smoothed estimate of recent power usage,
                // which helps filter out short-term fluctuations and gives a more stable value for power management decisions.
                averagePowerConsumption <= (powerHistory[0][7:0] + powerHistory[1][7:0] +
                                            powerHistory[2][7:0] + powerHistory[3][7:0] +
                                            powerHistory[4][7:0] + powerHistory[5][7:0] +
                                            powerHistory[6][7:0] + powerHistory[7][7:0]) / 8;

                // Update performance tracking.
                previousInstructions <= totalInstructions;
                previousCycles <= totalCycles;
            end

            // Emergency Management [HIGHEST PRIORITY]
            if (temperatureEstimate > THERMALCRITICAL || totalPowerConsumption >
               (powerBudget + POWERBUDGETMARGIN)) begin
                emergencyLevel <= 4'hF; // Set emergency level to maximum.
                emergencyTimer <= 8'hFF; // Set emergency timer to maximum.
                powerState <= POWERCRITICAL; // Set power state to critical.
                thermalThrottle <= 1'b1; // Enable thermal throttling.
                clockFrequencyLevel <= 3'b000; // Set clock frequency to minimum.
                voltageLevel <= 3'b000; // Set voltage level to minimum.
                
                // Emergency Power Gating
                powerGateALU <= !activeProcessor;
                powerGateCache <= 1'b1;
                powerGateBranchPredictor <= 1'b1;

               end else if (emergencyLevel > 0) begin
                // Emergency Recovery
                emergencyLevel <= emergencyLevel - 1;
                emergencyTimer <= emergencyTimer - 1;
                emergencyRecovery <= 1'b1;

                if (emergencyLevel == 1) begin
                    emergencyRecovery <= 1'b0;
                    powerState <= POWERLOW; // Safe recovery state.
                end
            end

            // Normal Power Optimization
            else if (emergencyLevel == 0) begin
                // Thermal Management
                if (temperatureEstimate > THERMALWARNING) begin
                    thermalThrottle <= 1'b1; // Enable thermal throttling.
                    if (clockFrequencyLevel > 3'b001) begin
                        clockFrequencyLevel <= clockFrequencyLevel - 1;
                        voltageLevel <= voltageLevel - 1; // Also reduce voltage to match frequency.
                    end
                end else if (temperatureEstimate < (THERMALWARNING - 8'd30)) begin
                    thermalThrottle <= 1'b0; // Disable thermal throttling.
                end

                // Workload-Aware Power State Management
                if (classificationValid && workloadConfidence >= 4'h6) begin
                    case (workloadFormat)
                        WLIDLE: begin
                            powerState <= POWERIDLE;
                            targetFrequencyLevel <= 3'b001; // Very low frequency.
                            targetVoltageLevel <= 3'b001; // Very low voltage.
                            // Aggressive power gating for idle workloads.
                            if (!activeProcessor) begin
                                powerGateALU <= 1'b1;
                                powerGateCache <= 1'b1;
                                powerGateBranchPredictor <= 1'b1;
                            end
                        end
                        WLCOMPUTE: begin
                            if (performanceMode) begin
                                powerState <= POWERPERFORMANCE;
                                targetFrequencyLevel <= 3'b110; // High frequency for compute-intensive workloads.
                                targetVoltageLevel <= 3'b110; // High voltage for compute-intensive workloads.
                            end else begin
                                powerState <= POWERBALANCED;
                                targetFrequencyLevel <= 3'b100; // Moderate frequency for balanced workloads.
                                targetVoltageLevel <= 3'b100; // Moderate voltage for balanced workloads.
                            end
                            powerGateALU <= 1'b0; // Keep ALU active.
                            powerGateCache <= 1'b0; // Keep cache active.
                        end
                        WLMEMORY: begin
                            powerState <= POWERBALANCED;
                            targetFrequencyLevel <= 3'b011; // Balanced frequency for memory-intensive workloads.
                            targetVoltageLevel <= 3'b011; // Balanced voltage for memory-intensive workloads.
                            powerGateBranchPredictor <= 1'b0; // Keep branch predictor active.
                            powerGateALU <= !activeProcessor; // Power gate ALU if not active.
                        end
                        WLMIXED: begin
                            powerState <= POWERBALANCED;
                            targetFrequencyLevel <= 3'b011; // Balanced frequency for mixed workloads.
                            targetVoltageLevel <= 3'b011; // Balanced voltage for mixed workloads.
                            // Selective gating based on component usage.
                            powerGateALU <= 1'b0; // Keep ALU active.
                            powerGateCache <= 1'b0; // Keep cache active.
                        end
                        WLSTREAMING: begin
                            powerState <= POWERBALANCED;
                            targetFrequencyLevel <= 3'b100; // Higher frequency for streaming workloads.
                            targetVoltageLevel <= 3'b100; // Higher voltage for streaming workloads.
                            powerGateCache <= 1'b0; // Keep cache active.
                            powerGateALU <= !activeProcessor; // Power gate ALU if not active.
                        end
                        WLIRREGULAR: begin
                            // For irregular workloads, set the power state to adaptive.
                            powerState <= POWERADAPTIVE;
                            // Dynamically adjust the frequency level based on power efficiency:
                            // -> If the power efficiency is below the target, decrease the frequency level, but do not go below zero.
                            // -> If the power efficiency is significantly above the target (by more than 30), increase the frequency level, but do not exceed the maximum value of seven.
                            // This approach allows the system to adapt to unpredictable workloads using a machine learning-inspired strategy.
                            if (powerEfficiency < EFFICIENCYTARGET) begin
                                targetFrequencyLevel <= (clockFrequencyLevel > 0) ? clockFrequencyLevel - 1 : 0;
                            end else if (powerEfficiency > (EFFICIENCYTARGET + 8'd30)) begin
                                targetFrequencyLevel <= (clockFrequencyLevel < 7) ? clockFrequencyLevel + 1 : 7;
                            end
                            // Always set the voltage level to match the new frequency level to ensure safe operation.
                            targetVoltageLevel <= targetFrequencyLevel;
                        end
                        default: begin
                            powerState <= POWERBALANCED;
                            targetFrequencyLevel <= 3'b011; // Balanced frequency for irregular workloads.
                            targetVoltageLevel <= 3'b011; // Balanced voltage for irregular workloads.
                        end
                    endcase
                end

                // DVFS (Dynamic Voltage and Frequency Scaling) Transitions
                // The following logic gradually adjusts the clock frequency and voltage levels
                // to reach the target values, helping to avoid sudden changes (glitches) that could
                // destabilize the system or cause timing issues.

                // Increment the DVFS timer on every cycle. This timer is used to pace the transitions.
                timerDVFS <= timerDVFS + 1;

                // Only attempt a transition every 8 cycles (when the lowest 3 bits of timerDVFS are zero)
                // and only if there is no ongoing transition delay.
                if (timerDVFS[2:0] == 3'h0 && transitionDelay == 0) begin
                    // If the current frequency is less than the target and we are not thermally throttled,
                    // increment both the clock frequency and voltage by one step to move closer to the target.
                    // This is a gradual ramp-up.
                    if (clockFrequencyLevel < targetFrequencyLevel && !thermalThrottle) begin
                        clockFrequencyLevel <= clockFrequencyLevel + 1;
                        voltageLevel <= voltageLevel + 1;
                        transitionDelay <= 8'h4; // Insert a delay of 4 cycles to allow the system to stabilize.
                    // If the current frequency is higher than the target, decrement both the clock frequency
                    // and voltage by one step to move closer to the target. This is a gradual ramp-down.
                    end else if (clockFrequencyLevel > targetFrequencyLevel) begin
                        clockFrequencyLevel <= clockFrequencyLevel - 1;
                        voltageLevel <= voltageLevel - 1;
                        transitionDelay <= 8'h4; // Insert a delay of 4 cycles to allow the system to stabilize.
                    end
                end
                
                // Handle transition delay for DVFS (Dynamic Voltage and Frequency Scaling).
                // If a transition is in progress (transitionDelay > 0), decrement the delay counter.
                // This ensures that frequency/voltage changes are spaced out to allow the system to stabilize.
                if (transitionDelay > 0) begin
                    transitionDelay <= transitionDelay - 1;
                end

                // Power Budget Management
                // If the total power consumption exceeds the allowed power budget,
                // take corrective actions to reduce power usage.
                if (totalPowerConsumption > powerBudget) begin
                    // If the current clock frequency is above the minimum, reduce both
                    // the target frequency and voltage by one step to lower power draw.
                    if (clockFrequencyLevel > 3'b000) begin
                        targetFrequencyLevel <= clockFrequencyLevel - 1;
                        targetVoltageLevel <= voltageLevel - 1;
                    end
                    // If the processor is not actively executing instructions,
                    // enable power gating for the ALU and cache to further reduce power.
                    if (!activeProcessor) begin
                        powerGateALU <= 1'b1;
                        powerGateCache <= 1'b1;
                    end
                end

                // Adaptive Learning and Optimization
                // Every 64 cycles (when the lower 6 bits of adaptationCounter are zero),
                // update learning and adaptation parameters to improve optimization.
                if (adaptationCounter[4:0] == 5'h0) begin // Every 32 cycles.
                    // Adjust the learning rate based on the accuracy of workload prediction.
                    // If prediction accuracy is high (>200), decrease the learning rate (down to a minimum of 4).
                    if (workloadPredictionAccuracy > 8'd200) begin
                        learningRate <= (learningRate > 8'h04) ? learningRate - 8'h04 : 8'h04;
                    // If prediction accuracy is low (<100), increase the learning rate (up to a maximum of 32).
                    end else if (workloadPredictionAccuracy < 8'd100) begin
                        learningRate <= (learningRate < 8'h20) ? learningRate + 8'h04 : 8'h20;
                    end

                    // Update the adaptation rate based on the learning rate, scaled appropriately.
                    // Scale learning rate to 4-bit range (divide by 2 for better representation).
                    adaptationRate <= (learningRate >> 1) & 4'hF;
                    
                    // Calculate and accumulate energy savings.
                    // If the average power consumption is nonzero, add the difference between
                    // average and current total power to the energySaved counter.
                    if (averagePowerConsumption > 0) begin
                        energySaved <= energySaved + (averagePowerConsumption - totalPowerConsumption);
                    end
                end

                // Increment the count of optimization decisions made.
                optimizationDecisions <= optimizationDecisions + 1;
            end

            // Predictive Wake-Up for Power Gating
            // Increment the gating timer every cycle.
            gatingTimer <= gatingTimer + 1;
            // Every 16 cycles (when the lower 4 bits of gatingTimer are zero),
            // predict when components will be needed next and update wakeupPrediction accordingly.
            if (gatingTimer[3:0] == 4'h0) begin
                // Use the predicted workload format to estimate when to wake up each component.
                case (predictedWorkloadFormat)
                    WLCOMPUTE: wakeupPrediction <= 8'h08; // ALU will be needed soon.
                    WLMEMORY: wakeupPrediction <= 8'h10; // Cache will be needed soon.
                    WLCONTROL: wakeupPrediction <= 8'h06; // Branch predictor will be needed soon.
                    default: wakeupPrediction <= 8'h20; // Use a conservative estimate for unknown workloads.
                endcase

                // If the predicted wakeup time is very soon (<= 4 cycles),
                // preemptively disable power gating for ALU, cache, and branch predictor.
                if (wakeupPrediction <= 8'h04) begin
                    powerGateALU <= 1'b0;
                    powerGateCache <= 1'b0;
                    powerGateBranchPredictor <= 1'b0;
                end

                // Decrement the wakeupPrediction counter if it is greater than zero,
                // moving closer to the predicted wakeup event.
                if (wakeupPrediction > 0) wakeupPrediction <= wakeupPrediction - 1;
            end

            // Power Trend Analysis
            // Every 128 cycles (when the lower 7 bits of cycleCounter are zero),
            // analyze the trend in power consumption to detect increases or decreases.
            if (cycleCounter[6:0] == 7'h0) begin // Every 128 cycles.
                // If current power consumption is significantly higher than the average (+16),
                // increase the powerTrend indicator (up to a maximum of 255).
                if (totalPowerConsumption > averagePowerConsumption + 8'h10) begin
                    powerTrend <= (powerTrend < 8'd240) ? powerTrend + 8'h10 : 8'd255;
                // If current power consumption is significantly lower than the average (-16),
                // decrease the powerTrend indicator (down to a minimum of 0).
                end else if (totalPowerConsumption < averagePowerConsumption - 8'h10) begin
                    powerTrend <= (powerTrend > 8'h10) ? powerTrend - 8'h10 : 8'h00;
                // If power consumption is stable, set the trend to a neutral value (128).
                end else begin
                    powerTrend <= 8'h80; // Neutral, stable trend.
                end
            end
        end
    end

    // OUTPUT ASSIGNMENTS
    // Assign the optimizationQuality output based on power efficiency.
    // If efficiency exceeds the target, output the maximum value (255).
    // Otherwise, scale the efficiency to a 0-255 range relative to the target.
    assign optimizationQuality = (powerEfficiency > EFFICIENCYTARGET) ?
                                  8'd255 : (powerEfficiency * 255) / EFFICIENCYTARGET;
    // Assign the powerOptimizationActive output to indicate if optimization is active.
    // Optimization is active if not in a critical power state, no emergency, and classification is valid.
    assign powerOptimizationActive = (powerState != POWERCRITICAL) &&
                                    (emergencyLevel == 0) && classificationValid;

endmodule

    

    
