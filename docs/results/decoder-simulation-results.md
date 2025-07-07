```
=========================================
      INSTRUCTION DECODER TESTBENCH      
=========================================
Test           1:                                                                                                                                                                                          
ADD x1, x0, x0
  Instruction: 0x000000b3
  Decoded: opcode=0x33, rd= 1, rs1= 0, rs2= 0
  Functions: fun3=0x0, fun7=0x00
  Control: enRegWrite=1, enALU=1, opALU=0x0
  Flags: isRT=1, isVI=1
  PASS

Test           2:                                                                                                                                                                                          
SUB x2, x0, x0
  Instruction: 0x40000133
  Decoded: opcode=0x33, rd= 2, rs1= 0, rs2= 0
  Functions: fun3=0x0, fun7=0x20
  Control: enRegWrite=1, enALU=1, opALU=0x1
  Flags: isRT=1, isVI=1
  PASS

Test           3:                                                                                                                                                                                          
AND x3, x0, x0
  Instruction: 0x000071b3
  Decoded: opcode=0x33, rd= 3, rs1= 0, rs2= 0
  Functions: fun3=0x7, fun7=0x00
  Control: enRegWrite=1, enALU=1, opALU=0x2
  Flags: isRT=1, isVI=1
  PASS

Test           4:                                                                                                                                                                                           
OR x4, x0, x0
  Instruction: 0x00006233
  Decoded: opcode=0x33, rd= 4, rs1= 0, rs2= 0
  Functions: fun3=0x6, fun7=0x00
  Control: enRegWrite=1, enALU=1, opALU=0x3
  Flags: isRT=1, isVI=1
  PASS

Test           5:                                                                                                                                                                                          
XOR x5, x0, x0
  Instruction: 0x000042b3
  Decoded: opcode=0x33, rd= 5, rs1= 0, rs2= 0
  Functions: fun3=0x4, fun7=0x00
  Control: enRegWrite=1, enALU=1, opALU=0x4
  Flags: isRT=1, isVI=1
  PASS

Test           6:                                                                                                                                                                     
Invalid instruction (I-type opcode)
  Instruction: 0x00000093
  Decoded: opcode=0x13, rd= 1, rs1= 0, rs2= 0
  Functions: fun3=0x0, fun7=0x00
  Control: enRegWrite=0, enALU=0, opALU=0x0
  Flags: isRT=0, isVI=0
  PASS

=========================================
        SUMMARIZED DECODER RESULTS       
=========================================
Total Tests:           6
Passed:           6
Failed:           0
Success Rate:         100%
ALL TESTS PASSED! Decoder is working!
$finish called at time : 60 ns : File "D:/AMD/Projects/risc-v-processor-fpga/vivado-project/vivado-project.srcs/sim_1/new/instruction_decoder_tb.v" Line 129
INFO: [USF-XSim-96] XSim completed. Design snapshot 'instruction_decoder_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
```