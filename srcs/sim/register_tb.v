`timescale 1ns / 1ps

// PROCESSOR'S REGISTER FILE TESTBENCH
// Engineer: Sadad Haidari

module register_tb();

// Creating test signals for us to control.
reg clk; // Provide clock signal.
reg reset; // Provide when to reset.
reg [4:0] rs1, rs2, rd; // Provide which registers to use.
wire [31:0] rsData1, rsData2; // Read the output from register files.
reg enWrite; // Provide when to write.
reg [31:0] rdData; // Provide data to write.

// PERFORMANCE MONITORING
wire [31:0] regAccessCount;
wire [31:0] regWriteCount;
wire [4:0] regMostUsed;
wire powerActive;

// INSTANTIATE UNIT UNDER TEST
// This is the wiring from the register file to the test bench.
register uut(
    .clk(clk),
    .reset(reset),
    .rs1(rs1),
    .rs2(rs2),
    .rsData1(rsData1),
    .rsData2(rsData2),
    .enWrite(enWrite),
    .rd(rd),
    .rdData(rdData),
    .regAccessCount(regAccessCount),
    .regWriteCount(regWriteCount),
    .regMostUsed(regMostUsed),
    .powerActive(powerActive)
);

// 100MHz CLOCK
initial begin
    clk = 0; // Start with clock low.
    forever #5 clk = ~clk; // 5ns toggles.
end

// MAIN TEST SEQUENCE
initial begin
    // First, initialize all values to safe values.
    reset = 0;
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    enWrite = 0;
    rdData = 0;
    
    // Hold the reset for 20ns, then release.
    #20;
    reset = 1; // Release reset (ACTIVE LOW).
    #10;
    
    $display("===============================");
    $display("FIRST RISC-V REGISTER FILE TEST");
    $display("===============================");
    
    // TEST 1: Write to Register 1
    $display("Test 1: Writing 0x5ADAD to Register 1");
    @(posedge clk)
    enWrite = 1; // Enable write.
    rd = 5'd1; // Choose register 1. 
    rdData = 32'h5ADAD; // Test pattern.
    
    @(posedge clk);
    enWrite = 0;
    
    // TEST 2: Read from Register 1
    $display("Test 2: Reading from Register 1");
    rs1 = 5'd1; // Read from register 1.
    #1;
    if (rsData1 == 32'h5ADAD) begin
        $display("PASS: Read correct value 0x%h", rsData1);
    end else begin
        $display("FAIL: Expected 0x5ADAD, got 0x%h", rsData1);
    end
    
    // TEST 3: Prove x0 is 0
    $display("Test 3: Proving x0 is 0");
    rs1 = 5'd0; // Read from register 0.
    #1;
    if (rsData1 == 32'h0) begin
        $display("PASS: x0 reads as 0");
    end else begin
        $display("FAIL: x0 should read 0, got 0x%h", rsData1);
    end
    
    // TEST 4: Attempt to Write to x0
    $display("Test 4: Attempt to Write to x0");
    @(posedge clk);
    enWrite = 1;
    rd = 5'd0; // Write to x0.
    rdData = 32'h5ADAD;
    #1;
    @(posedge clk);
    enWrite = 0;
    rs1 = 5'd0; // Read x0.
    #1;
    if (rsData1 == 32'h0) begin
        $display("PASS: x0 remains 0 after write attempt");
    end else begin
        $display("FAIL: x0 was modified to 0x%h", rsData1);
    end
    
    // TEST 5: Performance Monitoring
    $display("Test 5: Testing Performance Monitoring");
    // Write to register 5 multiple times.
    repeat(3) begin // Repeat this block 3 times.
        @(posedge clk);
        enWrite = 1;
        rd = 5'd5; // Write to register 5.
        rdData = 32'h5ADAD;
    end
    enWrite = 0;
    // Read register 5 multiple times to make it the most used.
    repeat(10) begin
        @(posedge clk);
        rs1 = 5'd5; // Read register 5.
        rs2 = 5'd1; // Read register 1.
    end
    // Display performance statistics.
    @(posedge clk);
    $display("PERFORMANCE STATISTICS:");
    $display("    Total accesses: %d", regAccessCount);
    $display("    Total writes: %d", regWriteCount);
    $display("    Most used register: %d", regMostUsed);
    $display("    Power active this cycle: %b", powerActive);
    
    // Test 6: Power Monitoring
    $display("Test 6: Power Activity Monitoring");
    @(posedge clk);
    // No register access this cycle (reading x0 does not count).
    rs1 = 5'd0;
    rs2 = 5'd0;
    enWrite = 0;
    
    @(posedge clk);
    $display("    Power active (no real access): %b", powerActive);
    
    // Now using a real access.
    rs1 = 5'd5;
    @(posedge clk);
    $display("    Power active (real access): %b", powerActive);
    $display("===============================");
    $display("  REGISTER TEST FILE COMPLETE  ");
    $display("===============================");
    
    $finish;
end

// Monitor all register file activity continuously.
   always @(posedge clk) begin
    if(enWrite && rd != 0) begin // If writing to non-zero register.
        $display("   [WRITE] x%d <= 0x%h", rd, rdData);
    end
    if(rs1 != 0 || rs2 != 0) begin // If reading real registers.
        $display("   [READ] x%d = 0x%h, x%d = 0x%h", rs1, rsData1, rs2, rsData2);
    end
   end
endmodule
