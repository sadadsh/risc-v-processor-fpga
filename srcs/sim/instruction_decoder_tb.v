
`timescale 1ns / 1ps

// ENHANCED INSTRUCTION DECODER TESTBENCH
// Engineer: Sadad Haidari

module instruction_decoder_tb();
    // TESTBENCH SIGNALS
    // Input to decoder (instruction to test).
    reg [31:0] instruction;

    // Outputs from decoder.
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] fun3;
    wire [6:0] fun7;
    wire [31:0] immediateValue;
    wire enRegWrite, enALU;
    wire [3:0] opALU;
    wire useImmediate;
    wire isBranch, isJump;
    wire [2:0] branchT;
    wire branchTaken;
    wire isRT, isIT, isBT, isJT, isVI;
    
    // Test management variables.
    integer testCount = 0;
    integer passCount = 0;
    integer failCount = 0;

    // DEVICE UNDER TEST INSTANTIATION
    instruction_decoder uut (
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
        .branchTaken(branchTaken),
        .isRT(isRT),
        .isIT(isIT),
        .isBT(isBT),
        .isJT(isJT),
        .isVI(isVI)
    );

    // INSTRUCTION TESTING TASK
    task testInstruction;
        input [31:0] inst;
        input [200*8-1:0] description;
        input expectedIsRT, expectedIsIT, expectedIsBT, expectedIsJT;
        input expectedEnRegWrite, expectedEnALU, expectedUseImmediate;
        input [3:0] expectedOpALU;
        input [31:0] expectedImmediateValue;
        input expectedIsBranch, expectedIsJump;

        begin
            // Send instruction to decoder.
            instruction = inst;
            #10; // Wait for combinational logic to settle.
            
            testCount = testCount + 1;
            
            // DISPLAY DETAILED TEST RESULTS
            $display("Test %d: %s", testCount, description);
            $display("  Instruction: 0x%h", inst);
            $display("  Decoded Fields:");
            $display("    opcode=0x%h, rd=%d, rs1=%d, rs2=%d", opcode, rd, rs1, rs2);
            $display("    fun3=0x%h, fun7=0x%h", fun3, fun7);
            $display("    immediate=0x%h (signed: %0d)", immediateValue, $signed(immediateValue));
            $display("  Instruction Types:");
            $display("    isRT=%b, isIT=%b, isBT=%b, isJT=%b, isVI=%b", 
                     isRT, isIT, isBT, isJT, isVI);
            $display("  Control Signals:");
            $display("    enRegWrite=%b, enALU=%b, useImmediate=%b, opALU=0x%h", 
                     enRegWrite, enALU, useImmediate, opALU);
            $display("  Branch/Jump Signals:");
            $display("    isBranch=%b, isJump=%b, branchT=0x%h, branchTaken=%b", 
                     isBranch, isJump, branchT, branchTaken);

            // COMPREHENSIVE VERIFICATION
            // Check all aspects of the decoder output.
            if (isRT == expectedIsRT &&
                isIT == expectedIsIT &&
                isBT == expectedIsBT &&
                isJT == expectedIsJT &&
                enRegWrite == expectedEnRegWrite &&
                enALU == expectedEnALU &&
                useImmediate == expectedUseImmediate &&
                opALU == expectedOpALU &&
                immediateValue ==  expectedImmediateValue &&
                isBranch == expectedIsBranch &&
                isJump == expectedIsJump) begin
                    $display("PASS: All checks passed!");
                    passCount = passCount + 1;
                end else begin
                    $display("FAIL: Mismatch detected!");
                    $display("    Expected: isRT=%b, isIT=%b, isBT=%b, isJT=%b", 
                         expectedIsRT, expectedIsIT, expectedIsBT, expectedIsJT);
                    $display("    Expected: enRegWrite=%b, enALU=%b, useImmediate=%b, opALU=0x%h", 
                         expectedEnRegWrite, expectedEnALU, expectedUseImmediate, expectedOpALU);
                    $display("    Expected: immediate=0x%h, isBranch=%b, isJump=%b", 
                          expectedImmediateValue, expectedIsBranch, expectedIsJump);
                    failCount = failCount + 1;
                end
                $display("");
        end
    endtask

    // TEST SEQUENCE
    initial begin
        $display("=========================================");
        $display(" ENHANCED INSTRUCTION DECODER TESTBENCH  ");
        $display("=========================================");
                
        // TEST 1: RT INSTRUCTIONS
        $display("Test 1: Testing RT Instructions");
        
        // ADD x1, x2, x3 (0000000_00011_00010_000_00001_0110011)
        testInstruction(32'b00000000001100010000000010110011, "\nADD x1, x2, x3",
                       1, 0, 0, 0,        // isRT=1, others=0
                       1, 1, 0,           // enRegWrite=1, enALU=1, useImmediate=0
                       4'b0000,           // opALU=ADD
                       32'h0,             // immediate=0 (not used)
                       0, 0);             // isBranch=0, isJump=0
        
        // SUB x4, x5, x6 (0100000_00110_00101_000_00100_0110011)
        testInstruction(32'b01000000011000101000001000110011, "\nSUB x4, x5, x6",
                       1, 0, 0, 0,        // isRT=1, others=0
                       1, 1, 0,           // enRegWrite=1, enALU=1, useImmediate=0
                       4'b0001,           // opALU=SUB
                       32'h0,             // immediate=0 (not used)
                       0, 0);             // isBranch=0, isJump=0
        
        // AND x7, x8, x9 (0000000_01001_01000_111_00111_0110011)
        testInstruction(32'b00000000100101000111001110110011, "\nAND x7, x8, x9",
                       1, 0, 0, 0,        // isRT=1, others=0
                       1, 1, 0,           // enRegWrite=1, enALU=1, useImmediate=0
                       4'b0010,           // opALU=AND
                       32'h0,             // immediate=0 (not used)
                       0, 0);             // isBranch=0, isJump=0
        
        // TEST 2: IT INSTRUCTIONS
        // Test immediate instructions needed for comprehensive processor.
        $display("Test 2:Testing IT Instructions");
        
        // ADDI x1, x2, 100 (000001100100_00010_000_00001_0010011)
        // immediate = 100 = 0x64
        testInstruction(32'b00000110010000010000000010010011, "\nADDI x1, x2, 100",
                       0, 1, 0, 0,        // isIT=1, others=0
                       1, 1, 1,           // enRegWrite=1, enALU=1, useImmediate=1
                       4'b0000,           // opALU=ADD
                       32'h64,            // immediate=100
                       0, 0);             // isBranch=0, isJump=0
        
        // SLTI x3, x4, -50 (111111001110_00100_010_00011_0010011)
        // immediate = -50 = 0xFFFFFFCE (sign extended)
        testInstruction(32'b11111100111000100010000110010011, "\nSLTI x3, x4, -50",
                       0, 1, 0, 0,        // isIT=1, others=0
                       1, 1, 1,           // enRegWrite=1, enALU=1, useImmediate=1
                       4'b0101,           // opALU=SLT
                       32'hFFFFFFCE,      // immediate=-50 (sign extended)
                       0, 0);             // isBranch=0, isJump=0
        
        // XORI x5, x6, 255 (000011111111_00110_100_00101_0010011)
        testInstruction(32'b00001111111100110100001010010011, "\nXORI x5, x6, 255",
                       0, 1, 0, 0,        // isIT=1, others=0
                       1, 1, 1,           // enRegWrite=1, enALU=1, useImmediate=1
                       4'b0100,           // opALU=XOR
                       32'h00FF,          // immediate=255
                       0, 0);             // isBranch=0, isJump=0
        
        // TEST 3: BT INSTRUCTIONS
        // Test branch instructions that enable our adaptive branch predictor.
        $display("Test 3: Testing BT Instructions");
        
        // BEQ x1, x2, 8 (0000000_00010_00001_000_01000_1100011)
        // Branch immediate: offset = 8, encoded as scattered bits
        testInstruction(32'b00000000001000001000010001100011, "\nBEQ x1, x2, 8",
                       0, 0, 1, 0,        // isBT=1, others=0
                       0, 1, 0,           // enRegWrite=0, enALU=1, useImmediate=0
                       4'b0001,           // opALU=SUB (for comparison)
                       32'h8,             // immediate=8 (branch offset)
                       1, 0);             // isBranch=1, isJump=0
        
        // BNE x3, x4, -16 (encoded with negative offset)
        testInstruction(32'hFE4198E3, "\nBNE x3, x4, -16",
                       0, 0, 1, 0,        // isBT=1, others=0
                       0, 1, 0,           // enRegWrite=0, enALU=1, useImmediate=0
                       4'b0001,           // opALU=SUB (for comparison)
                       32'hFFFFFFF0,      // immediate=-16 (sign extended)
                       1, 0);             // isBranch=1, isJump=0

        // BLT x5, x6, 32 (0000001_00110_00101_100_00000_1100011)
        testInstruction(32'b00000010011000101100000001100011, "BLT x5, x6, 32",
                       0, 0, 1, 0,        // isBT=1, others=0
                       0, 1, 0,           // enRegWrite=0, enALU=1, useImmediate=0
                       4'b0101,           // opALU=SLT (signed less than)
                       32'h20,            // immediate=32 (branch offset)
                       1, 0);             // isBranch=1, isJump=0
        
        // BGE x7, x8, 64 (0000010_01000_00111_101_00000_1100011)
        testInstruction(32'b00000100100000111101000001100011, "\nBGE x7, x8, 64",
                       0, 0, 1, 0,        // isBT=1, others=0
                       0, 1, 0,           // enRegWrite=0, enALU=1, useImmediate=0
                       4'b0101,           // opALU=SLT (for >= comparison)
                       32'h40,            // immediate=64 (branch offset)
                       1, 0);             // isBranch=1, isJump=0
        
        // BLTU x9, x10, 128 (0000100_01010_01001_110_00000_1100011)
        testInstruction(32'b00001000101001001110000001100011, "\nBLTU x9, x10, 128",
                       0, 0, 1, 0,        // isBT=1, others=0
                       0, 1, 0,           // enRegWrite=0, enALU=1, useImmediate=0
                       4'b0110,           // opALU=SLTU (unsigned less than)
                       32'h80,            // immediate=128 (branch offset)
                       1, 0);             // isBranch=1, isJump=0
        
        // BGEU x11, x12, 256 (0001000_01100_01011_111_00000_1100011)
        testInstruction(32'b00010000110001011111000001100011, "\nBGEU x11, x12, 256",
                       0, 0, 1, 0,        // isBT=1, others=0
                       0, 1, 0,           // enRegWrite=0, enALU=1, useImmediate=0
                       4'b0110,           // opALU=SLTU (for unsigned >= comparison)
                       32'h100,           // immediate=256 (branch offset)
                       1, 0);             // isBranch=1, isJump=0
        
        // TEST 4: JT INSTRUCTIONS (JUMP INNOVATION!)
        // Test jump instructions for unconditional control flow.
        $display("Test 4: Testing JT Instructions");
        
        // JAL x1, 1024 (jump and link with large offset)
        // JAL immediate encoding: [20|10:1|11|19:12] scattered in instruction
        // For offset 1024 = 0x400, we need to encode this in JAL format
        testInstruction(32'b01000000000000000000000011101111, "JAL x1, 1024",
                       0, 0, 0, 1,        // isJT=1, others=0
                       1, 0, 0,           // enRegWrite=1 (save PC+4), enALU=0, useImmediate=0
                       4'b0000,           // opALU=0 (not used)
                       32'h400,           // immediate=1024 (jump offset)
                       0, 1);             // isBranch=0, isJump=1
        
        // JALR x2, x3, 16 (jump and link register)
        // JALR: 000000010000_00011_000_00010_1100111
        testInstruction(32'b00000001000000011000000101100111, "\nJALR x2, x3, 16",
                       0, 1, 0, 0,        // isIT=1 (JALR is I-type variant)
                       1, 0, 1,           // enRegWrite=1, enALU=0, useImmediate=1
                       4'b0000,           // opALU=ADD (for address calculation)
                       32'h10,            // immediate=16 (offset from register)
                       0, 1);             // isBranch=0, isJump=1
        
        // TEST 5: INVALID INSTRUCTION HANDLING
        // Test that invalid instructions are properly rejected
        $display("Test 5: Testing Invalid Instruction Handling");
        
        // Invalid opcode (should set isVI=0)
        testInstruction(32'b11111111111111111111111111111111, "\nInvalid instruction",
                       0, 0, 0, 0,        // All instruction types=0
                       0, 0, 0,           // All control signals=0
                       4'b0000,           // opALU=0 (default)
                       32'h0,             // immediate=0 (not applicable)
                       0, 0);             // isBranch=0, isJump=0
        
        // FINAL TEST RESULTS AND ANALYSIS
        $display("=========================================");
        $display(" INSTRUCTION DECODER SUMMARIZED RESULTS  ");
        $display("=========================================");
        $display("Total Tests: %d", testCount);
        $display("Passed: %d", passCount);
        $display("Failed: %d", failCount);
        
        if (testCount > 0) begin
            $display("Success Rate: %d%%", (passCount * 100) / testCount);
        end
        
        if (failCount == 0) begin
            $display("ALL TESTS PASSED!");
            $display("  RT instructions: Working correctly.");
            $display("  IT instructions: Working correctly.");
            $display("  BT instructions: Working correctly.");
            $display("  JT instructions: Working correctly.");
            $display("");
        end else begin
            $display("FAIL! %d tests failed. (-.-) The decoder needs debugging.", failCount);
        end
        $display("=========================================");
        $finish;
    end
    
    // INNOVATION READINESS VERIFICATION
    // This section specifically tests the signals needed for branch prediction.
    initial begin
        #200; // Wait for main tests to complete.
        
        $display("\nBranch Predictor Interface Verification");
        
        // Test that branch predictor interface signals are working.
        instruction = 32'b00000000001000001000010001100011; // BEQ instruction.
        #10;
        
        if (isBranch && !isJump && isVI) begin
            $display("  Branch detection working: isBranch=%b, branchT=0x%h", 
                     isBranch, branchT);
        end else begin
            $display("Branch detection failed!");
        end
        
        instruction = 32'b00000100000000000000000011101111; // JAL instruction.
        #10;
        
        if (isJump && !isBranch && isVI) begin
            $display("Jump detection working: isJump=%b, immediate=0x%h", 
                     isJump, immediateValue);
        end else begin
            $display("Jump detection failed@");
        end
    end

endmodule