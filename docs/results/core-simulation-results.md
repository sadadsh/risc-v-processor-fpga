```
=========================================
          CORE MODULE TESTBENCH          
=========================================
Testing Basic RT-Instructions
   [CORE] Executing 0x000000b3
   [CORE] Executing 0x000000b3
   [CORE] Executing 0x000000b3
   [CORE] Executing 0x000000b3
   [CORE] Executing 0x000000b3
   [CORE] Completed instruction. Register Access = 0, ALU Operations = 1, Estimated Power =   8
Test 1:                                                                                                                                                                                          
ADD x1, x0, x0
  Instruction: 0x000000b3
  Decoded: rs1=0, rs2=0, rd=1
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x1
  Expected: 0x00000000 -> x1
  Power:  13
  Performance: Instructions = 1, ALU Operations = 1, Register Accesses = 0
  Deltas: ALU Operations = 1, Register Accesses = 0
PASS: All checks passed!

   [CORE] Executing 0x40000133
   [CORE] Completed instruction. Register Access = 0, ALU Operations = 2, Estimated Power =   8
Test 2:                                                                                                                                                                                          
SUB x2, x0, x0
  Instruction: 0x40000133
  Decoded: rs1=0, rs2=0, rd=2
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x2
  Expected: 0x00000000 -> x2
  Power:  15
  Performance: Instructions = 2, ALU Operations = 2, Register Accesses = 0
  Deltas: ALU Operations = 1, Register Accesses = 0
PASS: All checks passed!

   [CORE] Executing 0x000071b3
   [CORE] Completed instruction. Register Access = 0, ALU Operations = 3, Estimated Power =   8
Test 3:                                                                                                                                                                                          
AND x3, x0, x0
  Instruction: 0x000071b3
  Decoded: rs1=0, rs2=0, rd=3
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x3
  Expected: 0x00000000 -> x3
  Power:  11
  Performance: Instructions = 3, ALU Operations = 3, Register Accesses = 0
  Deltas: ALU Operations = 1, Register Accesses = 0
PASS: All checks passed!

   [CORE] Executing 0x00006233
   [CORE] Completed instruction. Register Access = 0, ALU Operations = 4, Estimated Power =   8
Test 4:                                                                                                                                                                                           
OR x4, x0, x0
  Instruction: 0x00006233
  Decoded: rs1=0, rs2=0, rd=4
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x4
  Expected: 0x00000000 -> x4
  Power:  11
  Performance: Instructions = 4, ALU Operations = 4, Register Accesses = 0
  Deltas: ALU Operations = 1, Register Accesses = 0
PASS: All checks passed!

   [CORE] Executing 0x000042b3
   [CORE] Completed instruction. Register Access = 0, ALU Operations = 5, Estimated Power =   8
Test 5:                                                                                                                                                                                          
XOR x5, x0, x0
  Instruction: 0x000042b3
  Decoded: rs1=0, rs2=0, rd=5
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x5
  Expected: 0x00000000 -> x5
  Power:  12
  Performance: Instructions = 5, ALU Operations = 5, Register Accesses = 0
  Deltas: ALU Operations = 1, Register Accesses = 0
PASS: All checks passed!

Testing with Non-Zero Register Values...
   [CORE] Executing 0x002081b3
   [CORE] Completed instruction. Register Access = 0, ALU Operations = 6, Estimated Power =   8
Test 6:                                                                                                                                                                                          
ADD x3, x1, x2
  Instruction: 0x002081b3
  Decoded: rs1=1, rs2=2, rd=3
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x3
  Expected: 0x00000000 -> x3
  Power:  18
  Performance: Instructions = 6, ALU Operations = 6, Register Accesses = 1
  Deltas: ALU Operations = 1, Register Accesses = 1
PASS: All checks passed!

   [CORE] Executing 0x40118233
   [CORE] Completed instruction. Register Access = 3, ALU Operations = 7, Estimated Power =   8
Test 7:                                                                                                                                                                                          
SUB x4, x3, x1
  Instruction: 0x40118233
  Decoded: rs1=3, rs2=1, rd=4
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x4
  Expected: 0x00000000 -> x4
  Power:  20
  Performance: Instructions = 7, ALU Operations = 7, Register Accesses = 4
  Deltas: ALU Operations = 1, Register Accesses = 3
PASS: All checks passed!

   [CORE] Executing 0x003172b3
   [CORE] Completed instruction. Register Access = 6, ALU Operations = 8, Estimated Power =   8
Test 8:                                                                                                                                                                                          
AND x5, x2, x3
  Instruction: 0x003172b3
  Decoded: rs1=2, rs2=3, rd=5
  Operands: rsData1=0x00000000, rsData2=0x00000000
  Result: 0x00000000 -> x5
  Expected: 0x00000000 -> x5
  Power:  16
  Performance: Instructions = 8, ALU Operations = 8, Register Accesses = 7
  Deltas: ALU Operations = 1, Register Accesses = 3
PASS: All checks passed!

Testing Performance Monitoring Features...
 Final Performance Statistics:
  Total Instructions Executed: 8
  Total ALU Operations: 8
  Total Register Accesses: 7
  Most Used Register: x1
  Most Used ALU Operation: 0
  Final Estimated Power:  16

=========================================
        CORE TESTBENCH SUMMARIZED        
=========================================
Total Tests:           8
Passed:           8
Failed:           0
Success Rate:         100%
PASS: All tests passed!
$finish called at time : 315 ns : File "D:/AMD/Projects/risc-v-processor-fpga/srcs/sim/core_tb.v" Line 224
INFO: [USF-XSim-96] XSim completed. Design snapshot 'core_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
```