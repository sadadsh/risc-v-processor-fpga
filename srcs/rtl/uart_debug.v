`timescale 1ns / 1ps

// UART DEBUG OUTPUT MODULE
// Engineer: Sadad Haidari
// 
// This module provides text output for debugging and demonstration purposes.
// Outputs instruction execution details, performance metrics, and system status
// over UART at 115200 baud for connection to PC terminal.

module uart_debug (
    input wire clk,
    input wire reset,
    
    // Processor signals to monitor
    input wire instructionComplete,
    input wire [31:0] instruction,
    input wire [31:0] currentPC,
    input wire [2:0] pipelineStage,
    input wire [31:0] resultALU,
    input wire [4:0] rs1, rs2, rd,
    input wire [31:0] rsData1, rsData2,
    
    // Performance monitoring inputs
    input wire [31:0] totalInstructions,
    input wire [31:0] totalCycles,
    input wire [7:0] branchAccuracy,
    input wire [2:0] workloadFormat,
    input wire [3:0] workloadConfidence,
    input wire [7:0] currentPower,
    input wire [2:0] powerState,
    input wire powerOptimizationActive,
    input wire thermalThrottle,
    
    // UART output
    output wire uart_tx
);

    // UART transmitter parameters for 115200 baud @ 125 MHz
    localparam BAUD_RATE = 115200;
    localparam CLK_FREQ = 125000000;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    
    // UART transmitter signals
    reg [7:0] uart_data;
    reg uart_send;
    wire uart_busy;
    
    // Message buffer and control
    reg [7:0] message_buffer [0:255];
    reg [7:0] buffer_length;
    reg [7:0] send_index;
    reg sending_message;
    
    // Timing and trigger controls
    reg [23:0] message_timer;
    reg instruction_complete_last;
    reg [7:0] message_count;
    
    // Pipeline stage names for display
    function [23:0] stage_name;
        input [2:0] stage;
        case (stage)
            3'b000: stage_name = "IDL";  // IDLE
            3'b001: stage_name = "DEC";  // DECODE
            3'b010: stage_name = "EXE";  // EXECUTE
            3'b011: stage_name = "MEM";  // MEMORY
            3'b100: stage_name = "WRB";  // WRITEBACK
            default: stage_name = "UNK";
        endcase
    endfunction
    
    // Power state names for display
    function [23:0] power_state_name;
        input [2:0] state;
        case (state)
            3'b000: power_state_name = "IDL";  // IDLE
            3'b001: power_state_name = "LOW";  // LOW
            3'b010: power_state_name = "BAL";  // BALANCED
            3'b011: power_state_name = "PER";  // PERFORMANCE
            3'b100: power_state_name = "MAX";  // MAXIMUM
            3'b101: power_state_name = "CRT";  // CRITICAL
            default: power_state_name = "UNK";
        endcase
    endfunction
    
    // Workload format names for display
    function [23:0] workload_name;
        input [2:0] format;
        case (format)
            3'b000: workload_name = "UNK";  // UNKNOWN
            3'b001: workload_name = "CMP";  // COMPUTE
            3'b010: workload_name = "MEM";  // MEMORY
            3'b011: workload_name = "CTL";  // CONTROL
            3'b100: workload_name = "MIX";  // MIXED
            3'b101: workload_name = "IDL";  // IDLE
            default: workload_name = "ERR";
        endcase
    endfunction
    
    // UART Transmitter Module
    uart_tx_module uart_transmitter (
        .clk(clk),
        .reset(reset),
        .data(uart_data),
        .send(uart_send),
        .tx(uart_tx),
        .busy(uart_busy)
    );
    
    // Main debug output control
    always @(posedge clk) begin
        if (!reset) begin
            message_timer <= 24'h0;
            instruction_complete_last <= 1'b0;
            sending_message <= 1'b0;
            send_index <= 8'h0;
            uart_send <= 1'b0;
            message_count <= 8'h0;
        end else begin
            instruction_complete_last <= instructionComplete;
            message_timer <= message_timer + 1;
            
            // Detect instruction completion
            if (instructionComplete && !instruction_complete_last) begin
                prepare_instruction_message();
                sending_message <= 1'b1;
                send_index <= 8'h0;
                message_count <= message_count + 1;
            end
            
            // Send periodic status updates every ~1 second
            else if (message_timer == 24'hBEBC20) begin  // ~125M cycles ≈ 1 second
                prepare_status_message();
                sending_message <= 1'b1;
                send_index <= 8'h0;
                message_timer <= 24'h0;
            end
            
            // Message transmission state machine
            if (sending_message) begin
                if (!uart_busy && !uart_send) begin
                    if (send_index < buffer_length) begin
                        uart_data <= message_buffer[send_index];
                        uart_send <= 1'b1;
                        send_index <= send_index + 1;
                    end else begin
                        sending_message <= 1'b0;
                    end
                end else if (uart_send) begin
                    uart_send <= 1'b0;  // Clear send signal after one cycle
                end
            end
        end
    end
    
    // Prepare instruction execution message
    task prepare_instruction_message;
        begin
            // Format: "[###] PC:0x1004 | ADD x1,x2,x3 -> x1=0x00000005 | PWR:15W PRED:94%"
            
            // Message counter
            message_buffer[0] = "[";
            hex_to_ascii(message_count[7:4], message_buffer[1]);
            hex_to_ascii(message_count[3:0], message_buffer[2]);
            message_buffer[3] = "]";
            message_buffer[4] = " ";
            
            // Program counter
            message_buffer[5] = "P";
            message_buffer[6] = "C";
            message_buffer[7] = ":";
            message_buffer[8] = "0";
            message_buffer[9] = "x";
            hex_to_ascii(currentPC[31:28], message_buffer[10]);
            hex_to_ascii(currentPC[27:24], message_buffer[11]);
            hex_to_ascii(currentPC[23:20], message_buffer[12]);
            hex_to_ascii(currentPC[19:16], message_buffer[13]);
            hex_to_ascii(currentPC[15:12], message_buffer[14]);
            hex_to_ascii(currentPC[11:8], message_buffer[15]);
            hex_to_ascii(currentPC[7:4], message_buffer[16]);
            hex_to_ascii(currentPC[3:0], message_buffer[17]);
            
            message_buffer[18] = " ";
            message_buffer[19] = "|";
            message_buffer[20] = " ";
            
            // Instruction decoding (simplified)
            decode_instruction_name(instruction, 21);
            
            message_buffer[30] = " ";
            message_buffer[31] = "x";
            dec_to_ascii(rd, message_buffer[32], message_buffer[33]);
            message_buffer[34] = "=";
            message_buffer[35] = "0";
            message_buffer[36] = "x";
            hex_to_ascii(resultALU[31:28], message_buffer[37]);
            hex_to_ascii(resultALU[27:24], message_buffer[38]);
            hex_to_ascii(resultALU[23:20], message_buffer[39]);
            hex_to_ascii(resultALU[19:16], message_buffer[40]);
            hex_to_ascii(resultALU[15:12], message_buffer[41]);
            hex_to_ascii(resultALU[11:8], message_buffer[42]);
            hex_to_ascii(resultALU[7:4], message_buffer[43]);
            hex_to_ascii(resultALU[3:0], message_buffer[44]);
            
            message_buffer[45] = " ";
            message_buffer[46] = "|";
            message_buffer[47] = " ";
            
            // Power and performance info
            message_buffer[48] = "P";
            message_buffer[49] = "W";
            message_buffer[50] = "R";
            message_buffer[51] = ":";
            dec_to_ascii(currentPower, message_buffer[52], message_buffer[53]);
            message_buffer[54] = "W";
            message_buffer[55] = " ";
            
            message_buffer[56] = "A";
            message_buffer[57] = "C";
            message_buffer[58] = "C";
            message_buffer[59] = ":";
            dec_to_ascii(branchAccuracy, message_buffer[60], message_buffer[61]);
            message_buffer[62] = "%";
            
            message_buffer[63] = "\r";
            message_buffer[64] = "\n";
            
            buffer_length = 65;
        end
    endtask
    
    // Prepare status message
    task prepare_status_message;
        reg [23:0] workload_name_result;
        reg [23:0] power_state_name_result;
        begin
            // Format: "=== STATUS === Inst:123 Cyc:456 Workload:CMP Conf:15 Power:BAL ==="
            
            message_buffer[0] = "=";
            message_buffer[1] = "=";
            message_buffer[2] = "=";
            message_buffer[3] = " ";
            message_buffer[4] = "S";
            message_buffer[5] = "T";
            message_buffer[6] = "A";
            message_buffer[7] = "T";
            message_buffer[8] = "U";
            message_buffer[9] = "S";
            message_buffer[10] = " ";
            message_buffer[11] = "=";
            message_buffer[12] = "=";
            message_buffer[13] = "=";
            message_buffer[14] = " ";
            
            // Instructions
            message_buffer[15] = "I";
            message_buffer[16] = "n";
            message_buffer[17] = "s";
            message_buffer[18] = "t";
            message_buffer[19] = ":";
            dec_to_ascii_32(totalInstructions, 20);
            
            message_buffer[25] = " ";
            message_buffer[26] = "C";
            message_buffer[27] = "y";
            message_buffer[28] = "c";
            message_buffer[29] = ":";
            dec_to_ascii_32(totalCycles, 30);
            
            message_buffer[35] = " ";
            message_buffer[36] = "W";
            message_buffer[37] = "L";
            message_buffer[38] = ":";
            workload_name_result = workload_name(workloadFormat);
            message_buffer[39] = workload_name_result[23:16];
            message_buffer[40] = workload_name_result[15:8];
            message_buffer[41] = workload_name_result[7:0];
            
            message_buffer[42] = " ";
            message_buffer[43] = "P";
            message_buffer[44] = "S";
            message_buffer[45] = ":";
            power_state_name_result = power_state_name(powerState);
            message_buffer[46] = power_state_name_result[23:16];
            message_buffer[47] = power_state_name_result[15:8];
            message_buffer[48] = power_state_name_result[7:0];
            
            if (thermalThrottle) begin
                message_buffer[49] = " ";
                message_buffer[50] = "T";
                message_buffer[51] = "H";
                message_buffer[52] = "R";
                message_buffer[53] = "O";
                message_buffer[54] = "T";
                message_buffer[55] = "!";
            end else begin
                message_buffer[49] = " ";
                message_buffer[50] = " ";
                message_buffer[51] = " ";
                message_buffer[52] = " ";
                message_buffer[53] = " ";
                message_buffer[54] = " ";
                message_buffer[55] = " ";
            end
            
            message_buffer[56] = "\r";
            message_buffer[57] = "\n";
            
            buffer_length = 58;
        end
    endtask
    
    // Helper tasks for number conversion
    task hex_to_ascii;
        input [3:0] hex_val;
        output [7:0] ascii_char;
        begin
            if (hex_val < 10)
                ascii_char = "0" + hex_val;
            else
                ascii_char = "A" + (hex_val - 10);
        end
    endtask
    
    task dec_to_ascii;
        input [7:0] dec_val;
        output [7:0] tens_digit;
        output [7:0] ones_digit;
        begin
            tens_digit = "0" + (dec_val / 10);
            ones_digit = "0" + (dec_val % 10);
        end
    endtask
    
    task dec_to_ascii_32;
        input [31:0] dec_val;
        input [7:0] start_index;
        reg [31:0] temp_val;
        integer i;
        begin
            temp_val = dec_val;
            for (i = 4; i >= 0; i = i - 1) begin
                message_buffer[start_index + i] = "0" + (temp_val % 10);
                temp_val = temp_val / 10;
            end
        end
    endtask
    
    task decode_instruction_name;
        input [31:0] instr;
        input [7:0] start_index;
        reg [6:0] opcode;
        reg [2:0] funct3;
        begin
            opcode = instr[6:0];
            funct3 = instr[14:12];
            
            case (opcode)
                7'b0110011: begin  // R-type
                    case (funct3)
                        3'b000: begin
                            if (instr[30]) begin
                                message_buffer[start_index] = "S";
                                message_buffer[start_index+1] = "U";
                                message_buffer[start_index+2] = "B";
                            end else begin
                                message_buffer[start_index] = "A";
                                message_buffer[start_index+1] = "D";
                                message_buffer[start_index+2] = "D";
                            end
                        end
                        3'b111: begin
                            message_buffer[start_index] = "A";
                            message_buffer[start_index+1] = "N";
                            message_buffer[start_index+2] = "D";
                        end
                        3'b110: begin
                            message_buffer[start_index] = "O";
                            message_buffer[start_index+1] = "R";
                            message_buffer[start_index+2] = " ";
                        end
                        3'b100: begin
                            message_buffer[start_index] = "X";
                            message_buffer[start_index+1] = "O";
                            message_buffer[start_index+2] = "R";
                        end
                        default: begin
                            message_buffer[start_index] = "R";
                            message_buffer[start_index+1] = "-";
                            message_buffer[start_index+2] = "?";
                        end
                    endcase
                end
                7'b0010011: begin  // I-type
                    message_buffer[start_index] = "A";
                    message_buffer[start_index+1] = "D";
                    message_buffer[start_index+2] = "I";
                end
                7'b1100011: begin  // Branch
                    message_buffer[start_index] = "B";
                    message_buffer[start_index+1] = "R";
                    message_buffer[start_index+2] = "?";
                end
                default: begin
                    message_buffer[start_index] = "?";
                    message_buffer[start_index+1] = "?";
                    message_buffer[start_index+2] = "?";
                end
            endcase
            
            message_buffer[start_index+3] = " ";
            message_buffer[start_index+4] = "x";
            dec_to_ascii(rs1, message_buffer[start_index+5], message_buffer[start_index+6]);
            message_buffer[start_index+7] = ",";
            message_buffer[start_index+8] = "x";
            dec_to_ascii(rs2, message_buffer[start_index+9], message_buffer[start_index+10]);
        end
    endtask

endmodule

// Simple UART Transmitter Module
module uart_tx_module (
    input wire clk,
    input wire reset,
    input wire [7:0] data,
    input wire send,
    output reg tx,
    output reg busy
);

    localparam BAUD_DIV = 1085;  // 125MHz / 115200 ≈ 1085
    
    reg [10:0] baud_counter;
    reg [3:0] bit_counter;
    reg [9:0] shift_reg;
    reg transmitting;
    
    always @(posedge clk) begin
        if (!reset) begin
            tx <= 1'b1;
            busy <= 1'b0;
            transmitting <= 1'b0;
            baud_counter <= 11'h0;
            bit_counter <= 4'h0;
        end else begin
            if (send && !busy) begin
                shift_reg <= {1'b1, data, 1'b0};  // Stop bit, data, start bit
                transmitting <= 1'b1;
                busy <= 1'b1;
                baud_counter <= 11'h0;
                bit_counter <= 4'h0;
            end
            
            if (transmitting) begin
                if (baud_counter == BAUD_DIV - 1) begin
                    baud_counter <= 11'h0;
                    tx <= shift_reg[bit_counter];
                    bit_counter <= bit_counter + 1;
                    
                    if (bit_counter == 4'h9) begin
                        transmitting <= 1'b0;
                        busy <= 1'b0;
                        tx <= 1'b1;
                    end
                end else begin
                    baud_counter <= baud_counter + 1;
                end
            end
        end
    end

endmodule