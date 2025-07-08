```
=========================================
 ENHANCED INSTRUCTION DECODER TESTBENCH  
=========================================
Test 1: Testing RT Instructions
Test           1:                                                                                                                                                                                          
ADD x1, x2, x3
  Instruction: 0x003100b3
  Decoded Fields:
    opcode=0x33, rd= 1, rs1= 2, rs2= 3
    fun3=0x0, fun7=0x00
    immediate=0x00000000 (signed: 0)
  Instruction Types:
    isRT=1, isIT=0, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=1, useImmediate=0, opALU=0x0
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x0, branchTaken=0
PASS: All checks passed!

Test           2:                                                                                                                                                                                          
SUB x4, x5, x6
  Instruction: 0x40628233
  Decoded Fields:
    opcode=0x33, rd= 4, rs1= 5, rs2= 6
    fun3=0x0, fun7=0x20
    immediate=0x00000000 (signed: 0)
  Instruction Types:
    isRT=1, isIT=0, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=1, useImmediate=0, opALU=0x1
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x0, branchTaken=0
PASS: All checks passed!

Test           3:                                                                                                                                                                                          
AND x7, x8, x9
  Instruction: 0x009473b3
  Decoded Fields:
    opcode=0x33, rd= 7, rs1= 8, rs2= 9
    fun3=0x7, fun7=0x00
    immediate=0x00000000 (signed: 0)
  Instruction Types:
    isRT=1, isIT=0, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=1, useImmediate=0, opALU=0x2
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x7, branchTaken=0
PASS: All checks passed!

Test 2:Testing IT Instructions
Test           4:                                                                                                                                                                                        
ADDI x1, x2, 100
  Instruction: 0x06410093
  Decoded Fields:
    opcode=0x13, rd= 1, rs1= 2, rs2= 4
    fun3=0x0, fun7=0x03
    immediate=0x00000064 (signed: 100)
  Instruction Types:
    isRT=0, isIT=1, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=1, useImmediate=1, opALU=0x0
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x0, branchTaken=0
PASS: All checks passed!

Test           5:                                                                                                                                                                                        
SLTI x3, x4, -50
  Instruction: 0xfce22193
  Decoded Fields:
    opcode=0x13, rd= 3, rs1= 4, rs2=14
    fun3=0x2, fun7=0x7e
    immediate=0xffffffce (signed: -50)
  Instruction Types:
    isRT=0, isIT=1, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=1, useImmediate=1, opALU=0x5
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x2, branchTaken=0
PASS: All checks passed!

Test           6:                                                                                                                                                                                        
XORI x5, x6, 255
  Instruction: 0x0ff34293
  Decoded Fields:
    opcode=0x13, rd= 5, rs1= 6, rs2=31
    fun3=0x4, fun7=0x07
    immediate=0x000000ff (signed: 255)
  Instruction Types:
    isRT=0, isIT=1, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=1, useImmediate=1, opALU=0x4
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x4, branchTaken=0
PASS: All checks passed!

Test 3: Testing BT Instructions
Test           7:                                                                                                                                                                                           
BEQ x1, x2, 8
  Instruction: 0x00208463
  Decoded Fields:
    opcode=0x63, rd= 8, rs1= 1, rs2= 2
    fun3=0x0, fun7=0x00
    immediate=0x00000008 (signed: 8)
  Instruction Types:
    isRT=0, isIT=0, isBT=1, isJT=0, isVI=1
  Control Signals:
    enRegWrite=0, enALU=1, useImmediate=0, opALU=0x1
  Branch/Jump Signals:
    isBranch=1, isJump=0, branchT=0x0, branchTaken=0
PASS: All checks passed!

Test           8:                                                                                                                                                                                         
BNE x3, x4, -16
  Instruction: 0xfe4198e3
  Decoded Fields:
    opcode=0x63, rd=17, rs1= 3, rs2= 4
    fun3=0x1, fun7=0x7f
    immediate=0xfffffff0 (signed: -16)
  Instruction Types:
    isRT=0, isIT=0, isBT=1, isJT=0, isVI=1
  Control Signals:
    enRegWrite=0, enALU=1, useImmediate=0, opALU=0x1
  Branch/Jump Signals:
    isBranch=1, isJump=0, branchT=0x1, branchTaken=0
PASS: All checks passed!

Test           9:                                                                                                                                                                                           BLT x5, x6, 32
  Instruction: 0x0262c063
  Decoded Fields:
    opcode=0x63, rd= 0, rs1= 5, rs2= 6
    fun3=0x4, fun7=0x01
    immediate=0x00000020 (signed: 32)
  Instruction Types:
    isRT=0, isIT=0, isBT=1, isJT=0, isVI=1
  Control Signals:
    enRegWrite=0, enALU=1, useImmediate=0, opALU=0x5
  Branch/Jump Signals:
    isBranch=1, isJump=0, branchT=0x4, branchTaken=0
PASS: All checks passed!

Test          10:                                                                                                                                                                                          
BGE x7, x8, 64
  Instruction: 0x0483d063
  Decoded Fields:
    opcode=0x63, rd= 0, rs1= 7, rs2= 8
    fun3=0x5, fun7=0x02
    immediate=0x00000040 (signed: 64)
  Instruction Types:
    isRT=0, isIT=0, isBT=1, isJT=0, isVI=1
  Control Signals:
    enRegWrite=0, enALU=1, useImmediate=0, opALU=0x5
  Branch/Jump Signals:
    isBranch=1, isJump=0, branchT=0x5, branchTaken=0
PASS: All checks passed!

Test          11:                                                                                                                                                                                       
BLTU x9, x10, 128
  Instruction: 0x08a4e063
  Decoded Fields:
    opcode=0x63, rd= 0, rs1= 9, rs2=10
    fun3=0x6, fun7=0x04
    immediate=0x00000080 (signed: 128)
  Instruction Types:
    isRT=0, isIT=0, isBT=1, isJT=0, isVI=1
  Control Signals:
    enRegWrite=0, enALU=1, useImmediate=0, opALU=0x6
  Branch/Jump Signals:
    isBranch=1, isJump=0, branchT=0x6, branchTaken=0
PASS: All checks passed!

Test          12:                                                                                                                                                                                      
BGEU x11, x12, 256
  Instruction: 0x10c5f063
  Decoded Fields:
    opcode=0x63, rd= 0, rs1=11, rs2=12
    fun3=0x7, fun7=0x08
    immediate=0x00000100 (signed: 256)
  Instruction Types:
    isRT=0, isIT=0, isBT=1, isJT=0, isVI=1
  Control Signals:
    enRegWrite=0, enALU=1, useImmediate=0, opALU=0x6
  Branch/Jump Signals:
    isBranch=1, isJump=0, branchT=0x7, branchTaken=0
PASS: All checks passed!

Test 4: Testing JT Instructions
Test          13:                                                                                                                                                                                             JAL x1, 1024
  Instruction: 0x400000ef
  Decoded Fields:
    opcode=0x6f, rd= 1, rs1= 0, rs2= 0
    fun3=0x0, fun7=0x20
    immediate=0x00000400 (signed: 1024)
  Instruction Types:
    isRT=0, isIT=0, isBT=0, isJT=1, isVI=1
  Control Signals:
    enRegWrite=1, enALU=0, useImmediate=0, opALU=0x0
  Branch/Jump Signals:
    isBranch=0, isJump=1, branchT=0x0, branchTaken=0
PASS: All checks passed!

Test          14:                                                                                                                                                                                         
JALR x2, x3, 16
  Instruction: 0x01018167
  Decoded Fields:
    opcode=0x67, rd= 2, rs1= 3, rs2=16
    fun3=0x0, fun7=0x00
    immediate=0x00000010 (signed: 16)
  Instruction Types:
    isRT=0, isIT=1, isBT=0, isJT=0, isVI=1
  Control Signals:
    enRegWrite=1, enALU=0, useImmediate=1, opALU=0x0
  Branch/Jump Signals:
    isBranch=0, isJump=1, branchT=0x0, branchTaken=0
PASS: All checks passed!

Test 5: Testing Invalid Instruction Handling
Test          15:                                                                                                                                                                                     
Invalid instruction
  Instruction: 0xffffffff
  Decoded Fields:
    opcode=0x7f, rd=31, rs1=31, rs2=31
    fun3=0x7, fun7=0x7f
    immediate=0x00000000 (signed: 0)
  Instruction Types:
    isRT=0, isIT=0, isBT=0, isJT=0, isVI=0
  Control Signals:
    enRegWrite=0, enALU=0, useImmediate=0, opALU=0x0
  Branch/Jump Signals:
    isBranch=0, isJump=0, branchT=0x7, branchTaken=0
PASS: All checks passed!

=========================================
 INSTRUCTION DECODER SUMMARIZED RESULTS  
=========================================
Total Tests:          15
Passed:          15
Failed:           0
Success Rate:         100%
ALL TESTS PASSED!
  RT instructions: Working correctly.
  IT instructions: Working correctly.
  BT instructions: Working correctly.
  JT instructions: Working correctly.

=========================================
```