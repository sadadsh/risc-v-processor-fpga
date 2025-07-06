// SIMPLE PROCESSOR CORE
// Engineer: Sadad Haidari

// This will connect the register file + ALU + instruction decoder for the complete RISC-V execution.

// Instruction -> Decoder -> Register File -> ALU -> Register File:
//      1. Decoder breaks apart instruction into control signals.
//      2. Register files reads source operands.
//      3. ALU performs computations on operands.
//      4. Register file writes ALU result to destination.

// This processor includes performance monitoring throughout, tracking instruction count,
// ALU usage, register usage, monitors power consumption in real-time, and identifies usage
// patterns for optimization.

module core(
    input wire clk,
    input wire reset,
    // INSTRUCTION INPUT INTERFACE
    // How instructions get into the processor.
    input wire [31:0] instruction, // 32-bit RISC-V instruction to execute.
    input wire validInstruction, // Is the instruction valid/ready?
    // PROCESSOR STATUS OUTPUTS
    // Tells outside world what is happening.
    output wire completeInstruction, // Has current instruction finished executing?
    // INNOVATION
    // Performance monitoring outputs.
    output wire [31:0] totalInstructions, // How many instructions have we executed?
    output wire [31:0] totalOperationsALU, // How many ALU operations performed?
    output wire [31:0] totalRegAccesses, // How many register file accesses?
    output wire [7:0] currentEstimatedPower, // Current power consumption estimate?
    output wire [4:0] mostUsedReg, // Which register gets used most often?
    output wire [3:0] mostUsedOpsALU, // Which ALU operations is used the most?
    // DEBUG OUTPUTS
    // Helps for testing and learning.
    output wire [4:0] rs1Debug, // Which source register 1 is being read?
    output wire [4:0] rs2Debug, // Which source register 2 is being read?
    output wire [4:0] rdDebug, // Which destination register is being written?
    output wire [31:0] resultALUDebug, // What did the ALU compute?
    output wire [31:0] rsData1Debug, // What data came from register 1?
    output wire [31:0] rsData2Debug // What data came from register 2?
    );
    
    // INTERNAL WIRES CONNECTING MODULES
    // Each wire carries a specific signal between modules.
    // INSTRUCTION DECODER OUTPUTS
    // These come FROM the decoder and go TO other modules.
    wire [6:0] opcode; // What type of instruction?
    wire [4:0] rd, rs1, rs2; // Which registers to read from and write to?
    wire [2:0] fun3; // Function code that helps specify operation.
    wire [6:0] fun7; // Additional function code for operation specification.
    wire enRegWrite; // Should we write ALU result back to register file.
    wire enALU; // Should ALU perform (ADD, SUB, etc.).
    wire [3:0] opALU;
    wire isRT;
    wire isVI;
    // REGISTER FILE CONNECTIONS
    // These wires carry data to and from the register file.
    wire [31:0] rsData1, rsData2; // Data read from source registers.
    wire [31:0] regAccessCount;
    wire [31:0] regWriteCount;
    wire [4:0] regMostUsed;
    wire regPowerActive;
    // ALU CONNECTIONS
    wire [31:0] resultALU;
    wire flagZeroALU;
    wire [31:0] totalOpsALU;
    wire [3:0] mostUsedALU;
    wire [7:0] estimatedPowerALU;
    wire activeALU;
    // PROCESSOR STATE REGISTERS
    // These track the processor's overall state.
    reg [31:0] instructionCount; // How many instructions have we completed?
    reg completeExecution; // Has the current instruction finished executing?
    // Initialize processor state when simulation starts.
    initial begin
        instructionCount = 32'h0;
        completeExecution = 1'b0;
    end
    
    // Connect the decoder outputs to internal wires.
    instruction_decoder decoder (
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .fun3(fun3),
    .rs1(rs1),
    .rs2(rs2),
    .fun7(fun7),
    .enRegWrite(enRegWrite),
    .enALU(enALU),
    .op(op),
    .isRT(isRT),
    .isVI(isVI)
    );

    // Connects our register file and tells it what to do
    // based on the decoded instructions.
    register register (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rsData1(rsData1),
        .rsData2(rsData2),
        .rdData(rdData),
        .enWrite(enRegWrite),
        .regAccessCount(regAccessCount),
        .regWriteCount(regWriteCount),
        .regMostUsed(regMostUsed),
        .powerActive(regPowerActive)
    );

    // This connects our ALU and provides it with operands from
    // the register file.
    alu alu (
        .clk(clk),
        .reset(reset),
        .operandA(rsData1),
        .operandB(rsData2),
        .op(opALU),
        .enALU(enALU),
        .result(resultALU),
        .flagZero(flagZeroALU),
        .operationTotal(totalOpsALU),
        .operationMostUsed(mostUsedALU),
        .estimatedPower(estimatedPowerALU),
        .operationActive(activeALU)
    );

    // PROCESSOR CONTROL LOGIC
    // Brain that orchestrates instruction execution.
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            instructionCount <= 32'h0; // Clear instruction counter.
            completeExecution <= 1'b0; // No executions right now.
        end else begin
            // Check if there is a valid instruction to execute.
            if (validInstruction && isVI) begin
                completeExecution <= 1'b0; // Starting execution.
                if (enALU) begin
                    completeExecution <= 1'b1; // Mark instruction complete.
                    instructionCount <= instructionCount + 1;
                end
            end else begin
                // No valid instruction, nothing is executing.
                completeExecution <= 1'b0;
            end
        end
    end

    // OUTPUT ASSIGNMENTS
    // Connect internal signals to module outputs.

    // Processor Status Outputs
    assign completeInstruction = completeExecution; // Notifies of instruction completion.
    
    // Performance Monitoring Outputs
    assign totalInstructions = instructionCount;
    assign totalOperationsALU = totalOpsALU;
    assign totalRegAccesses = regAccessCount;
    assign currentEstimatedPower = estimatedPowerALU;
    assign mostUsedReg = regMostUsed;
    assign mostUsedOpsALU = mostUsedALU;

    // Debug Outputs
    assign rs1Debug = rs1;
    assign rs2Debug = rs2;
    assign rdDebug = rd;
    assign resultALUDebug = resultALU;
    assign rsData1Debug = rsData1;
    assign rsData2Debug = rsData2;

endmodule
