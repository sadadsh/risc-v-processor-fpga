`timescale 1ns / 1ps

// ENHANCED INSTRUCTION DECODER - FULLY FIXED
// Engineer: Sadad Haidari

module instruction_decoder (
    input wire [31:0] instruction, // 32-bit instruction input.

    output wire [6:0] opcode, // Bits [6:0] opcode field.
    output wire [4:0] rd, // Bits [11:7] destination register.
    output wire [2:0] fun3, // Bits [14:12] fun3 field.
    output wire [4:0] rs1, // Bits [19:15] source register 1.
    output wire [4:0] rs2, // Bits [24:20] source register 2.
    output wire [6:0] fun7, // Bits [31:25] fun7 field.

    output wire [31:0] immediateValue, // Sign-extended immediate value.

    output wire enRegWrite, // Enable register write.
    output wire enALU, // Enable ALU operation.
    output wire [3:0] opALU, // Which ALU operation to perform.
    output wire useImmediate, // Use immediate value for ALU operation.

    output wire isBranch, // Is a branch instruction.
    output wire isJump, // Is a jump instruction.
    output wire [2:0] branchT, // Type of branch instruction (BEQ, BNE, etc.)
    output wire branchTaken, // Should the branch be taken (for static prediction?)

    output wire isRT, // Register-Register.
    output wire isIT, // Register-Immediate.
    output wire isBT, // Branch.
    output wire isJT, // Jump.
    output wire isVI // Valid instruction?
);
    // RISC-V INSTRUCTION FORMAT CONSTANTS
    localparam OPCODERT        = 7'b0110011;  
    localparam OPCODEIT        = 7'b0010011;
    localparam OPCODEBRANCH    = 7'b1100011;
    localparam OPCODEJAL       = 7'b1101111; 
    localparam OPCODEJALR      = 7'b1100111; 

    // INSTRUCTION FIELD EXTRACTION
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign fun3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign fun7 = instruction[31:25];

    // INSTRUCTION TYPE IDENTIFICATION
    assign isRT = (opcode == OPCODERT);                           
    assign isIT = (opcode == OPCODEIT) || (opcode == OPCODEJALR); 
    assign isBT = (opcode == OPCODEBRANCH);                       
    assign isJT = (opcode == OPCODEJAL);                          

    // VALID INSTRUCTION CHECK
    assign isVI = isRT || isIT || isBT || isJT;

    // BRANCH AND JUMP DETECTION
    assign isBranch = isBT;              
    assign isJump   = isJT || (isIT && (opcode == OPCODEJALR)); 

    // IMMEDIATE VALUE EXTRACTION - COMPLETELY FIXED
    reg [31:0] immediateExtracted;

    always @(*) begin
        case (opcode)
            OPCODEIT, OPCODEJALR: begin
                // I-type: 12-bit immediate in bits [31:20]
                immediateExtracted = {{20{instruction[31]}}, instruction[31:20]};
            end
            OPCODEBRANCH: begin
                // B-type: immediate = {sign[19:0], inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}
                // This creates: imm[12:0] where imm[0] is always 0
                immediateExtracted = {{19{instruction[31]}},  // Sign extension (19 bits)
                                      instruction[31],        // imm[12] (1 bit) 
                                      instruction[7],         // imm[11] (1 bit)
                                      instruction[30:25],     // imm[10:5] (6 bits)
                                      instruction[11:8],      // imm[4:1] (4 bits)
                                      1'b0};                  // imm[0] = 0 (1 bit)
            end 
            OPCODEJAL: begin
                // J-type: immediate = {sign[11:0], inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}
                immediateExtracted = {{11{instruction[31]}},  // Sign extension (11 bits)
                                     instruction[31],         // imm[20] (1 bit)
                                     instruction[19:12],      // imm[19:12] (8 bits)
                                     instruction[20],         // imm[11] (1 bit)
                                     instruction[30:21],      // imm[10:1] (10 bits)
                                     1'b0};                   // imm[0] = 0 (1 bit)
            end
            default: begin
                immediateExtracted = 32'h0;
            end
        endcase
    end

    assign immediateValue = immediateExtracted;

    // CONTROL SIGNAL GENERATION
    assign enRegWrite = isRT || isIT || isJT;
    assign enALU = isRT || (isIT && (opcode != OPCODEJALR)) || isBT;
    assign useImmediate = isIT;

    // ALU OPERATION DECODING
    reg [3:0] aluOperation;
    always @(*) begin
        if (isRT) begin
            case ({fun7, fun3})
                10'b0000000000: aluOperation = 4'b0000; // ADD
                10'b0100000000: aluOperation = 4'b0001; // SUB
                10'b0000000111: aluOperation = 4'b0010; // AND
                10'b0000000110: aluOperation = 4'b0011; // OR
                10'b0000000100: aluOperation = 4'b0100; // XOR
                10'b0000000010: aluOperation = 4'b0101; // SLT
                10'b0000000011: aluOperation = 4'b0110; // SLTU
                10'b0000000001: aluOperation = 4'b0111; // SLL
                10'b0000000101: aluOperation = 4'b1000; // SRL
                10'b0100000101: aluOperation = 4'b1001; // SRA
                default:        aluOperation = 4'b0000; 
            endcase
        end else if (isIT) begin
            case (fun3)
                3'b000: aluOperation = 4'b0000; // ADDI
                3'b010: aluOperation = 4'b0101; // SLTI
                3'b011: aluOperation = 4'b0110; // SLTIU
                3'b100: aluOperation = 4'b0100; // XORI
                3'b110: aluOperation = 4'b0011; // ORI
                3'b111: aluOperation = 4'b0010; // ANDI
                3'b001: aluOperation = 4'b0111; // SLLI
                3'b101: begin
                    if (fun7[5] == 1'b0) begin
                        aluOperation = 4'b1000; // SRLI
                    end else begin
                        aluOperation = 4'b1001; // SRAI
                    end
                end
                default: aluOperation = 4'b0000; 
            endcase
        end else if (isBT) begin
            case (fun3)
                3'b000: aluOperation = 4'b0001; // BEQ (subtract for comparison)
                3'b001: aluOperation = 4'b0001; // BNE (subtract for comparison)
                3'b100: aluOperation = 4'b0101; // BLT (set less than)
                3'b101: aluOperation = 4'b0101; // BGE (set less than)
                3'b110: aluOperation = 4'b0110; // BLTU (set less than unsigned)
                3'b111: aluOperation = 4'b0110; // BGEU (set less than unsigned)
                default: aluOperation = 4'b0000; 
            endcase
        end else begin
            aluOperation = 4'b0000;
        end
    end

    assign opALU = aluOperation;
    assign branchT = fun3;

    // BRANCH CONDITION EVALUATION (placeholder for now)
    assign branchTaken = 1'b0; // Default to not taken

endmodule