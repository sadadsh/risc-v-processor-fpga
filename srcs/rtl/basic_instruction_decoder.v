`timescale 1ns / 1ps

// INSTRUCTION DECODER
// Engineer: Sadad Haidari

// This module takes a 32-bit RISC-V instruction and breaks it apart
// into its component fields, then generates control signals to tell
// other parts of the processor what to do.

module instruction_decoder(
    input wire [31:0] instruction, // 32-bit RISC-V instruction from memory/test-bench.
    // DECODED INSTRUCTION FIElDS
    // Wire connections to specific bits.
    output wire [6:0] opcode, // Operation code (bits 6:0) which tells us ADD vs SUB vs other.
    output wire [4:0] rd, // Destination register (bits 11:7), where result gets stored.
    output wire [2:0] fun3, // Function code 3 (bits 14:12), helps distinguish operations.
    output wire [4:0] rs1, // Source register 1 (bits 19:15), first input to ALU.
    output wire [4:0] rs2, // Source register 2 (bits 24:20), second input to ALU.
    output wire [6:0] fun7, // Function code 7 (bits 31:25), distinguishes ADD from SUB.
    // CONTROL SIGNALS FOR PROCESSOR
    // These tell the other modules what to do.
    output wire enRegWrite, // Should we write ALU result back to the register file?
    output wire enALU, // Should ALU perform operations this cycle?
    output wire [3:0] opALU, // Which ALU operation to perform?
    // INSTRUCTION TYPE IDENTIFICATION
    // Helps processor know what kind of instruction this is.
    output wire isRT, // R-type instruction (register-register operations).
    output wire isVI // Is this a valid instruction?
    );
    
    // RISC-V INSTRUCTION FORMAT CONSTANTS
    // Each instruction type has a unique opcode in the bottom 7 bits.
    localparam OPCODERT = 7'b0110011; // R-Type standard instructions.
    
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign fun3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign fun7 = instruction[31:25];
    
    // Identify instruction types by comparing opcode to known values:
    assign isRT = (opcode == OPCODERT); // True if this is ADD, SUB, AND, OR, etc.
    
    // For now, just R-Type will be supported.
    assign isVI = isRT;
    
    assign enRegWrite = isRT; // R-Type instructions always write result to destination register.
    assign enALU = isRT; // R-Type instructions always need ALU to compute result.
    
    // ALU operation mapping based on third and seventh function.
    // This will be the brain of the decoder, figuring out which ALU operation to perform.
    // RISC-V uses these for operation identification.
    // We need to convert RISC-V function codes to our ALU's operation codes.
    reg [3:0] incode; // Internal register to hold the ALU operation code.
    
    always @(*) begin
        if (isRT) begin
            // Combine the functions for unique identification of each operation.
            // The {...} syntax concatenates bits to make a 10-bit value.
            case ({fun7, fun3}) // Case statement act like a big lookup table.
            // Format: {fun7[6:0], fun3[2:0]) : opALU
            // These values come from RISC-V specification.
                {7'b0000000, 3'b000}: incode = 4'b0000;  // ADD: fun7=0000000, fun3=000
                {7'b0100000, 3'b000}: incode = 4'b0001;  // SUB: fun7=0100000, fun3=000 (note different fun7)
                {7'b0000000, 3'b111}: incode = 4'b0010;  // AND: fun7=0000000, fun3=111
                {7'b0000000, 3'b110}: incode = 4'b0011;  // OR:  fun7=0000000, fun3=110
                {7'b0000000, 3'b100}: incode = 4'b0100;  // XOR: fun7=0000000, fun3=100
                {7'b0000000, 3'b010}: incode = 4'b0101;  // SLT: fun7=0000000, fun3=010 (set less than signed)
                {7'b0000000, 3'b011}: incode = 4'b0110;  // SLTU:fun7=0000000, fun3=011 (set less than unsigned)
                {7'b0000000, 3'b001}: incode = 4'b0111;  // SLL: fun7=0000000, fun3=001 (shift left logical)
                {7'b0000000, 3'b101}: incode = 4'b1000;  // SRL: fun7=0000000, fun3=101 (shift right logical)
                {7'b0100000, 3'b101}: incode = 4'b1001;  // SRA: fun7=0100000, fun3=101 (shift right arithmetic)
                default:              incode = 4'b0000;  // Default to ADD for any unknown instruction
            endcase
        end else begin
            incode = 4'b0000; // Default operation when not R-Type.
        end
    end
    // Connect internal register to output wire.
    assign opALU = incode;
endmodule
