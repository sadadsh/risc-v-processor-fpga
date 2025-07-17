// ================================================================
// LED DISPLAY CONTROLLER
// Manages LED patterns and RGB LEDs for system status indication
// ================================================================
// This module controls the 16 standard LEDs and 2 RGB LEDs on the
// Z7-20 board to provide visual feedback of system status.
// Optimized for simulation performance and clear status indication.
// ================================================================

`timescale 1ns / 1ps

module led_display (
    input wire clk,               // Display refresh clock.
    input wire reset,             // Reset signal (ACTIVE HIGH).
    
    // System status inputs.
    input wire clockLocked,       // Clock manager lock status.
    input wire processorActive,   // Processor running status.
    input wire [3:0] frequencyLevel,   // Current frequency level.
    input wire [3:0] powerState,       // Current power state.
    input wire [3:0] workloadFormat,   // Workload classification.
    input wire thermalThrottle,   // Thermal throttling active.
    input wire [15:0] branchAccuracy,  // Branch prediction accuracy.
    input wire demoActive,        // Demo mode active.
    input wire [2:0] demoPhase,   // Current demo phase.
    input wire [14:0] switchInputs,    // Switch inputs for control.
    
    // LED outputs.
    output reg [15:0] led,        // 16 standard LEDs.
    output reg led16_r,           // RGB LED 16 red.
    output reg led16_g,           // RGB LED 16 green.
    output reg led16_b,           // RGB LED 16 blue.
    output reg led17_r,           // RGB LED 17 red.
    output reg led17_g,           // RGB LED 17 green.
    output reg led17_b            // RGB LED 17 blue.
);

    // ================================================================
    // PARAMETERS AND CONSTANTS
    // ================================================================
    
    // Display modes based on switch settings.
    localparam MODE_SYSTEM_STATUS = 3'd0;
    localparam MODE_FREQUENCY_POWER = 3'd1;
    localparam MODE_BRANCH_ACCURACY = 3'd2;
    localparam MODE_DEMO_STATUS = 3'd3;
    localparam MODE_WORKLOAD_CLASS = 3'd4;
    localparam MODE_ALL_ON = 3'd5;
    localparam MODE_PATTERN_TEST = 3'd6;
    localparam MODE_HEARTBEAT = 3'd7;
    
    // Animation timing.
    parameter ANIMATION_SPEED = 24'd5000000; // 50ms at 100MHz.
    parameter HEARTBEAT_SPEED = 24'd25000000; // 250ms at 100MHz.
    
    // ================================================================
    // INTERNAL SIGNALS AND REGISTERS
    // ================================================================
    
    // Display control registers.
    reg [2:0] displayMode;        // Current display mode.
    reg [23:0] animationCounter;  // Animation timing counter.
    reg [3:0] animationPhase;     // Current animation phase.
    reg [15:0] ledPattern;        // Current LED pattern.
    
    // RGB LED control.
    reg [7:0] rgbCounter;         // RGB animation counter.
    reg [2:0] rgbPhase;           // RGB animation phase.
    
    // Status processing.
    reg [7:0] processedBranchAccuracy; // Processed branch accuracy.
    reg [3:0] systemHealth;       // Overall system health indicator.
    
    // ================================================================
    // INITIALIZATION
    // ================================================================
    
    initial begin
        led = 16'h0000;
        led16_r = 1'b0;
        led16_g = 1'b0;
        led16_b = 1'b0;
        led17_r = 1'b0;
        led17_g = 1'b0;
        led17_b = 1'b0;
        displayMode = MODE_SYSTEM_STATUS;
        animationCounter = 24'd0;
        animationPhase = 4'd0;
        ledPattern = 16'h0000;
        rgbCounter = 8'd0;
        rgbPhase = 3'd0;
        processedBranchAccuracy = 8'd0;
        systemHealth = 4'd0;
    end
    
    // ================================================================
    // DISPLAY MODE SELECTION
    // ================================================================
    
    // Select display mode based on switch inputs.
    always @(*) begin
        displayMode = switchInputs[2:0]; // Use lower 3 switches for mode.
    end
    
    // ================================================================
    // ANIMATION AND TIMING CONTROL
    // ================================================================
    
    // Animation timing and phase control.
    always @(posedge clk) begin
        if (reset) begin
            animationCounter <= 24'd0;
            animationPhase <= 4'd0;
            rgbCounter <= 8'd0;
            rgbPhase <= 3'd0;
        end else begin
            // Main animation counter.
            animationCounter <= animationCounter + 24'd1;
            if (animationCounter >= ANIMATION_SPEED) begin
                animationCounter <= 24'd0;
                animationPhase <= animationPhase + 4'd1;
            end
            
            // RGB animation counter (faster).
            rgbCounter <= rgbCounter + 8'd1;
            if (rgbCounter == 8'd0) begin
                rgbPhase <= rgbPhase + 3'd1;
            end
        end
    end
    
    // ================================================================
    // STATUS PROCESSING
    // ================================================================
    
    // Process branch accuracy for display.
    always @(*) begin
        processedBranchAccuracy = branchAccuracy[7:0]; // Take lower 8 bits.
    end
    
    // Calculate overall system health.
    always @(*) begin
        systemHealth = 4'd0;
        if (clockLocked) systemHealth = systemHealth + 4'd1;
        if (processorActive) systemHealth = systemHealth + 4'd1;
        if (!thermalThrottle) systemHealth = systemHealth + 4'd1;
        if (powerState <= 4'd5) systemHealth = systemHealth + 4'd1; // Reasonable power.
    end
    
    // ================================================================
    // LED PATTERN GENERATION
    // ================================================================
    
    // Generate LED patterns based on display mode.
    always @(*) begin
        case (displayMode)
            MODE_SYSTEM_STATUS: begin
                // Display system status on LEDs.
                ledPattern[15] = clockLocked;         // Clock lock status.
                ledPattern[14] = processorActive;     // Processor status.
                ledPattern[13] = thermalThrottle;     // Thermal status.
                ledPattern[12] = demoActive;          // Demo mode status.
                ledPattern[11:8] = frequencyLevel;    // Frequency level.
                ledPattern[7:4] = powerState;         // Power state.
                ledPattern[3:0] = systemHealth;       // Overall health.
            end
            
            MODE_FREQUENCY_POWER: begin
                // Display frequency and power information.
                ledPattern[15:12] = frequencyLevel;   // Frequency on upper LEDs.
                ledPattern[11:8] = powerState;        // Power state.
                ledPattern[7:0] = processedBranchAccuracy; // Branch accuracy.
            end
            
            MODE_BRANCH_ACCURACY: begin
                // Display branch prediction accuracy.
                ledPattern = {8'd0, processedBranchAccuracy};
            end
            
            MODE_DEMO_STATUS: begin
                // Display demo status and phase.
                ledPattern[15] = demoActive;
                ledPattern[14:12] = demoPhase;
                ledPattern[11:8] = workloadFormat;
                ledPattern[7:0] = processedBranchAccuracy;
            end
            
            MODE_WORKLOAD_CLASS: begin
                // Display workload classification.
                ledPattern[15:12] = workloadFormat;
                ledPattern[11:8] = frequencyLevel;
                ledPattern[7:4] = powerState;
                ledPattern[3:0] = systemHealth;
            end
            
            MODE_ALL_ON: begin
                // All LEDs on for testing.
                ledPattern = 16'hFFFF;
            end
            
            MODE_PATTERN_TEST: begin
                // Animated test pattern.
                case (animationPhase[1:0])
                    2'd0: ledPattern = 16'h5555; // Alternating pattern.
                    2'd1: ledPattern = 16'hAAAA; // Inverted pattern.
                    2'd2: ledPattern = 16'hFF00; // Upper half.
                    2'd3: ledPattern = 16'h00FF; // Lower half.
                endcase
            end
            
            MODE_HEARTBEAT: begin
                // Heartbeat pattern showing system alive.
                if (animationCounter < HEARTBEAT_SPEED / 4) begin
                    ledPattern = 16'h0001; // Single LED.
                end else if (animationCounter < HEARTBEAT_SPEED / 2) begin
                    ledPattern = 16'h0003; // Two LEDs.
                end else begin
                    ledPattern = 16'h0000; // Off.
                end
            end
            
            default: begin
                // Default to system status.
                ledPattern[15] = clockLocked;
                ledPattern[14] = processorActive;
                ledPattern[13:0] = 14'd0;
            end
        endcase
    end
    
    // ================================================================
    // RGB LED CONTROL
    // ================================================================
    
    // Control RGB LED 16 based on system status.
    always @(*) begin
        case (systemHealth)
            4'd0, 4'd1: begin
                // Poor health - red.
                led16_r = 1'b1;
                led16_g = 1'b0;
                led16_b = 1'b0;
            end
            4'd2: begin
                // Fair health - yellow.
                led16_r = 1'b1;
                led16_g = 1'b1;
                led16_b = 1'b0;
            end
            4'd3, 4'd4: begin
                // Good health - green.
                led16_r = 1'b0;
                led16_g = 1'b1;
                led16_b = 1'b0;
            end
            default: begin
                // Excellent health - blue.
                led16_r = 1'b0;
                led16_g = 1'b0;
                led16_b = 1'b1;
            end
        endcase
    end
    
    // Control RGB LED 17 based on demo and workload status.
    always @(*) begin
        if (demoActive) begin
            // Demo mode - cycling colors.
            case (rgbPhase[1:0])
                2'd0: begin
                    led17_r = 1'b1;
                    led17_g = 1'b0;
                    led17_b = 1'b0;
                end
                2'd1: begin
                    led17_r = 1'b0;
                    led17_g = 1'b1;
                    led17_b = 1'b0;
                end
                2'd2: begin
                    led17_r = 1'b0;
                    led17_g = 1'b0;
                    led17_b = 1'b1;
                end
                2'd3: begin
                    led17_r = 1'b1;
                    led17_g = 1'b1;
                    led17_b = 1'b1;
                end
            endcase
        end else begin
            // Normal mode - workload classification colors.
            case (workloadFormat[1:0])
                2'd0: begin
                    // Idle - dim white.
                    led17_r = rgbPhase[2];
                    led17_g = rgbPhase[2];
                    led17_b = rgbPhase[2];
                end
                2'd1: begin
                    // Compute intensive - red.
                    led17_r = 1'b1;
                    led17_g = 1'b0;
                    led17_b = 1'b0;
                end
                2'd2: begin
                    // Memory intensive - green.
                    led17_r = 1'b0;
                    led17_g = 1'b1;
                    led17_b = 1'b0;
                end
                2'd3: begin
                    // Control intensive - blue.
                    led17_r = 1'b0;
                    led17_g = 1'b0;
                    led17_b = 1'b1;
                end
            endcase
        end
    end
    
    // ================================================================
    // OUTPUT ASSIGNMENT
    // ================================================================
    
    // Assign LED pattern to output.
    always @(posedge clk) begin
        if (reset) begin
            led <= 16'h0000;
        end else begin
            led <= ledPattern;
        end
    end

endmodule