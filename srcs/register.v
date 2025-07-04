`timescale 1ns / 1ps

// PROCESSOR'S REGISTER FILE
// Engineer: Sadad Haidari

// This processor has 32 slots (registers x0 through x31), each slot storing one 32-bit number
// for instant access. This is implemented on a Z7-20 board.
// I include descriptive comments for better understanding.

// RISC-V Rules:
// - x0 = 0 at all times, regardless of what is written to it.
// - x1 to x31 are working registers.
// - The processor can read from two registers at once and write to one register at a time.

module register(
    input wire clk, // The clock signal.
    input wire reset, // The reset signal (ACTIVE LOW).
    
    // READ PORTS
    // We take data out of these registers.
    // We use [4:0] bits since 2^5 = 32, and [31:0] for the 32-bit numbers.
    input wire [4:0] rs1, // First source register to read from (PORT 1).
    input wire [4:0] rs2, // Second source register to read from (PORT 2).
    output wire [31:0] rsData1, // The data from first register.
    output wire [31:0] rsData2, // The data from second register.
    
    // WRITE PORT
    // We put data into these registers.
    input wire enWrite, // Enable write to register (ACTIVE HIGH).
    input wire [4:0] rd, // Holds which register we choose to write to.
    input wire [31:0] rdData, // Holds the data we will write into that register.
    
    // CUSTOM PERFORMANCE MONITORING
    output wire [31:0] regAccessCount, // The number of times we've read registers.
    output wire [31:0] regWriteCount, // The number of times we've written registers.
    output wire [4:0] regMostUsed, // The register that gets used most often.
    output wire powerActive // Is the register being used right now?
    );
    
    // INTERNAL STORAGE
    reg [31:0] registers [0:31]; // A 32-bit array of registers.
    
    // PERFORMANCE MONITORING COUNTERS
    // This is to keep track of statistics for our registers.
    reg [31:0] accessCount [0:31]; // Counts accesses per register.
    reg [31:0] accessTotal; // The total access count.
    reg [31:0] writeTotal; // The total write count.
    reg [4:0] mostUsed; // Which register number is used the most.
    
    // POWER MANAGEMENT SIGNALS
    reg accessed;
    integer i;
    
   // INITIALIZE REGISTERS
   initial begin
    for (i = 0; i < 32; i = i+1)
        begin
            registers[i] = 32'h0;
            accessCount[i] = 32'h0;
        end
        accessTotal = 32'h0;
        writeTotal = 32'h0;
        mostUsed = 5'h0;
        accessed = 1'b0;
   end
   
   // COMBINATIONAL READ LOGIC
   // If register x0 then it will return 0, else return stored number.
   assign rsData1 = (rs1 == 5'h0) ? 32'h0 : registers[rs1];
   assign rsData2 = (rs2 == 5'h0) ? 32'h0 : registers[rs2];
   
   // LOGIC AND PERFORMANCE MONITORING
   // Will run on a positive edge or reset on a negative edge using continuous checks.
   always @(posedge clk or negedge reset) begin
    if (!reset) begin // Reset all registers and counters through increments when reset is pressed.
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'h0;
            accessCount[i] <= 32'h0;
        end
        accessTotal <= 32'h0;
        writeTotal <= 32'h0;
        mostUsed <= 5'h0;
        accessed <= 1'b0;
    end else begin
        accessed <= 1'b0; // Default to not accessed.
        
        // WRITE HANDLING
        // If write is enabled and we are not writing to x0, then store to specified register and
        // increment our write counter as well as mark active for power monitoring.
        if (enWrite && rd != 5'h0) begin
            registers[rd] <= rdData;
            writeTotal <= writeTotal + 1;
            accessed <= 1'b1;
        end
        
        // READ TRACKING
        // If we're reading from register that is not x0, increment the counter from
        // that register as well as total counter and mark active for power monitoring.
        if (rs1 != 5'h0) begin
            accessCount[rs1] <= accessCount[rs1] + 1;
            accessTotal <= accessTotal + 1;
            accessed <= 1'b1;
        end
        if (rs2 != 5'h0) begin
            accessCount[rs2] <= accessCount[rs2] + 1;
            accessTotal <= accessTotal + 1;
            accessed <= 1'b1;
        end
        
        // Find most accessed register.
        for (i = 1; i < 32; i = i + 1) begin
            if (accessCount[i] > accessCount[mostUsed]) begin
                mostUsed <= i;
            end
        end
    end
end

// OUTPUT ASSIGNMENTS
assign regAccessCount = accessTotal;
assign regWriteCount = writeTotal;
assign regMostUsed = mostUsed;
assign powerActive = accessed;

endmodule
