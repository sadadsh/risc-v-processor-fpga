
// PROCESSOR CORE
// Engineer: Sadad Haidari

// ARCHITECTURE
// This processor implements a 4-stage pipeline:
// S00 [IDLE]            | Waiting for new instruction.
// S01 [DECODE/READ]     | Break instruction into parts.
// S10 [EXECUTE]         | ALU performs computations.
// S11 [WRITEBACK]       | Store result back to register file.

module core (
    input wire clk,
    input wire reset,
    // INSTRUCTION INPUT INTERFACE
    input wire [31:0] instruction, // 32-bit RISC-V instruction.
    input wire validInstruction, // Signal that instruction is prepared to execute.
    // PROCESSOR STATUS OUTPUTS
    output wire completeInstruction, // Signal that current instruction finished.
    // PERFORMANCE MONITORING OUTPUTS
    output wire [31:0] totalInstructions,
    output wire [31:0] totalOperationsALU,
    output wire [31:0] totalRegAccesses,
    output wire [7:0] currentEstimatedPower,
    output wire [4:0] mostUsedReg,
    output wire [3:0] mostUsedOpsALU,
    // DEBUG OUTPUTS
    output wire [4:0] rs1Debug, // Which source register is being read?
    output wire [4:0] rs2Debug, // Which source register is being read?
    output wire [4:0] rdDebug, // Which destination register is being written?
    output wire [31:0] rsData1Debug, // What data did we read from it?
    output wire [31:0] rsData2Debug, // What data did we read from it?
    output wire [31:0] resultALUDebug // What result did the unit compute?
);

// INTERNAL WIRE DECLARATIONS
// This will connect to the three main modules: the decoder, register, and arithmetic unit.
wire [6:0] opcode; // Bits [6:0] and tells us instruction format like ADD, SUB, etc.
wire [4:0] rd; // Bits [11:7] tells us which register to write result to.
wire [4:0] rs1; // Bits [19:15] tells us first source register to read from.
wire [4:0] rs2; // Bits [24:20] tells us second source register to read from.
wire [2:0] fun3; // Bits [14:12] further specifies the operation.
wire [6:0] fun7; // Bits [31:25] further specifies the operation.
wire enRegWrite;
wire enALU;
wire [3:0] opALU; // ALU operation code.
wire isRT; // Is it an R-type instruction?
wire isVI; // Is this a valid instruction?

// REGISTER FILE CONNECTIONS
// The register file stores 32 registers (x0 to x31), each 32 bits wide and provides performance monitoring.
wire [31:0] rsData1, rsData2; // Data read from source registers.
wire [31:0] regAccessCount, regWriteCount;
wire [4:0] regMostUsed;
wire regPowerActive;

// ALU CONNECTIONS
// The ALU performs arithmetic and logic operations, also with performance monitoring.
wire [31:0] resultALU; // Result from ALU operation.
wire flagZeroALU; // Is the result zero?
wire [31:0] totalOpsALU;
wire [3:0] mostUsedALU;
wire [7:0] estimatedPowerALU;
wire activeALU;

// PROCESSOR STATE REGISTERS
// These registers track the overall state of the processor.
reg [31:0] instructionCount; // Total instructions executed.
reg completeExecution; // Signal that current instruction finished.

// PIPELINE STATE TRACKING
reg executionActive; // Is an instruction being processed right now?
reg [1:0] executionStage; // Current stage in the 4-stage pipeline.
// Reminder: [2'b00 IDLE] [2'b01 DECODE/READ] [2'b10 EXECUTE] [2'b11 WRITEBACK]

