`timescale 1ns / 1ps

// SIMPLE CORE TESTBENCH
// Engineer: Sadad Haidari

// This testbench verifies that the processor can execute real RISC-V
// instructions.

// 1. Provide 32-bit RISC-V instruction words to the processor.
// 2. Processor decodes the instruction and executes it.
// 3. Verify that the correct registers were accessed and results computed.
// 4. Monitor performance metrics throughout execution.

module core_tb ();
    reg clk;
    reg reset;
    
    // Instruction Interface
    reg [31:0] instruction;
    reg validInstruction;

    // Processor Output Signals
    wire completeInstruction;
    wire [31:0] totalInstructions;
    wire [31:0] totalOperationsALU;
    wire [31:0] totalRegAccesses;
    wire [7:0] currentEstimatedPower;
    wire [4:0] mostUsedReg;
    wire [3:0] mostUsedOpsALU;

    // Debug Output Signals
    wire [4:0] rs1Debug, rs2Debug, rdDebug;
    wire [31:0] resultALUDebug;
    wire [31:0] rsData1Debug, rsData2Debug;

    // Test Management Variables
    integer testCount; // # of tests ran.
    integer passCount; // # of tests passed.
    integer failCount; // # of tests failed.

    core uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .validInstruction(validInstruction),
        .completeInstruction(completeInstruction),
        .totalInstructions(totalInstructions),
        .totalOperationsALU(totalOperationsALU),
        .totalRegAccesses(totalRegAccesses),
        .currentEstimatedPower(currentEstimatedPower),
        .mostUsedReg(mostUsedReg),
        .mostUsedOpsALU(mostUsedOpsALU),
        .rs1Debug(rs1Debug),
        .rs2Debug(rs2Debug),
        .rdDebug(rdDebug),
        .rsData1Debug(rsData1Debug),
        .rsData2Debug(rsData2Debug)
    );

    // 100MHz CLOCK
    initial begin
        clk = 0; // Start with clock low.
        forever #5 clk = ~clk; // 5ns toggles.
    end

    // TESTING TASKS
    task testInstruction;
        input [31:0] inst; // The 32-bit RISC-V instruction to test.
        input [200*8-1:0] description; // Text description of instruction.
        input [4:0] rdExpected; // Which register should be written to.
        input [31:0] resultExpected; // What result we expect to see.
        begin
            @(posedge clk);
            instruction = instr; // Send instruction to processor.
            validInstruction = 1; // Tell processor instruction is ready.

            @(posedge clk);
            validInstruction = 0; // Clear ready signal.

            wait(completeInstruction); // Waits until processor finishes.
            @(posedge clk);

            testCount = testCount + 1;

            $display("Instruction: %s", description);
            $display("  Decoded: rs1 = x%d, rs2 = x%d, rd = x%d", rs1Debug, rs2Debug, rdDebug);
            $display("  Operands: rsData1 = 0x%h, rsData2 = 0x%h", rsData1Debug, rsData2Debug);
            $display("  Result: 0x%h -> x%d", resultALUDebug, rdDebug);
            $display("  Power: %d", currentEstimatedPower);

            // Check if the test passed or failed.
            if (rdDebug == rdExpected) begin
                $display("PASS: Correct destination register.");
                passCount = passCount + 1;
            end else begin
                $display("FAIL: Expected rd = x%d, got x%d", rdExpected, rdDebug);
                failCount = failCount + 1;
            end
        end
    endtask

    task setupTestData;
        begin
            $display("Setting up test data using ADD instructions...");
            // Use the ALU to create test values so that we can
            // demonstrate how real processors work, all goes throguh
            // instructions.
            $display("Creating tests values throguh arithmetic...");
        end
    endtask

    task testAllRT;
        begin
            // RISC-V RT Instruction Format: |fun7|rs2|rs1|fun3|rd|opcode|
            // For all these tests: rs1 = x0, rs2 = x0, predictable results.
            
            // ADD x1, x0, x0   (x1 = x0 + x0 = 0 + 0 = 0)
            // Binary breakdown: 0000000_00000_00000_000_00001_0110011
            testInstruction(32'b00000000000000000000000010110011, "ADD x1, x0, x0", 5'd1, 32'h0);
            
            // SUB x2, x0, x0   (x2 = x0 - x0 = 0 - 0 = 0)
            // Binary breakdown: 0100000_00000_00000_000_00010_0110011
            // Note: funct7=0100000 distinguishes SUB from ADD
            testInstruction(32'b01000000000000000000000100110011, "SUB x2, x0, x0", 5'd2, 32'h0);
            
            // AND x3, x0, x0   (x3 = x0 & x0 = 0 & 0 = 0)
            // Binary breakdown: 0000000_00000_00000_111_00011_0110011
            // Note: funct3=111 specifies AND operation
            testInstruction(32'b00000000000000000111000110110011, "AND x3, x0, x0", 5'd3, 32'h0);
            
            // OR x4, x0, x0    (x4 = x0 | x0 = 0 | 0 = 0)
            // Binary breakdown: 0000000_00000_00000_110_00100_0110011
            // Note: funct3=110 specifies OR operation
            testInstruction(32'b00000000000000000110001000110011, "OR x4, x0, x0", 5'd4, 32'h0);
            
            // XOR x5, x0, x0   (x5 = x0 ^ x0 = 0 ^ 0 = 0)
            // Binary breakdown: 0000000_00000_00000_100_00101_0110011
            // Note: funct3=100 specifies XOR operation
            testInstruction(32'b00000000000000000100001010110011, "XOR x5, x0, x0", 5'd5, 32'h0);
            
            // SLT x6, x0, x0   (x6 = (x0 < x0) ? 1 : 0 = (0 < 0) ? 1 : 0 = 0)
            // Binary breakdown: 0000000_00000_00000_010_00110_0110011
            // Note: funct3=010 specifies SLT (set less than, signed)
            testInstruction(32'b00000000000000000010001100110011, "SLT x6, x0, x0", 5'd6, 32'h0);
            
            // SLTU x7, x0, x0  (x7 = (x0 < x0) ? 1 : 0 = (0 < 0) ? 1 : 0 = 0, unsigned comparison)
            // Binary breakdown: 0000000_00000_00000_011_00111_0110011
            // Note: funct3=011 specifies SLTU (set less than, unsigned)
            testInstruction(32'b00000000000000000011001110110011, "SLTU x7, x0, x0", 5'd7, 32'h0);
            
            $display("All basic RT instructions tested!");
        end
    endtask

    task testPM;
        begin
            $display("Testing performance monitoring features...");
            $display("Testing performance monitoring features...");
            
            // Execute several ADD instructions to build up statistics.
            // This tests that our performance counters are working correctly.
            repeat(5) begin  // Execute 5 ADD instructions.
                testInstruction(32'b00000000000000000000000010110011, "Performance test ADD", 5'd1, 32'h0);
            end
            
            // Execute several SUB instructions.
            // This should make SUB operations show up in our statistics.
            repeat(3) begin  // Execute 3 SUB instructions.
                testInstruction(32'b01000000000000000000000100110011, "Performance test SUB", 5'd2, 32'h0);
            end
            
            // Display the performance monitoring results
            // This shows our innovation in action!
            $display("Performance monitoring results:");
            $display("  Instructions executed: %d", totalInstructions); // Should be 8 (5 ADD + 3 SUB).
            $display("  ALU operations: %d", totalOperationsALU); // Should match instructions.
            $display("  Register accesses: %d", totalRegAccesses); // Should be higher (multiple per instruction).
            $display("  Most used register: x%d", mostUsedReg); // Should show which register accessed most.
            $display("  Most used ALU op: %d", mostUsedOpsALU); // Should be 0 (ADD) since we did 5 ADDs vs 3 SUBs.
        end
    endtask


    // BEGIN TEST PROCEDURE
    initial begin
        testCount = 0;
        passCount = 0;
        failCount = 0;
        reset = 0;
        instruction = 32'h0;
        validInstruction = 32'h0;
        #20;
        reset = 1;
        #10;

        $display("=========================================");
        $display("        First Processor Test Suite       ");
        $display("=========================================");

        // TEST 1: Initialize Registers with Data
        $display("Test 1: Setting up Initial Register Values");
        // Manual data loading onto registers for testing.
        // In a real processor, this would come from memory or instructions.
        // For testing, I'm going to use ADD instructions to set up values.

        // ADD x1, x0, x0  -> x1 = 0 + 0 = 0 (but we'll verify the instruction works)
        testInstruction(32'b00000000000000000000000010110011, "ADD x1, x0, x0", 5'd1, 32'h0);

        // TEST 2: Basic ADD Operations
        $display("\\n Test 2: Basic ADD Instructions");
        setupTestData();

        // TEST 3: Complete Instruction Set
        $display("\\n Test 3: All RT Instructions");
        testAllRT();

        // TEST 4: Performance Monitoring
        $display("\\n Test 4: Performance Monitoring")
        testPM();

        // FINAL RESULTS
        $display("\\n=========================================");
        $display("         Processor Test Summary          ");
        $display("=========================================");
        $display("Total Tests: %d", testCount);
        $display("Passed: %d", passCount);
        $display("Failed: %d", failCount);
        $display("Success Rate: %d%%", (passCount * 100) / testCount);

        if (failCount == 0) begin
                $display("ALL TESTS PASSED! ALU is prepared for processor integration!");
        end else begin
        $display("Some tests have failed. Check implementation.");
        end

        $display("\\nFinal Performance Statistics:");
        $display("  Total instructions executed: %d", totalInstructions);
        $display("  Total ALU operations: %d", totalOperationsALU);
        $display("  Total register accesses: %d", totalRegAccesses);
        $display("  Most used register: x%d", mostUsedReg);
        $display("  Most used ALU operation: %d", mostUsedOpsALU);
        
        $display("=========================================");
        $finish;
    end

    // CONTINUOUS MONITORING BLOCK
    // Runs throughout simulation so that real-time feedback
    // of the processor is given.

    always @(posedge clk) begin
        if (validInstruction) begin
            $display("  [CORE] Executing Instruction: 0x%h", instruction);
        end
        if (completeInstruction) begin
            $display("  [CORE] Instruction Complete.");
        end
    end

endmodule
