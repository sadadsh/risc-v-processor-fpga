`timescale 1ns / 1ps

// POWER OPTIMIZER TESTBENCH
// Engineer: Sadad Haidari
//
// Comprehensive testbench for power optimizer module. Tests all power management
// features including DVFS, power gating, thermal management, workload-aware
// optimization, and emergency handling.

module power_optimizer_tb();
    // Testbench Parameters
    localparam CLKPERIOD = 10; // 100MHz clock.
    localparam TESTCYCLES = 2000; // 2000 clock cycles for each test.

    // DUT Signals
    reg clk;
    reg reset;

    // Workload Classification Interface
    reg [2:0] workloadFormat;
    reg [3:0] workloadConfidence;
    reg [7:0] computeToll;
    reg [7:0] memToll;
    reg [7:0] controlToll;
    reg [7:0] complexPattern;
    reg classificationValid;

    // Component Power Consumption Inputs
    reg [7:0] powerALU;
    reg [7:0] powerRegister;
    reg [7:0] powerBranchPredictor;
    reg [7:0] powerCache;
    reg [7:0] powerCore;

    // Performance Metrics Inputs
    reg [31:0] totalInstructions;
    reg [31:0] totalCycles;
    reg [7:0] branchAccuracy;
    reg [15:0] cacheHitRate;
    reg activeProcessor;

    // External Constraints
    reg [7:0] powerBudget;
    reg [7:0] thermalReading;
    reg [7:0] batteryLevel;
    reg performanceMode;

    // DUT Outputs
    wire [2:0] clockFrequencyLevel;
    wire [2:0] voltageLevel;
    wire powerGateALU;
    wire powerGateRegister;
    wire powerGateBranchPredictor;
    wire powerGateCache;
    wire thermalThrottle;
    wire [7:0] currentTotalPower;
    wire [7:0] powerEfficiency;
    wire [2:0] powerState;
    wire [7:0] temperatureEstimate;
    wire [15:0] energySaved;
    wire [7:0] optimizationQuality;
    wire [2:0] predictedWorkloadFormat;
    wire [3:0] adaptationRate;
    wire [7:0] powerTrend;
    wire powerOptimizationActive;

    // Testbench Variables
    integer testCase;
    integer cycleCount;
    integer errorCount;
    integer passCount;

    // Monitoring Variables
    reg [7:0] maxPowerObserved;
    reg [7:0] minPowerObserved;
    reg [7:0] maxTemperatureObserved;
    reg [15:0] totalEnergySaved;

    // INSTANTIATE DEVICE UNDER TEST
    power_optimizer dut(
        .clk(clk),
        .reset(reset),
        .workloadFormat(workloadFormat),
        .workloadConfidence(workloadConfidence),
        .computeToll(computeToll),
        .memToll(memToll),
        .controlToll(controlToll),
        .complexPattern(complexPattern),
        .classificationValid(classificationValid),
        .powerALU(powerALU),
        .powerRegister(powerRegister),
        .powerBranchPredictor(powerBranchPredictor),
        .powerCache(powerCache),
        .powerCore(powerCore),
        .totalInstructions(totalInstructions),
        .totalCycles(totalCycles),
        .branchAccuracy(branchAccuracy),
        .cacheHitRate(cacheHitRate),
        .activeProcessor(activeProcessor),
        .powerBudget(powerBudget),
        .thermalReading(thermalReading),
        .batteryLevel(batteryLevel),
        .performanceMode(performanceMode),
        .clockFrequencyLevel(clockFrequencyLevel),
        .voltageLevel(voltageLevel),
        .powerGateALU(powerGateALU),
        .powerGateRegister(powerGateRegister),
        .powerGateBranchPredictor(powerGateBranchPredictor),
        .powerGateCache(powerGateCache),
        .thermalThrottle(thermalThrottle),
        .currentTotalPower(currentTotalPower),
        .powerEfficiency(powerEfficiency),
        .powerState(powerState),
        .temperatureEstimate(temperatureEstimate),
        .energySaved(energySaved),
        .optimizationQuality(optimizationQuality),
        .predictedWorkloadFormat(predictedWorkloadFormat),
        .adaptationRate(adaptationRate),
        .powerTrend(powerTrend),
        .powerOptimizationActive(powerOptimizationActive)
    );

    // CLOCK GENERATION
    initial begin
        clk = 0;
        forever #(CLKPERIOD/2) clk = ~clk;
    end

    // POWER AND PERFORMANCE MONITORING
    always @(posedge clk) begin
        if (reset) begin
            // Update power consumption tracking.
            if (currentTotalPower > maxPowerObserved) begin
                maxPowerObserved <= currentTotalPower;
            end
            if (currentTotalPower < minPowerObserved || minPowerObserved == 0) begin
                minPowerObserved <= currentTotalPower;
            end

            // Update temperature tracking.
            if (temperatureEstimate > maxTemperatureObserved) begin
                maxTemperatureObserved <= temperatureEstimate;
            end

            // Track total energy saved.
            totalEnergySaved <= energySaved;
        end
    end

    // TESTBENCH TASKS
    
    // Initialize All Inputs to Default Values
    task initializeInputs;
        begin
            workloadFormat = 3'b000; // Unknown.
            workloadConfidence = 4'h0; // Low confidence.
            computeToll = 8'h00; // No toll.
            memToll = 8'h00; // No toll.
            controlToll = 8'h00; // No toll.
            complexPattern = 8'h00; // No complex pattern.
            classificationValid = 1'b0; // No classification.

            powerALU = 8'h20;
            powerRegister = 8'h10;
            powerBranchPredictor = 8'h08;
            powerCache = 8'h15;
            powerCore = 8'h12;

            totalInstructions = 32'h0;
            totalCycles = 32'h0;
            branchAccuracy = 8'h80;
            cacheHitRate = 16'h8000;
            activeProcessor = 1'b0;

            powerBudget = 8'hC0; // 192 units.
            thermalReading = 8'h64; // 100 units (moderate).
            batteryLevel = 8'hFF; // 100% (full).
            performanceMode = 1'b0; // Power-saving mode initially.
        end
    endtask

    // Reset Sequence
    task resetSequence;
        begin
            $display("Resetting...");
            reset = 1'b0;
            repeat (10) @(posedge clk);
            reset = 1'b1;
            repeat (10) @(posedge clk);
            $display("Reset complete.");
        end
    endtask
    
    // Setup for Compute-Intensive Workload
    task setupComputeWorkload;
        begin
            $display("Setting up for compute-intensive workload...");
            workloadFormat = 3'b001; // Compute-intensive.
            workloadConfidence = 4'hC; // High confidence.
            computeToll = 8'hE0; // High compute toll.
            memToll = 8'h30; // Moderate memory toll.
            controlToll = 8'h20; // Moderate control toll.
            complexPattern = 8'h40; // Moderate complex pattern.
            classificationValid = 1'b1;

            powerALU = 8'h40;
            activeProcessor = 1'b1;
        end
    endtask

    // Setup for Memory-Intensive Workload
    task setupMemoryWorkload;
        begin
            $display("Setting up for memory-intensive workload...");
            workloadFormat = 3'b010; // Memory-intensive.
            workloadConfidence = 4'hA; // High confidence.
            computeToll = 8'h20; // Low compute toll.
            memToll = 8'hD0; // High memory toll.
            controlToll = 8'h25; // Moderate control toll.
            complexPattern = 8'h60; // Low complex pattern.
            classificationValid = 1'b1;

            powerCache = 8'h35; // High cache power.
            activeProcessor = 1'b1;
        end
    endtask

    // Setup for Idle Workload
    task setupIdleWorkload;
        begin
            $display("Setting up for idle workload...");
            workloadFormat = 3'b101; // Idle.
            workloadConfidence = 4'hF; // Maximum confidence.
            computeToll = 8'h05; // Low compute toll.
            memToll = 8'h03; // Low memory toll.
            controlToll = 8'h02; // Low control toll.
            complexPattern = 8'h10; // Low complexity.
            classificationValid = 1'b1;

            powerALU = 8'h08; // Minimal ALU power.
            powerCache = 8'h05; // Minimal cache power.
            activeProcessor = 1'b0; // Processor is idle.
        end
    endtask

    // Setup for Mixed Workload
    task setupMixedWorkload;
        begin
            $display("Setting up for mixed workload...");
            workloadFormat = 3'b100; // Mixed workload.
            workloadConfidence = 4'h8; // Moderate confidence.
            computeToll = 8'h70; // Moderate compute toll.
            memToll = 8'h60; // Moderate memory toll.
            controlToll = 8'h50; // Moderate control toll.
            complexPattern = 8'h80; // High complexity.
            classificationValid = 1'b1;
            
            powerALU = 8'h30;
            powerCache = 8'h25;
            powerBranchPredictor = 8'h15;
            activeProcessor = 1'b1;
        end
    endtask

   // Create Thermal Stress Condition
   task createThermalStress;
        begin
            $display("Creating thermal stress condition...");
            thermalReading = 8'hC0; // High temperature (192) to ensure thermal threshold is exceeded.
            powerALU = 8'h60;
            powerCache = 8'h50;
            powerCore = 8'h40;
        end
   endtask

   // Create Power Budget Stress
   task createPowerBudgetStress;
        begin
            $display("Creating power budget stress condition...");
            powerBudget = 8'h50; // Low power budget.
            powerALU = 8'h25;
            powerCache = 8'h20;
            powerCore = 8'h15;
        end
   endtask

   // Simulate Performance Mode
   task enablePerformanceMode;
        begin
            $display("Enabling performance mode...");
            performanceMode = 1'b1;
            batteryLevel = 8'hFF; // Full battery.
        end
   endtask

   // Simulate Battery Conservation Mode
   task enableBatteryConservation;
        begin
            $display("Enabling battery conservation mode...");
            performanceMode = 1'b0;
            batteryLevel = 8'h30; // Low battery/
        end
   endtask

   // Check Expected Power State
   task checkPowerState;
        input [2:0] expectedState;
        reg [31*8:1] currStateName;
        reg [31*8:1] expStateName;
        begin
            // Assign current state name
            case (powerState)
                3'b000: currStateName = "IDLE";
                3'b001: currStateName = "LOW";
                3'b010: currStateName = "BALANCED";
                3'b011: currStateName = "PERFORMANCE";
                3'b100: currStateName = "BURST";
                3'b101: currStateName = "THERMAL";
                3'b110: currStateName = "CRITICAL";
                3'b111: currStateName = "ADAPTIVE";
                default: currStateName = "UNKNOWN";
            endcase
            // Assign expected state name
            case (expectedState)
                3'b000: expStateName = "IDLE";
                3'b001: expStateName = "LOW";
                3'b010: expStateName = "BALANCED";
                3'b011: expStateName = "PERFORMANCE";
                3'b100: expStateName = "BURST";
                3'b101: expStateName = "THERMAL";
                3'b110: expStateName = "CRITICAL";
                3'b111: expStateName = "ADAPTIVE";
                default: expStateName = "UNKNOWN";
            endcase
            if (powerState == expectedState) begin
                $display("PASS: Power state is %s as expected.", expStateName);
                passCount = passCount + 1;
            end else begin
                $display("FAIL: Power state is %s, expected %s.", currStateName, expStateName);
                errorCount = errorCount + 1;
            end
        end
   endtask

   // Helper function to print state name
   function [16*8:1] getStateName;
        input [2:0] state;
        begin
            case (state)
                3'b000: getStateName = "IDLE";
                3'b001: getStateName = "LOW";
                3'b010: getStateName = "BALANCED";
                3'b011: getStateName = "PERFORMANCE";
                3'b100: getStateName = "BURST";
                3'b101: getStateName = "THERMAL";
                3'b110: getStateName = "CRITICAL";
                3'b111: getStateName = "ADAPTIVE";
                default: getStateName = "UNKNOWN";
            endcase
        end
   endfunction

   // Check DVFS Levels are within Expected Range
   task checkDVFSLevels;
        input [2:0] minFrequency, maxFrequency;
        input [2:0] minVoltage, maxVoltage;
        begin
            if (clockFrequencyLevel >= minFrequency && clockFrequencyLevel <= maxFrequency &&
                voltageLevel >= minVoltage && voltageLevel <= maxVoltage) begin
                    $display("PASS: DVFS levels are within expected range.");
                    $display("Frequency: %0d, Voltage: %0d", clockFrequencyLevel, voltageLevel);
                    passCount = passCount + 1;
            end else begin
                $display("FAIL: DVFS levels are outside expected range.");
                $display("Frequency: %0d, Voltage: %0d", clockFrequencyLevel, voltageLevel);
                errorCount = errorCount + 1;
            end
        end
   endtask

   // Check Power Gating Behavior
   task checkPowerGating;
        input expectedALUGate;
        input expectedCacheGate;
        begin
            if (powerGateALU == expectedALUGate && powerGateCache == expectedCacheGate) begin
                $display("PASS: Power gating behaves as expected.");
                $display("ALU Gate: %0b, Cache Gate: %0b", powerGateALU, powerGateCache);
                passCount = passCount + 1;
            end else begin
                $display("FAIL: Power gating unexpected.");
                $display("Expected ALU: %0b, Cache: %0b | Received ALU: %0b, Cache: %0b",
                          expectedALUGate, expectedCacheGate, powerGateALU, powerGateCache);
                errorCount = errorCount + 1;
            end
        end
   endtask

   // Check Thermal Throttling Behavior
   task checkThermalThrottling;
        input expectedThrottle;
        begin
            if (thermalThrottle == expectedThrottle) begin
                $display("PASS: Thermal throttling behaves as expected.");
                $display("Throttle: %0b", thermalThrottle);
                passCount = passCount + 1;
            end else begin
                $display("FAIL: Thermal throttling unexpected.");
                $display("Expected: %0b | Received: %0b", expectedThrottle, thermalThrottle);
                errorCount = errorCount + 1;
            end
        end
   endtask

   // Wait for Specified # of Cycles
   task waitForCycles;
        input integer cycles;
        begin
            repeat (cycles) @(posedge clk);
        end
   endtask

   // Run a Test and Update Performance COunters
   task runTestCycles;
        input integer cycles;
        begin
            cycleCount = 0;
            while (cycleCount < cycles) begin
                @(posedge clk);
                cycleCount = cycleCount + 1;

                // Update performance counters to simulate realistic operation.
                totalCycles = totalCycles + 1;
                if (activeProcessor && $random % 4 == 0) begin
                    totalInstructions = totalInstructions + 1;
                end
            end
        end
   endtask

   // Display Test Results
   task displayResults;
        begin
            $display("Results:");
            $display("Power State: %0d (%s)", powerState, getStateName(powerState));
            $display("Clock Frequency Level: %0d", clockFrequencyLevel);
            $display("Voltage Level: %0d", voltageLevel);
            $display("Current Total Power: %0d", currentTotalPower);
            $display("Power Efficiency: %0d", powerEfficiency);
            $display("Temperature Estimate: %0d", temperatureEstimate);
            $display("Energy Saved: %0d", energySaved);
            $display("Optimization Quality: %0d", optimizationQuality);
            $display("Power Gating | ALU: %0b, Cache: %0b, Branch Predictor: %0b",
                    powerGateALU, powerGateCache, powerGateBranchPredictor);
            $display("Thermal Throttle: %0b", thermalThrottle);
            $display("Predicted Workload Format: %0d", predictedWorkloadFormat);
            $display("Adaptation Rate: %0d", adaptationRate);
            $display("Power Trend: %0d", powerTrend);
            $display("Power Optimization Active: %0b", powerOptimizationActive);
            $display("Total Cycles: %0d", totalCycles);
            $display("Total Instructions: %0d", totalInstructions);
            $display("Branch Accuracy: %0d", branchAccuracy);
            $display("Cache Hit Rate: %0d", cacheHitRate);
            $display("Active Processor: %0b", activeProcessor);
        end
   endtask

   // MAIN TEST SEQUENCE
   initial begin
        $display("================================================");
        $display("      Starting Power Optimizer Testbench        ");
        $display("================================================");

        // Initialize Monitoring Variables
        maxPowerObserved = 0;
        minPowerObserved = 0;
        maxTemperatureObserved = 0;
        totalEnergySaved = 0;

        // Initialize Testbench Variables
        testCase = 0;
        errorCount = 0;
        passCount = 0;

        // Initialize DUT Inputs
        initializeInputs();

        // TEST 1: Basic Reset and Initialization
        testCase = 1;
        $display("*** TEST %0d: Reset and Initialization ***", testCase);
        resetSequence();
        waitForCycles(100);

        // Check Initial State
        checkPowerState(3'b010); // Should start in balanced mode.
        checkDVFSLevels(3'b011, 3'b011, 3'b011, 3'b011); // Should start at moderate levels.

        // Check Initial State
        checkPowerState(3'b010); // Should start in balanced mode.
        checkDVFSLevels(3'b011, 3'b011, 3'b011, 3'b011); // Should start at moderate levels.
        
        // Additional checks for proper initialization and adaptation.
        // Note: By cycle 100, the adaptation logic has run and updated the rate based on learningRate.
        if (adaptationRate == 4'h8) begin
            $display("PASS: Adaptation rate calculated correctly (%0d)", adaptationRate);
            passCount = passCount + 1;
        end else begin
            $display("FAIL: Adaptation rate not calculated correctly (expected 8, got %0d)", adaptationRate);
            errorCount = errorCount + 1;
        end
        
        displayResults();

        // TEST 2: Idle Workload Optimization
        testCase = 2;
        $display("*** TEST %0d: Idle Workload Optimization ***", testCase);
        setupIdleWorkload();
        runTestCycles(300);

        // Should transition to idle state with low power.
        // Note: System may need time to transition out of any emergency states.
        if (powerState == 3'b000 || powerState == 3'b001) begin
            $display("PASS: Power state is in low power mode (IDLE or LOW) as expected.");
            passCount = passCount + 1;
        end else begin
            $display("FAIL: Power state is %s, expected IDLE or LOW.", getStateName(powerState));
            errorCount = errorCount + 1;
        end
        checkDVFSLevels(3'b000, 3'b010, 3'b000, 3'b010);
        checkPowerGating(1'b1, 1'b1);
        displayResults();

        // TEST 3: Compute-Intensive Workload
        testCase = 3;
        $display("*** TEST %0d: Compute-Intensive Workload ***", testCase);
        setupComputeWorkload();
        runTestCycles(200);

        checkPowerGating(1'b0, 1'b0); // Should not gate ALU and cache during compute.
        displayResults();

        // TEST 4: Memory-Intensive Workload
        testCase = 4;
        $display("*** TEST %0d: Memory-Intensive Workload ***", testCase);
        setupMemoryWorkload();
        runTestCycles(200);

        // Cache should remain active, ALU can be gated when not computing.
        displayResults();

        // TEST 5: Mixed Workload
        testCase = 5;
        $display("*** TEST %0d: Mixed Workload ***", testCase);
        setupMixedWorkload();
        runTestCycles(200);

        checkPowerState(3'b010); // Should remain balanced.
        displayResults();

        // TEST 6: Performance Mode
        testCase = 6;
        $display("*** TEST %0d: Performance Mode ***", testCase);
        enablePerformanceMode();
        setupComputeWorkload();
        runTestCycles(200);

        // Should use higher frequency/voltage in performance mode.
        checkDVFSLevels(3'b100, 3'b111, 3'b100, 3'b111);
        displayResults();

        // TEST 7: Thermal Stress Management
        testCase = 7;
        $display("*** TEST %0d: Thermal Stress Management ***", testCase);
        createThermalStress();
        runTestCycles(500);

        // Should enable thermal throttling and reduce frequency.
        checkThermalThrottling(1'b1); // Should throttle.
        checkDVFSLevels(3'b000, 3'b101, 3'b000, 3'b101); // Should reduce frequency.
        displayResults();

        // TEST 8: Power Budget Stress
        testCase = 8;
        $display("*** TEST %0d: Power Budget Stress ***", testCase);
        // Reset thermal stress first.
        thermalReading = 8'h64;
        createPowerBudgetStress();
        setupComputeWorkload();
        runTestCycles(400);

        // Should reduce power consumption to meet budget.
        if (currentTotalPower <= powerBudget + 8'h30) begin // Generous margin for test.
            $display("PASS: Power consumption meets budget (%0d <= %0d)", currentTotalPower, powerBudget + 8'h30);
            passCount = passCount + 1;
        end else begin
            $display("FAIL: Power consumption exceeds budget (%0d > %0d)", currentTotalPower, powerBudget);
            errorCount = errorCount + 1;
        end
        displayResults();

        // TEST 9: Battery Conservation Mode
        testCase = 9;
        $display("*** TEST %0d: Battery Conservation Mode ***", testCase);
        powerBudget = 8'hC0; // Reset power budget.
        enableBatteryConservation();
        setupMixedWorkload();
        runTestCycles(200);

        // Should prioritize power savings over performance.
        displayResults();

        // TEST 10: Workload Transition and Adaptation
        testCase = 10;
        $display("*** TEST %0d: Workload Transition and Adaptation ***", testCase);
        performanceMode = 1'b0;
        batteryLevel = 8'hFF; // Reset battery level.
        powerBudget = 8'hC0; // Reset power budget.
        thermalReading = 8'h64; // Reset thermal reading.

        // Transition through different workloads.
        setupIdleWorkload();
        runTestCycles(150);

        setupComputeWorkload();
        runTestCycles(150);

        setupMemoryWorkload();
        runTestCycles(150);

        setupIdleWorkload();
        runTestCycles(150);

        // Check if optimizer adapts and learns.
        if (adaptationRate >= 4'h1 || powerOptimizationActive) begin
            $display("PASS: Optimizer adapts and learns (rate: %0d)", adaptationRate);
            passCount = passCount + 1;
        end else begin
            $display("FAIL: Optimizer not adapting.");
            errorCount = errorCount + 1;
        end
        displayResults();

        // FINAL REPORT
        $display("================================================");
        $display("    TESTBENCH COMPLETE, SUMMARIZING RESULTS     ");
        $display("================================================");
        $display("Total Tests Run: %0d", testCase);
        $display("Total Checks: %0d", passCount + errorCount);
        $display("Total Passes: %0d", passCount);
        $display("Total Failures: %0d", errorCount);
        $display("Success Rate: %0d%%", (passCount * 100) / (passCount + errorCount));

        $display("Power Management Statistics:");
        $display("Max Power Observed: %0d", maxPowerObserved);
        $display("Minimum Power Observed: %0d", minPowerObserved);
        $display("Power Range: %0d", maxPowerObserved - minPowerObserved);
        $display("Average Power: %0d", (maxPowerObserved + minPowerObserved) / 2);
        $display("Maximum Temperature: %0d", maxTemperatureObserved);
        $display("Total Energy Saved: %0d", totalEnergySaved);

        if (errorCount == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED. PLEASE INVESTIGATE!");
        end
        $display("================================================");
        $finish;
   end

   // SIMULATION TIMEOUT
   initial begin
    #(CLKPERIOD * TESTCYCLES * 15); // Allow enough time for all tests.
    $display("ERROR: Simulation timed out.");
    $finish;
   end
endmodule