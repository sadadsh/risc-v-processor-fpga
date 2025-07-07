`timescale 1ns / 1ps

// CORE TESTBENCH
// Engineer: Sadad Haidari

// This testbench simulates the core module of the RISC-V processor.
// It tests instruction execution correctness, pipeline behavior, performance monitoring, and power management features.

// The approach is to start with simple instructions (all using x0 register which = 0 regardless), progress to complex
// instructions using additional registers, and test to see if the performance and power management
// features respond to different workloads.

module core_tb ();
    reg clk;
    reg reset;
    // INSTRUCTION INTERFACE
    reg [31:0] instruction; // The 32-bit instruction to execute.
    reg validInstruction; // ACTIVE HIGH when instruction is valid.
    // PROCESSOR OUTPUT MONITORING
    wire completeInstruction; // Goes HIGH when instruction is done executing.
    wire [31:0] totalInstructions;
    wire [31:0] totalOperationsALU;
    wire [31:0] totalRegAccesses;
    wire [7:0] currentEstimatedPower;
    wire [4:0] mostUsedReg;
    wire [3:0] mostUsedOpsALU;
    // DEBUG SIGNAL MONITORING
    wire [4:0] rs1Debug, rs2Debug, rdDebug; // Which registers are being used?
    wire [31:0] resultALUDebug, rsData1Debug, rsData2Debug; // What data is being processed?
    
    // TEST MANAGEMENT VARIABLES
    integer testCount;
    integer passCount;
    integer failCount;

    // PERFORMANCE MONITORING VARIABLES
    integer prevRegAccesses; // Previous register access count.
    integer prevOpsALU; // Previous operation count.
    integer regAccessesDelta; // Change in register accesses after each instruction.
    integer opsALUDelta; // Change in operations after each instruction.

    // DEVICE UNDER TEST

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
        .resultALUDebug(resultALUDebug),
        .rsData1Debug(rsData1Debug),
        .rsData2Debug(rsData2Debug)
    );

    // CLOCK GENERATION 100MHz
        initial begin
        clk = 0;                            // Start with clock low
        forever #5 clk = ~clk;              // Toggle every 5ns (100MHz)
    end

    // TESTING TASKS
    task testInstruction;
        // This task sends an instruction to the core and checks the results.
        input [31:0] inst; // The instruction to test.
        input [200*8-1:0] description; // Description of the test.
        input [4:0] rdExpected; // Expected destination register.
        input [31:0] resultExpected; // Expected result in destination register.
        input [31:0] minExpectedAccesses; // Minimum expected register accesses.

        begin
            // Store counts for delta calculations.
            prevRegAccesses = totalRegAccesses;
            prevOpsALU = totalOperationsALU;
            // Send instruction to processor and signal it's prepared.
            @(posedge clk);
            instruction = inst;
            validInstruction = 1'b1;
            // Wait for processor to complete the instruction through its pipeline.
            wait(completeInstruction == 1'b1);
            @(posedge clk);
            // Clear the instruction valid signal.
            validInstruction = 1'b0;
            @(posedge clk);
            // Check results.
            testCount = testCount + 1;
            regAccessesDelta = totalRegAccesses - prevRegAccesses;
            opsALUDelta = totalOperationsALU - prevOpsALU;

            // DETAILED TEST RESULTS
            $display("Test %0d: %s", testCount, description);
            $display("  Instruction: 0x%08h", inst);
            $display("  Decoded: rs1=%0d, rs2=%0d, rd=%0d", rs1Debug, rs2Debug, rdDebug);
            $display("  Operands: rsData1=0x%08h, rsData2=0x%08h", rsData1Debug, rsData2Debug);
            $display("  Result: 0x%08h -> x%0d", resultALUDebug, rdDebug);
            $display("  Expected: 0x%08h -> x%0d", resultExpected, rdExpected);
            $display("  Power: %d", currentEstimatedPower);
            $display("  Performance: Instructions = %0d, ALU Operations = %0d, Register Accesses = %0d", totalInstructions, totalOperationsALU, totalRegAccesses);
            $display("  Deltas: ALU Operations = %0d, Register Accesses = %0d", opsALUDelta, regAccessesDelta);

            // RESULT CHECKS
            if (rdDebug == rdExpected && resultALUDebug == resultExpected && regAccessesDelta >= minExpectedAccesses && opsALUDelta >= 1) begin
                $display("PASS: All checks passed!");
                passCount = passCount + 1;
            end else begin
                $display("FAIL: One or more checks failed.");
                if (rdDebug != rdExpected)
                    $display("  -> Expected destination register = %0d, got %0d", rdExpected, rdDebug);
                if (resultALUDebug != resultExpected)
                    $display("  -> Expected result = 0x%08h, got 0x%08h", resultExpected, resultALUDebug);
                if (regAccessesDelta < minExpectedAccesses)
                    $display("  -> Expected at least %0d register accesses, got %0d", minExpectedAccesses, regAccessesDelta);
                if (opsALUDelta < 1)
                    $display("  -> Expected at least 1 ALU operation, got %0d", opsALUDelta);
                failCount = failCount + 1;
            end
            $display("");
        end
    endtask

    // NON-ZERO REGISTER TESTING
    // Test instructions that use registers other than x0. This verifies correct register reads/writes and performance tracking.
    task testNZRegisters;
        begin
            $display("Testing with Non-Zero Register Values...");
            // APPROACH
            // Use instructions that read from registers that were written to in previous instructions.
            // This should generate more register accesses and test read/write correctness since we are no longer using x0.

            // ADD x3, x1, x2 (read from x1 and x2, write to x3).
            // Binary: 0000000_00010_00001_000_00011_0110011
            testInstruction(32'b00000000001000001000000110110011, "\nADD x3, x1, x2", 5'd3, 32'h0, 1);
            
            // SUB x4, x3, x1 (read from x3 and x1, write to x4).
            // Binary: 0100000_00001_00011_000_00100_0110011
            testInstruction(32'b01000000000100011000001000110011, "\nSUB x4, x3, x1", 5'd4, 32'h0, 2);
            
            // AND x5, x2, x3 (read from x2 and x3, write to x5).
            // Binary: 0000000_00011_00010_111_00101_0110011  
            testInstruction(32'b00000000001100010111001010110011, "\nAND x5, x2, x3", 5'd5, 32'h0, 2);
        end
    endtask

    // PERFORMANCE MONITORING VERIFICATION
    // Verifies that all our innovation are working as intended.
    task testPerformanceMonitoring;
        begin
            $display("Testing Performance Monitoring Features...");
            $display(" Final Performance Statistics:");
            $display("  Total Instructions Executed: %0d", totalInstructions);
            $display("  Total ALU Operations: %0d", totalOperationsALU);
            $display("  Total Register Accesses: %0d", totalRegAccesses);
            $display("  Most Used Register: x%0d", mostUsedReg);
            $display("  Most Used ALU Operation: %0d", mostUsedOpsALU);
            $display("  Final Estimated Power: %d", currentEstimatedPower);
            $display("");
        end
    endtask
    
    // MAIN TEST SEQUENCE
    initial begin
        testCount = 0;
        passCount = 0;
        failCount = 0;
        reset = 1'b1;
        instruction = 32'h0;
        validInstruction = 1'b0;

        // RESET SEQUENCE
        #20;
        reset = 1'b0; // Assert reset (ACTIVE LOW).
        #10;
        reset = 1'b1; // Deassert reset.
        #10;

        $display("=========================================");
        $display("          CORE MODULE TESTBENCH          ");
        $display("=========================================");

        // TEST 1: BASIC RT INSTRUCTIONS
        $display("Testing Basic RT-Instructions");
        // Test each basic instruction type with expected results.
        testInstruction(32'b00000000000000000000000010110011, "\nADD x1, x0, x0", 5'd1, 32'h0, 0);
        testInstruction(32'b01000000000000000000000100110011, "\nSUB x2, x0, x0", 5'd2, 32'h0, 0);
        testInstruction(32'b00000000000000000111000110110011, "\nAND x3, x0, x0", 5'd3, 32'h0, 0);
        testInstruction(32'b00000000000000000110001000110011, "\nOR x4, x0, x0", 5'd4, 32'h0, 0);
        testInstruction(32'b00000000000000000100001010110011, "\nXOR x5, x0, x0", 5'd5, 32'h0, 0);

        // TEST 2: NON-ZERO REGISTER ACCESS VERIFICATION
        testNZRegisters();

        // TEST 3: PERFORMANCE MONITORING VERIFICATION
        testPerformanceMonitoring();

        // FINAL TEST RESULTS
        $display("=========================================");
        $display("        CORE TESTBENCH SUMMARIZED        ");
        $display("=========================================");
        $display("Total Tests: %d", testCount);
        $display("Passed: %d", passCount);
        $display("Failed: %d", failCount);

        // CALCULATE AND DISPLAY SUCCESS RATE
        if (testCount > 0) begin
            $display("Success Rate: %d%%", (passCount * 100) / testCount);
        end
        
        // OVERALL RESULT ANALYSIS
        if (failCount == 0) begin
            // ALL TESTS PASSED - CELEBRATION!
            $display("PASS: All tests passed!");
        end else begin
            // SOME TESTS FAILED - DEBUGGING NEEDED
            $display("FAIL: %d tests failed. Bugs are still present. (._.)", failCount);
        end
        $finish;
    end

    // CONTINUOUS MONITORING BLOCK
    always @(posedge clk) begin
        if (validInstruction) begin
            $display("   [CORE] Executing 0x%08h", instruction);
        end
        if (completeInstruction) begin
            $display("   [CORE] Completed instruction. Register Access = %0d, ALU Operations = %0d, Estimated Power = %d", totalRegAccesses, totalOperationsALU, currentEstimatedPower);
        end
    end
endmodule