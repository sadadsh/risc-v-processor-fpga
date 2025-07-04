`timescale 1ns / 1ps

// ARITHMETIC LOGIC UNIT TESTBENCH
// Engineer: Sadad Haidari

// Comprehensive testing of all arithmetic logic unit funtions and performance monitoring.

module alu_tb();
    reg clk;
    reg reset;
    // INTERFACE SIGNALS
    reg [31:0] operandA, operandB;
    reg [3:0] op;
    reg enALU;
    wire [31:0] result;
    wire flagZero;
    // PERFORMANCE MONITORING SIGNALS
    wire [31:0] operationTotal;
    wire [31:0] operationMostUsed;
    wire [7:0] estimatedPower;
    wire operationActive;
    // OPERATION CODES
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam SLT  = 4'b0101;
    localparam SLTU = 4'b0110;
    localparam SLL  = 4'b0111;
    localparam SRL  = 4'b1000;
    localparam SRA  = 4'b1001;
    // TEST VARIABLES
    reg [31:0] expectedResult;
    integer testCount;
    integer passCount;
    integer failCount;
    
    // INSTANTIATE UNIT UNDER TESTING
    alu uut (
        .clk(clk),
        .reset(reset),
        .operandA(operandA),
        .operandB(operandB),
        .op(op),
        .enALU(enALU),
        .result(result),
        .flagZero(flagZero),
        .operationTotal(operationTotal),
        .operationMostUsed(operationMostUsed),
        .estimatedPower(estimatedPower),
        .operationActive(operationActive)
    );
    // 100MHz CLOCK
    initial begin
        clk = 0; // Start with clock low.
        forever #5 clk = ~clk; // 5ns toggles.
    end
    
    // TASKS
    task testOp;
        input [3:0] operation;
        input [31:0] a, b, expected;
        input [200 * 8 - 1:0] description;
        begin
            @(posedge clk);
            operandA = a;
            operandB = b;
            op = operation;
            enALU = 1;
            
            @(posedge clk);
            #1;
            testCount = testCount + 1;
            
            if (result == expected) begin
                $display("PASS: %s | 0x%h op 0x%h = 0x%h | Power: %d", description, a, b, result, estimatedPower);
                passCount = passCount + 1;
            end else begin
                $display("FAIL: %s | Expected: 0x%h, Got: 0x%h", description, expected, result);
                failCount = failCount + 1;
            end
            enALU = 0;
        end
    endtask
    
    task testZF;
        input [3:0] operation;
        input [31:0] a, b;
        input [200 * 8 - 1:0] description;
        begin
            @(posedge clk);
            operandA = a;
            operandB = b;
            op = operation;
            enALU = 1;
            
            @(posedge clk);
            enALU = 0;
            #1;
            
            testCount = testCount + 1;
            
            if (flagZero == (result == 32'h0)) begin
                $display("PASS: Zero Flag Test - %s | Result: 0x%h, Zero: %b", description, result, flagZero);
                passCount = passCount + 1;
            end else begin
                $display("FAIL: Zero Flag incorrect for %s", description);
                failCount = failCount + 1;
            end
        end
    endtask
    
    task testPM;
        begin
            $display("Performing multiple operation to test performance counters...");
            
            // Perform several ADD operations.
            repeat(5) begin
                testOp(ADD, 32'd1, 32'd1, 32'd2, "Performance Test ADD");
            end
            // Perform several SUB operations.
            repeat(3) begin
                testOp(SUB, 32'd10, 32'd5, 32'd5, "Performance Test SUB");
            end
            
            @(posedge clk);
            $display("PERFORMANCE STATISTICS:");
            $display("    Total operations: %d", operationTotal);
            $display("    Most used operation: %d", operationMostUsed);
            $display("    Operation active: %b", operationActive);
        end
    endtask
    
    task testPC;
        begin
            $display("Testing power consumption for different operations...");
            // Test each operation type and report power
            testOp(ADD, 32'd1, 32'd1, 32'd2, "Power Test ADD");      // Should show power = 10
            testOp(SUB, 32'd1, 32'd1, 32'd0, "Power Test SUB");      // Should show power = 12  
            testOp(AND, 32'hFF, 32'hFF, 32'hFF, "Power Test AND");   // Should show power = 8
            testOp(SLL, 32'd1, 32'd4, 32'd16, "Power Test SLL");     // Should show power = 20
            testOp(SRA, 32'h80000000, 32'd1, 32'hC0000000, "Power Test SRA");  // Should show power = 22

        end
    endtask
    
    // TEST PROCEDURE
    initial begin
    testCount = 0;
    passCount = 0;
    failCount = 0;
    reset = 1;
    operandA = 0;
    operandB = 0;
    op = 0;
    enALU = 0;
    
    #20; // Wait 20 time units in reset.
    reset = 0; // Release reset.
    #10; // Wait for things to settle.
    reset = 1;
    
    $display("===============================");
    $display("     FIRST RISC-V ALU TEST     ");
    $display("===============================");
    
    // TEST 1: Basic Addition
    $display("Test 1: Addition Operations");
    testOp(ADD, 32'd15, 32'd25, 32'd40, "15 + 25");
    testOp(ADD, 32'd0, 32'd0, 32'd0, "0 + 0");
    testOp(ADD, 32'hFFFFFFFF, 32'd1, 32'd0, "0xFFFFFFFF + 1 (overflow)");
    
    // TEST 2: Subtraction
    $display("Test 2: Subtraction Operations");
    testOp(SUB, 32'd50, 32'd30, 32'd20, "50 - 30");
    testOp(SUB, 32'd10, 32'd10, 32'd0, "10 - 10");
    testOp(SUB, 32'd5, 32'd10, 32'hFFFFFFFB, "5 - 10 (negative)"); // Negative result in 2's complement.
    
    // TEST 3: Logical Operations
    $display("Test 3: Logical Operations");
    testOp(AND, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'h00000000, "AND operation"); // No bits match.
    testOp(AND, 32'hFFFFFFFF, 32'h12345678, 32'h12345678, "AND with all 1s"); // AND with 1 = unchanged.
    
    testOp(OR, 32'hF0F0F0F0, 32'h0F0F0F0F, 32'hFFFFFFFF, "OR operation"); // All bits set.
    testOp(OR, 32'h00000000, 32'h12345678, 32'h12345678, "OR with zero"); // OR with 0 = unchanged.
    
    testOp(XOR, 32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, "XOR operation"); // Alternating patterns.
    testOp(XOR, 32'h12345678, 32'h12345678, 32'h00000000, "XOR with self"); // XOR with self = 0.
    
    // TEST 4: Comparison Operations
    $display("Test 4: Comparison Operation");
    testOp(SLT, 32'd10, 32'd20, 32'd1, "10 < 20 (signed)"); // 1 = True, 0 = False
    testOp(SLT, 32'd20, 32'd10, 32'd0, "20 < 10 (signed)");
    testOp(SLT, 32'hFFFFFFFF, 32'd1, 32'd1, "-1 < 1 (signed)"); // 0xFFFFFFFF = -1 (SIGNED)
    
    testOp(SLTU, 32'd10, 32'd20, 32'd1, "10 < 20 (unsigned)"); // Same numbers, unsigned comparison.
    testOp(SLTU, 32'hFFFFFFFF, 32'd1, 32'd0, "0xFFFFFFFF < 1 (unsigned)"); // 0xFFFFFFFF is a large positive in unsigned.
    
    // TEST 5: Shift Operations
    $display("Test 5: Shift Operations");
    testOp(SLL, 32'd1, 32'd4, 32'd16, "1 << 4"); // 1 shifted left 4 = 16 (2^4)
    testOp(SLL, 32'h12345678, 32'd8, 32'h34567800, "Shift left 8 bits"); // Bits move left, zeros fill right.
    
    testOp(SRL, 32'h80000000, 32'd4, 32'h08000000, "Logical right shift"); // Zeros fill from left.
    testOp(SRL, 32'hFFFFFFFF, 32'd8, 32'h00FFFFFF, "Right shift with 1s"); // Logical = zero fill.
    
    testOp(SRA, 32'h80000000, 32'd4, 32'hF8000000, "Arithmetic right shift"); // Sign bit (1) fills from left.
    testOp(SRA, 32'h7FFFFFFF, 32'd4, 32'h07FFFFFF, "Arithmetic right shift positive"); // Sign bit (0) fills from left.
    
    // TEST 6: Zero Flag Testing
    $display("Test 6: Zero Flag Testing"); // Custom task for zero flag testing.
    testZF(ADD, 32'd0, 32'd0, "Zero addition");
    testZF(SUB, 32'd100, 32'd100, "Equal subtraction");
    testZF(AND, 32'hF0F0F0F0, 32'h0F0F0F0F, "AND resulting in zero");
    testZF(XOR, 32'h5ADAD, 32'h5ADAD, "XOR with self (literally)");
    
    // TEST 7: Performance Monitoring
    $display("Test 7: Performance Monitoring");
    testPM();
    
    // TEST 8: Power Consumption
    $display("Test 8: Power Consumption");
    testPC();
    
    // FINAL RESULTS
    $display("===============================");
    $display("      ALU TEST SUMMARIZED      ");
    $display("===============================");
    $display("Total Tests: %d", testCount);
    $display("Passed: %d", passCount);
    $display("Failed: %d", failCount);
    $display("Success Rate: %d%%", (passCount * 100) / testCount);
    
    if (failCount == 0) begin
        $display("ALL TESTS PASSED! ALU is prepared for processor integration!");
    end else begin
        $display("Some tests have failed. Check implementation.");
    end
    $display("===============================");
    $display("     ALU TEST FILE COMPLETE    ");
    $display("===============================");
end

    always @(posedge clk) begin                           
        if (enALU) begin                              
            #1;
            $display("  [ALU] Op:%d, A:0x%h, B:0x%h → Result:0x%h, Power:%d", 
                     op, operandA, operandB, result, estimatedPower);
        end
    end
endmodule
