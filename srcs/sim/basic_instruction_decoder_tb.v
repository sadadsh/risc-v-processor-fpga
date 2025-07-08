`timescale 1ns / 1ps

// INSTRUCTION DECODER TESTBENCH
// Engineer: Sadad Haidari

// This testbench verifies that the instruction decoder
// decodes RISC-V instructions and generates proper control signals.

module instruction_decoder_tb();
    reg [31:0] instruction;
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] fun3;
    wire [6:0] fun7;
    wire enRegWrite, enALU;
    wire [3:0] opALU;
    wire isRT, isVI;
    integer testCount = 0;
    integer passCount = 0;
    integer failCount = 0;
    
    instruction_decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .fun3(fun3),
        .rs1(rs1),
        .rs2(rs2),
        .fun7(fun7),
        .enRegWrite(enRegWrite),
        .enALU(enALU),
        .opALU(opALU),
        .isRT(isRT),
        .isVI(isVI)
    );
    
    task testDecoding;
        input [31:0] instr;
        input [6:0] expectedOpcode;
        input [4:0] expectedRd, expectedRs1, expectedRs2;
        input [2:0] expectedFun3;
        input [6:0] expectedFun7;
        input [3:0] expectedOpALU;
        input expectedIsRT, expectedIsVI;
        input [200*8-1:0] description;
        begin
            instruction = instr;
            #10;
            
            testCount = testCount + 1;
            $display("Test %d: %s", testCount, description);
            $display("  Instruction: 0x%h", instruction);
            $display("  Decoded: opcode=0x%h, rd=%d, rs1=%d, rs2=%d", opcode, rd, rs1, rs2);
            $display("  Functions: fun3=0x%h, fun7=0x%h", fun3, fun7);
            $display("  Control: enRegWrite=%b, enALU=%b, opALU=0x%h", enRegWrite, enALU, opALU);
            $display("  Flags: isRT=%b, isVI=%b", isRT, isVI);
            
            // Check results.
            if (opcode == expectedOpcode && rd == expectedRd && rs1 == expectedRs1 && 
                rs2 == expectedRs2 && fun3 == expectedFun3 && fun7 == expectedFun7 &&
                opALU == expectedOpALU && isRT == expectedIsRT && isVI == expectedIsVI) begin
                $display("  PASS");
                passCount = passCount + 1;
            end else begin
                $display("  FAIL - Expected: opcode=0x%h, rd=%d, rs1=%d, rs2=%d, fun3=0x%h, fun7=0x%h, opALU=0x%h, isRT=%b, isVI=%b", 
                         expectedOpcode, expectedRd, expectedRs1, expectedRs2, expectedFun3, expectedFun7, expectedOpALU, expectedIsRT, expectedIsVI);
                failCount = failCount + 1;
            end
            $display("");
        end
    endtask
    
    initial begin
        $display("=========================================");
        $display("      INSTRUCTION DECODER TESTBENCH      ");
        $display("=========================================");
        
        // TEST 1: ADD x1, x0, x0
        // Instruction: 0000000_00000_00000_000_00001_0110011
        testDecoding(32'b00000000000000000000000010110011, 
                    7'b0110011, 5'd1, 5'd0, 5'd0, 3'b000, 7'b0000000, 4'b0000, 1'b1, 1'b1,
                    "\nADD x1, x0, x0");
        
        // TEST 2: SUB x2, x0, x0  
        // Instruction: 0100000_00000_00000_000_00010_0110011
        testDecoding(32'b01000000000000000000000100110011,
                    7'b0110011, 5'd2, 5'd0, 5'd0, 3'b000, 7'b0100000, 4'b0001, 1'b1, 1'b1,
                    "\nSUB x2, x0, x0");
        
        // TEST 3: AND x3, x0, x0
        // Instruction: 0000000_00000_00000_111_00011_0110011
        testDecoding(32'b00000000000000000111000110110011,
                    7'b0110011, 5'd3, 5'd0, 5'd0, 3'b111, 7'b0000000, 4'b0010, 1'b1, 1'b1,
                    "\nAND x3, x0, x0");
        
        // TEST 4: OR x4, x0, x0
        // Instruction: 0000000_00000_00000_110_00100_0110011  
        testDecoding(32'b00000000000000000110001000110011,
                    7'b0110011, 5'd4, 5'd0, 5'd0, 3'b110, 7'b0000000, 4'b0011, 1'b1, 1'b1,
                    "\nOR x4, x0, x0");
        
        // TEST 5: XOR x5, x0, x0
        // Instruction: 0000000_00000_00000_100_00101_0110011
        testDecoding(32'b00000000000000000100001010110011,
                    7'b0110011, 5'd5, 5'd0, 5'd0, 3'b100, 7'b0000000, 4'b0100, 1'b1, 1'b1,
                    "\nXOR x5, x0, x0");
        
        // TEST 6: Invalid instruction.
        testDecoding(32'b00000000000000000000000010010011,
                    7'b0010011, 5'd1, 5'd0, 5'd0, 3'b000, 7'b0000000, 4'b0000, 1'b0, 1'b0,
                    "\nInvalid instruction (I-type opcode)");
        
        // RESULTS
        $display("=========================================");
        $display("        SUMMARIZED DECODER RESULTS       ");
        $display("=========================================");
        $display("Total Tests: %d", testCount);
        $display("Passed: %d", passCount);
        $display("Failed: %d", failCount);
        if (testCount > 0) begin
            $display("Success Rate: %d%%", (passCount * 100) / testCount);
        end
        
        if (failCount == 0) begin
            $display("ALL TESTS PASSED! Decoder is working!");
        end else begin
            $display("Some tests failed.");
        end
        $finish;
    end
    
endmodule