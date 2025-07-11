```
================================================
      Starting Power Optimizer Testbench        
================================================
*** TEST 1: Reset and Initialization ***
Resetting...
Reset complete.
INFO: [USF-XSim-96] XSim completed. Design snapshot 'power_optimizer_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
launch_simulation: Time (s): cpu = 00:00:01 ; elapsed = 00:00:05 . Memory (MB): peak = 1864.051 ; gain = 0.000
run all
PASS: Power state is                        BALANCED as expected.
PASS: DVFS levels are within expected range.
Frequency: 3, Voltage: 3
PASS: Power state is                        BALANCED as expected.
PASS: DVFS levels are within expected range.
Frequency: 3, Voltage: 3
PASS: Adaptation rate calculated correctly (8)
Results:
Power State: 2 (        BALANCED)
Clock Frequency Level: 3
Voltage Level: 3
Current Total Power: 12
Power Efficiency: 50
Temperature Estimate: 109
Energy Saved: 65521
Optimization Quality: 70
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 0
Adaptation Rate: 8
Power Trend: 112
Power Optimization Active: 0
Total Cycles: 0
Total Instructions: 0
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 0
*** TEST 2: Idle Workload Optimization ***
Setting up for idle workload...
PASS: Power state is in low power mode (IDLE or LOW) as expected.
PASS: DVFS levels are within expected range.
Frequency: 1, Voltage: 1
PASS: Power gating behaves as expected.
ALU Gate: 1, Cache Gate: 1
Results:
Power State: 0 (            IDLE)
Clock Frequency Level: 1
Voltage Level: 1
Current Total Power: 2
Power Efficiency: 50
Temperature Estimate: 105
Energy Saved: 48
Optimization Quality: 70
Power Gating | ALU: 1, Cache: 1, Branch Predictor: 1
Thermal Throttle: 0
Predicted Workload Format: 5
Adaptation Rate: 8
Power Trend: 64
Power Optimization Active: 1
Total Cycles: 300
Total Instructions: 0
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 0
*** TEST 3: Compute-Intensive Workload ***
Setting up for compute-intensive workload...
PASS: Power gating behaves as expected.
ALU Gate: 0, Cache Gate: 0
Results:
Power State: 2 (        BALANCED)
Clock Frequency Level: 4
Voltage Level: 4
Current Total Power: 15
Power Efficiency: 0
Temperature Estimate: 110
Energy Saved: 65521
Optimization Quality: 0
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 1
Adaptation Rate: 8
Power Trend: 48
Power Optimization Active: 1
Total Cycles: 500
Total Instructions: 38
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 4: Memory-Intensive Workload ***
Setting up for memory-intensive workload...
Results:
Power State: 2 (        BALANCED)
Clock Frequency Level: 3
Voltage Level: 3
Current Total Power: 12
Power Efficiency: 91
Temperature Estimate: 109
Energy Saved: 65530
Optimization Quality: 128
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 2
Adaptation Rate: 8
Power Trend: 16
Power Optimization Active: 1
Total Cycles: 700
Total Instructions: 87
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 5: Mixed Workload ***
Setting up for mixed workload...
PASS: Power state is                        BALANCED as expected.
Results:
Power State: 2 (        BALANCED)
Clock Frequency Level: 3
Voltage Level: 3
Current Total Power: 12
Power Efficiency: 85
Temperature Estimate: 109
Energy Saved: 65532
Optimization Quality: 120
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 4
Adaptation Rate: 8
Power Trend: 0
Power Optimization Active: 1
Total Cycles: 900
Total Instructions: 144
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 6: Performance Mode ***
Enabling performance mode...
Setting up for compute-intensive workload...
PASS: DVFS levels are within expected range.
Frequency: 6, Voltage: 6
Results:
Power State: 3 (     PERFORMANCE)
Clock Frequency Level: 6
Voltage Level: 6
Current Total Power: 36
Power Efficiency: 111
Temperature Estimate: 117
Energy Saved: 65451
Optimization Quality: 157
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 1
Adaptation Rate: 8
Power Trend: 128
Power Optimization Active: 1
Total Cycles: 1100
Total Instructions: 207
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 7: Thermal Stress Management ***
Creating thermal stress condition...
PASS: Thermal throttling behaves as expected.
Throttle: 1
PASS: DVFS levels are within expected range.
Frequency: 5, Voltage: 5
Results:
Power State: 3 (     PERFORMANCE)
Clock Frequency Level: 5
Voltage Level: 5
Current Total Power: 30
Power Efficiency: 100
Temperature Estimate: 133
Energy Saved: 65475
Optimization Quality: 141
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 1
Predicted Workload Format: 1
Adaptation Rate: 8
Power Trend: 128
Power Optimization Active: 1
Total Cycles: 1600
Total Instructions: 337
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 8: Power Budget Stress ***
Creating power budget stress condition...
Setting up for compute-intensive workload...
PASS: Power consumption meets budget (36 <= 128)
Results:
Power State: 3 (     PERFORMANCE)
Clock Frequency Level: 6
Voltage Level: 6
Current Total Power: 36
Power Efficiency: 86
Temperature Estimate: 117
Energy Saved: 65441
Optimization Quality: 121
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 1
Adaptation Rate: 8
Power Trend: 128
Power Optimization Active: 1
Total Cycles: 2000
Total Instructions: 441
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 9: Battery Conservation Mode ***
Enabling battery conservation mode...
Setting up for mixed workload...
Results:
Power State: 2 (        BALANCED)
Clock Frequency Level: 3
Voltage Level: 3
Current Total Power: 12
Power Efficiency: 244
Temperature Estimate: 109
Energy Saved: 15
Optimization Quality: 255
Power Gating | ALU: 0, Cache: 0, Branch Predictor: 0
Thermal Throttle: 0
Predicted Workload Format: 4
Adaptation Rate: 8
Power Trend: 128
Power Optimization Active: 1
Total Cycles: 2200
Total Instructions: 497
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 1
*** TEST 10: Workload Transition and Adaptation ***
Setting up for idle workload...
Setting up for compute-intensive workload...
Setting up for memory-intensive workload...
Setting up for idle workload...
PASS: Optimizer adapts and learns (rate: 8)
Results:
Power State: 0 (            IDLE)
Clock Frequency Level: 1
Voltage Level: 1
Current Total Power: 2
Power Efficiency: 50
Temperature Estimate: 105
Energy Saved: 52
Optimization Quality: 70
Power Gating | ALU: 1, Cache: 1, Branch Predictor: 1
Thermal Throttle: 0
Predicted Workload Format: 5
Adaptation Rate: 8
Power Trend: 64
Power Optimization Active: 1
Total Cycles: 2800
Total Instructions: 587
Branch Accuracy: 128
Cache Hit Rate: 32768
Active Processor: 0
================================================
    TESTBENCH COMPLETE, SUMMARIZING RESULTS     
================================================
Total Tests Run: 10
Total Checks: 15
Total Passes: 15
Total Failures: 0
Success Rate: 100%
Power Management Statistics:
Max Power Observed: 36
Minimum Power Observed: 1
Power Range: 35
Average Power: 18
Maximum Temperature: 155
Total Energy Saved: 52
ALL TESTS PASSED!
================================================
```