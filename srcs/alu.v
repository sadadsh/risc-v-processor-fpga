`timescale 1ns / 1ps

// ARITHMETIC LOGIC UNIT
// Engineer: Sadad Haidari

// This logic unit features parallel computation, power modeling with realistic power cost,
// and performance tracking using real-time statistics on operation usage.

module alu(
    input wire clk, // Clock for performance monitoring.
    input wire reset, // Reset (ACTIVE LOW).
    
    // INTERFACE
    // This is how other modules will interact with the ALU.
    input wire [31:0] operandA, // First operand.
    input wire [31:0] operandB, // Second operand.
    input wire [3:0] op, // Operation selection, tells logic what to do.
    input wire enALU, // Enable operations.
    output reg [31:0] result, // Result.
    output wire flagZero, // Active when result = 0.
    
    // PERFORMANCE MONITORING
    output wire [31:0] operationTotal, // Total performed operations.
    output wire [3:0] operationMostUsed, // Most frequent operation.
    output wire [7:0] estimatedPower, // Estimated power consumption (0-255).
    output wire operationActive // Active when arithmetic logic unit is used.
    );
    
    // RISC-V STANDARD MAPPING
    // Mapping 4-bit codes to each operation using the standard.
    
    localparam ADD = 4'b0000; // Addition
    localparam SUB = 4'b0001; // Subtraction
    localparam AND = 4'b0010; // Bitwise AND
    localparam OR = 4'b0011; // Bitwise OR
    localparam XOR = 4'b0100; // Bitwise XOR
    localparam SLT = 4'b0101; // Set Less Than (SIGNED)
    localparam SLTU = 4'b0110; // Set Less Than (UNSIGNED)
    localparam SLL = 4'b0111; // Shift Left Logical
    localparam SRL = 4'b1000; // Shift Right Logical
    localparam SRA = 4'b1001; // Shift Right Arithmetic
    
    // PERFORMANCE MONITORING STORAGE
    reg [31:0] opsC [0:15]; // Count each operation form.
    reg [31:0] opsRT; // Running total of all operations.
    reg [3:0] opsMU; // Which operation number gets used most.
    reg opsBusy; // Activity flag.
    
    // POWER CONSUMPTION LOOKUP TABLE
    // Different operations consume different amounts of power.
    reg [7:0] powerConsumption; // Hold power estimate.
    // Internal computation wires and results.
    wire [31:0] addR;
    wire [31:0] subR;
    wire [31:0] andR;
    wire [31:0] orR;
    wire [31:0] xorR;
    wire [31:0] sltR;
    wire [31:0] sltuR;
    wire [31:0] sllR;
    wire [31:0] srlR;
    wire [31:0] sraR;
    
    integer i; // Loop variable.
    
    // INITIALIZE PERFORMANCE COUNTERS
    // Most units do not track this, this is unique to this code.
    // Sets the start values for all our variables and clears counters.
    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            opsC[i] = 32'h0;
        end
        opsRT = 32'h0;
        opsMU = 4'h0;
        opsBusy = 1'b0;
        powerConsumption = 8'h0;
    end
    
    // COMBINATIONAL LOGIC
    // These happen at an instant, no waiting on the clock.
    assign addR = operandA + operandB;
    assign subR = operandA - operandB;
    assign andR = operandA & operandB;
    assign orR = operandA | operandB;
    assign xorR = operandA ^ operandB;
    assign sltR = ($signed(operandA) < $signed(operandB)) ? 32'h1 : 32'h0;
    assign sltuR = (operandA < operandB) ? 32'h1 : 32'h0;
    assign sllR = operandA << operandB[4:0];
    assign srlR = operandA >> operandB[4:0];
    assign sraR = $signed(operandA) >>> operandB[4:0];
    // Combinational Operation Selection
    always @(*) begin
        opsBusy = enALU; // ALU is working when enabled.
        if (enALU) begin // Do work just when ALU is enabled.
            case (op) // Check which operation is requested.
            ADD: begin
                result = addR; // Use pre-computed ADD result.
                powerConsumption = 8'd10; // Low power operation.
            end
            SUB: begin
                result = subR;
                powerConsumption = 8'd12; // A bit higher than ADD.
            end
            AND: begin
                result = andR;
                powerConsumption = 8'd8; // Low power operation.
            end
            OR: begin
                result = orR;
                powerConsumption = 8'd8; // Low power operation.
            end
            XOR: begin
                result = xorR;
                powerConsumption = 8'd9; // A bit higher due to more complex gate.
            end
            SLT: begin
                result = sltR;
                powerConsumption = 8'd15; // Comparison requires more logic.
            end
            SLTU: begin
                result = sltuR;
                powerConsumption = 8'd15; // Comparison requires more logic.
            end
            SLL: begin
                result = sllR;
                powerConsumption = 8'd20; // Shifter circuits use more power.
            end
            SRL: begin
                result = srlR;
                powerConsumption = 8'd20; // Shifter circuits use more power.
            end
            SRA: begin
                result = sraR;
                powerConsumption = 8'd22; // Most complex since arithmetic shift preserves sign.
            end
            default: begin // IF UNKNOWN OPERATION CODE...
                result = 32'h0; // Safe default, so output 0.
                powerConsumption = 8'd0; // No operation, therefore no power used.
            end
        endcase
        end else begin // No logic unit enabled.
        result = 32'h0; // Output 0 when disabled.
        powerConsumption = 8'd0;
        end
    end
    
    // SEQUENTIAL LOGIC PERFORMANCE MONITORING
    // This occurs on the clock edges.
    always @(posedge clk or negedge reset) begin
        if (!reset) begin // If reset is active.
            // Reset all performance counters.
            for (i = 0; i < 16; i = i + 1) begin
                opsC[i] <= 32'h0; // Clear each operation counter.
            end
            opsRT <= 32'h0;
            opsMU <= 4'h0;
        end else begin
            if (enALU) begin
                // Increment counter for this specific operation.
                opsC[op] <= opsC[op] + 1; // Count this specific operation.
                opsRT <= opsRT + 1;
                
                // Find most used operation.
                for (i = 0; i < 16; i = i + 1) begin
                    if (opsC[i] > opsC[opsMU]) begin
                        opsMU <= i; // Update most used operation if this one has a higher count.
                    end
                end
            end
        end
    end
    // Output assignments.
    assign flagZero = (result == 32'h0); // Zero flag for conditional branches.
    assign operationTotal = opsRT; // Connect internal counter to output.
    assign operationMostUsed = opsMU; // Connect internal tracker to output.
    assign estimatedPower = powerConsumption; // Connect internal power estimate to output.
    assign operationActive = opsBusy; // Connect internal activity flag to output.
    
endmodule