// REGISTER ACCESS CONTROL SIGNALS
// These control when the register file should count accesses for accurate performance monitoring.
wire regReadEnable;
wire regWriteEnable;
// Control Logic
assign regReadEnable = executionActive && ((executionStage == 2'b01) || (executionStage == 2'b10));
assign regWriteEnable = enRegWrite && executionActive && (executionStage == 2'b11);

// PROCESSOR INSTANTIATIONS
// It is time now. Yes, time to connect the modules together.
// 1. Instruction Decoder
instruction_decoder decoderUnit (
    .instruction(instruction), // The 32-bit instruction to decode.
    .opcode(opcode), // Bits [6:0] and tells us instruction format like ADD, SUB, etc.
    .rd(rd), // Bits [11:7] tells us which register to write result to.
    .rs1(rs1), // Bits [19:15] tells us first source register to read from.
    .rs2(rs2), // Bits [24:20] tells us second source register to read from.
    .fun3(fun3), // Bits [14:12] further specifies the operation.
    .fun7(fun7), // Bits [31:25] further specifies the operation.
    .enRegWrite(enRegWrite), // Enable write to register file.
    .enALU(enALU), // Enable ALU operation.
    .opALU(opALU), // ALU operation code.
    .isRT(isRT), // Is it an R-type instruction?
    .isVI(isVI) // Is this a valid instruction?
);
// 2. Register File
register registerUnit (
    .clk(clk), // The clock signal.
    .reset(reset), // The reset signal (ACTIVE LOW).
    .rs1(rs1), // First source register to read from (PORT 1).
    .rs2(rs2), // Second source register to read from (PORT 2).
    .rsData1(rsData1), // The data from first register.
    .rsData2(rsData2), // The data from second register.
    .enWrite(regWriteEnable), // Enable write to register (ACTIVE HIGH).
    .rd(rd), // Holds which register we choose to write to.
    .rdData(resultALU), // Holds the data we will write into that register.
    .regAccessCount(regAccessCount), // The number of times we've read registers.
    .regWriteCount(regWriteCount), // The number of times we've written registers.
    .regMostUsed(regMostUsed), // The register that gets used most often.
    .powerActive(regPowerActive) // Is the register being used right now?
);
// 3. Arithmetic Logic Unit
alu aluUnit (
    .clk(clk), // The clock signal.
    .reset(reset), // The reset signal (ACTIVE LOW).
    .operandA(rsData1), // First operand for ALU operation.
    .operandB(rsData2), // Second operand for ALU operation.
    .op(opALU), // ALU operation code.
    .enALU(enALU && executionActive && (executionStage == 2'b10)), // Enable ALU operation.
    .result(resultALU), // Result from ALU operation.
    .flagZero(flagZeroALU), // Is the result zero?
    .operationTotal(totalOpsALU), // Total ALU operations performed.
    .operationMostUsed(mostUsedALU), // Most used ALU operation.
    .estimatedPower(estimatedPowerALU), // Estimated power consumption.
    .operationActive(activeALU) // Is the ALU active right now?
);

// PROCESSOR CONTROL LOGIC
// This is the brain of the processor, managing the pipeline stages and performance monitoring.
// Runs on each clock tick.
always @(posedge clk) begin
    if (!reset) begin
        // RESET CONDITION
        // Clear all state when reset is low and active.
        instructionCount <= 32'h0;
        completeExecution <= 1'b0;
        executionActive <= 1'b0;
        executionStage <= 2'b00; // Go to IDLE stage.
    end else begin
        // NORMAL
        completeExecution <= 1'b0; // Default to not complete.
        // PIPELINE STATE MACHINE
        // Each of these cases handles one pipleine stage and determines what to do next.
        case (executionStage)
            // IDLE STAGE
            2'b00: begin
                // Wait for a valid instruction to start processing.
                if (validInstruction && isVI) begin
                    // New valid instruction received.
                    executionActive <= 1'b1; // Start processing.
                    executionStage <= 2'b01; // Move to DECODE/READ stage.
                end else begin
                    executionActive <= 1'b0; // Remain IDLE stage.
                end
            end
            // DECODE/READ STAGE
            2'b01: begin
                // Decoder is breaking apart the instruction.
                // Register file is reading source operands from the registers.
                executionStage <= 2'b10; // Move to EXECUTE stage.
                // Execution remains active; therefore, executionActive = 1'b1 still.
            end
            // EXECUTE STAGE
            2'b10: begin
                // ALU is performing the computation.
                executionStage <= 2'b11; // Move to WRITEBACK stage.
                // Execution remains active; therefore, executionActive = 1'b1 still.
            end
            // WRITEBACK STAGE
            2'b11: begin
                // Register file is writing the result back to the destination register.
                // This is the last stage.
                completeExecution <= 1'b1; // Signal that instruction is complete.
                instructionCount <= instructionCount + 1; // Increment instruction count.
                
                if (validInstruction && isVI) begin
                    // Another instruction, immediate start for next instruction.
                    executionStage <= 2'b01; // Move to DECODE/READ stage.
                    // Execution remains active; therefore, executionActive = 1'b1 still.
                end else begin
                    // No new instruction, go back to IDLE stage.
                    executionActive <= 1'b0; // Stop processing.
                    executionStage <= 2'b00; // Move to IDLE stage.
                end
            end
            default: begin
                // Should never happen, but if it does, reset to IDLE.
                executionActive <= 1'b0;
                executionStage <= 2'b00;
            end
        endcase
    end
end

    // POWER MANAGEMENT CALCULATION
    // Calculate total power consumption through summation of all components.
    wire [7:0] totalEstimatedPower;
    assign totalEstimatedPower = estimatedPowerALU + (regPowerActive ? 8'd5 : 8'd0) + (executionActive ? 8'd3 : 8'd1);
    // This adds the ALU power, register power (5 units if active), and base processor power (3 units if active, else 1).

    // OUTPUT ASSIGNMENTS
    // 1. Processor Status Outputs
    assign completeInstruction = completeExecution; // Signal that current instruction finished.
    // 2. Performance Monitoring Outputs
    assign totalInstructions = instructionCount; // Total instructions executed.
    assign totalOperationsALU = totalOpsALU; // Total ALU operations performed.
    assign totalRegAccesses = regAccessCount; // Total register accesses.
    assign currentEstimatedPower = totalEstimatedPower; // Current estimated power consumption.
    assign mostUsedReg = regMostUsed; // The register that gets used most often.
    assign mostUsedOpsALU = mostUsedALU; // Most used ALU operation.
    // 3. Debug Outputs
    assign rs1Debug = rs1; // Which source register is being read?
    assign rs2Debug = rs2; // Which source register is being read?
    assign rdDebug = rd; // Which destination register is being written?
    assign rsData1Debug = rsData1; // What data did we read from it?
    assign rsData2Debug = rsData2; // What data did we read from it?
    assign resultALUDebug = resultALU; // What result did the unit compute?
    
endmodule
