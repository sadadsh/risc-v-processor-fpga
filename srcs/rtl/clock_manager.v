`timescale 1ns / 1ps

// CLOCK MANAGER MODULE
// Engineer: Sadad Haidari
//
// This module manages clock generation for the RISC-V processor with advanced power management.
// Features:
// - MMCM-based clock generation for multiple frequency levels
// - Power-aware frequency selection from power optimizer
// - Thermal protection and emergency frequency scaling
// - Lock detection and status monitoring
// - Supports frequencies from 12.5MHz to 100MHz

module clock_manager (
    // PRIMARY CLOCK INPUT
    input wire clkInput,                    // 100MHz input clock from FPGA.
    input wire reset,                       // Active LOW reset signal.
    
    // POWER MANAGEMENT INTERFACE  
    input wire [2:0] frequencyLevel,        // Requested frequency level (0-7).
    input wire thermalThrottle,             // Emergency thermal throttling enable.
    input wire [7:0] powerBudget,           // Available power budget for clock scaling.
    input wire emergencyMode,               // Emergency mode forces minimum frequency.
    
    // GENERATED CLOCK OUTPUTS
    output wire clkCore,                    // Main processor core clock.
    output wire clkMemory,                  // Memory interface clock (typically 2x core).
    output wire clkPeripheral,              // Peripheral clock (typically core/2).
    output wire clkDebug,                   // Debug interface clock (fixed 25MHz).
    
    // STATUS AND MONITORING OUTPUTS
    output wire clockLocked,                // MMCM lock status indicator.
    output wire clockStable,                // Clock stability indicator.
    output reg [2:0] actualFrequencyLevel, // Current active frequency level.
    output reg [15:0] lockCounter,          // Lock acquisition time counter.
    output wire [7:0] clockPowerEstimate,   // Estimated power consumption of clocks.
    
    // FREQUENCY MEASUREMENT OUTPUTS (FOR TESTBENCH)
    output reg [15:0] coreClockPeriod,      // Measured core clock period in ns*100.
    output reg clockTransition              // High during frequency transitions.
);

    // INTERNAL CLOCK SIGNALS FROM MMCM
    wire clkOut100;         // 100MHz output from MMCM.
    wire clkOut87_5;        // 87.5MHz output from MMCM.
    wire clkOut75;          // 75MHz output from MMCM.  
    wire clkOut50;          // 50MHz output from MMCM.
    wire clkOut25;          // 25MHz output from MMCM.
    wire clkOut12_5;        // 12.5MHz output from MMCM.
    wire clkFeedback;       // MMCM feedback clock.
    wire mmcmLocked;        // MMCM lock status.
    wire mmcmReset;         // MMCM reset control.
    
    // CLOCK SELECTION AND CONTROL REGISTERS
    reg [2:0] targetFrequencyLevel;         // Target frequency level after thermal/power checks.
    reg [2:0] previousFrequencyLevel;       // Previous frequency level for transition detection.
    reg [7:0] stabilityCounter;             // Counter for clock stability verification.
    reg [7:0] transitionTimer;              // Timer for controlled frequency transitions.
    reg resetSynchronizer1, resetSynchronizer2; // Reset synchronization registers.
    reg lockSynchronizer1, lockSynchronizer2;   // Lock synchronization registers.
    reg clkCoreInternal;                    // Internal core clock selection.
    
    // FREQUENCY MEASUREMENT REGISTERS
    reg [15:0] periodMeasureCounter;        // Counter for period measurement.
    reg periodMeasureEnable;                // Enable period measurement.
    reg coreClockPreviousEdge;              // Previous edge state for period measurement.
    
    // POWER ESTIMATION CONSTANTS
    localparam [7:0] POWERBASE = 8'd10;     // Base power consumption for clock generation.
    localparam [7:0] POWERPERMHZ = 8'd2;    // Additional power per MHz.
    
    // FREQUENCY LEVEL TO MHZ MAPPING
    // Updated to reflect actual MMCM output frequencies.
    function [7:0] getFrequencyMHz;
        input [2:0] level;
        begin
            case (level)
                3'b000: getFrequencyMHz = 8'd12;   // 12.5MHz (rounded for calculation).
                3'b001: getFrequencyMHz = 8'd25;   // 25MHz.
                3'b010: getFrequencyMHz = 8'd50;   // 50MHz.
                3'b011: getFrequencyMHz = 8'd78;   // ~77.8MHz (closest achievable to 75MHz).
                3'b100: getFrequencyMHz = 8'd87;   // 87.5MHz (rounded).
                3'b101: getFrequencyMHz = 8'd100;  // 100MHz.
                3'b110: getFrequencyMHz = 8'd100;  // 100MHz (high performance).
                3'b111: getFrequencyMHz = 8'd100;  // 100MHz (maximum).
                default: getFrequencyMHz = 8'd50;   // Default to 50MHz.
            endcase
        end
    endfunction
    
    // RESET SYNCHRONIZATION LOGIC
    // Properly synchronize the reset signal to avoid metastability.
    always @(posedge clkInput or negedge reset) begin
        if (!reset) begin
            resetSynchronizer1 <= 1'b0;
            resetSynchronizer2 <= 1'b0;
        end else begin
            resetSynchronizer1 <= 1'b1;
            resetSynchronizer2 <= resetSynchronizer1;
        end
    end
    
    assign mmcmReset = ~resetSynchronizer2;
    
    // LOCK SIGNAL SYNCHRONIZATION
    // Synchronize MMCM lock signal to input clock domain.
    always @(posedge clkInput or negedge reset) begin
        if (!reset) begin
            lockSynchronizer1 <= 1'b0;
            lockSynchronizer2 <= 1'b0;
        end else begin
            lockSynchronizer1 <= mmcmLocked;
            lockSynchronizer2 <= lockSynchronizer1;
        end
    end
    
    assign clockLocked = lockSynchronizer2;
    
    // XILINX MMCM PRIMITIVE INSTANTIATION
    // Generate multiple clock frequencies using Xilinx MMCM primitive.
    // For synthesis, we use the actual MMCM. For simulation, we use a behavioral model.
    
    `ifdef SYNTHESIS
        // REAL MMCM FOR SYNTHESIS
        MMCME2_BASE #(
            .BANDWIDTH("OPTIMIZED"),       // Jitter programming (OPTIMIZED, HIGH, LOW).
            .CLKFBOUT_MULT_F(7.0),        // Multiply value for all CLKOUT (700MHz VCO).
            .CLKFBOUT_PHASE(0.0),         // Phase offset in degrees of CLKFB (-360.000-360.000).
            .CLKIN1_PERIOD(10.0),         // Input clock period in ns (1.000-1000.000).
            // CLKOUT0-6: Clock output configuration - All frequencies directly generated.
            .CLKOUT0_DIVIDE_F(7.0),       // Divide amount for CLKOUT0 (1.000-128.000) - 100MHz.
            .CLKOUT1_DIVIDE(28),          // Divide amount for CLKOUT1 (1-128) - 25MHz.
            .CLKOUT2_DIVIDE(14),          // Divide amount for CLKOUT2 (1-128) - 50MHz.
            .CLKOUT3_DIVIDE(56),          // Divide amount for CLKOUT3 (1-128) - 12.5MHz.
            .CLKOUT4_DIVIDE(8),           // Divide amount for CLKOUT4 (1-128) - 87.5MHz.
            .CLKOUT5_DIVIDE(9),           // Divide amount for CLKOUT5 (1-128) - ~77.8MHz.
            .CLKOUT6_DIVIDE(1),           // Divide amount for CLKOUT6 (1-128) - 700MHz (unused).
            // CLKOUT0-6: Phase offset configuration.
            .CLKOUT0_PHASE(0.0),          // Phase offset for CLKOUT0 (-360.000-360.000).
            .CLKOUT1_PHASE(0.0),          // Phase offset for CLKOUT1 (-360.000-360.000).
            .CLKOUT2_PHASE(0.0),          // Phase offset for CLKOUT2 (-360.000-360.000).
            .CLKOUT3_PHASE(0.0),          // Phase offset for CLKOUT3 (-360.000-360.000).
            .CLKOUT4_PHASE(0.0),          // Phase offset for CLKOUT4 (-360.000-360.000).
            .CLKOUT5_PHASE(0.0),          // Phase offset for CLKOUT5 (-360.000-360.000).
            .CLKOUT6_PHASE(0.0),          // Phase offset for CLKOUT6 (-360.000-360.000).
            // CLKOUT0-6: Duty cycle configuration.
            .CLKOUT0_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT0 (0.01-0.99).
            .CLKOUT1_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT1 (0.01-0.99).
            .CLKOUT2_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT2 (0.01-0.99).
            .CLKOUT3_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT3 (0.01-0.99).
            .CLKOUT4_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT4 (0.01-0.99).
            .CLKOUT5_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT5 (0.01-0.99).
            .CLKOUT6_DUTY_CYCLE(0.5),     // Duty cycle for CLKOUT6 (0.01-0.99).
            .CLKOUT4_CASCADE("FALSE"),     // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE).
            .DIVCLK_DIVIDE(1),            // Master division value (1-106).
            .REF_JITTER1(0.0),            // Reference input jitter in UI (0.000-0.999).
            .STARTUP_WAIT("FALSE")        // Delays DONE until MMCM is locked (FALSE, TRUE).
        ) mmcmInstance (
            // Clock Feedback Signals
            .CLKFBOUT(clkFeedback),       // 1-bit output: Feedback clock.
            .CLKFBIN(clkFeedback),        // 1-bit input: Feedback clock.
            // Clock Outputs  
            .CLKOUT0(clkOut100),          // 1-bit output: CLKOUT0 - 100MHz.
            .CLKOUT0B(),                  // 1-bit output: Inverted CLKOUT0.
            .CLKOUT1(clkOut25),           // 1-bit output: CLKOUT1 - 25MHz.
            .CLKOUT1B(),                  // 1-bit output: Inverted CLKOUT1.
            .CLKOUT2(clkOut50),           // 1-bit output: CLKOUT2 - 50MHz.
            .CLKOUT2B(),                  // 1-bit output: Inverted CLKOUT2.
            .CLKOUT3(clkOut12_5),         // 1-bit output: CLKOUT3 - 12.5MHz.
            .CLKOUT3B(),                  // 1-bit output: Inverted CLKOUT3.
            .CLKOUT4(clkOut87_5),         // 1-bit output: CLKOUT4 - 87.5MHz.
            .CLKOUT5(clkOut75),           // 1-bit output: CLKOUT5 - ~77.8MHz (close to 75MHz).
            .CLKOUT6(),                   // 1-bit output: CLKOUT6 - Unused.
            // Status and Control Signals
            .LOCKED(mmcmLocked),          // 1-bit output: LOCK status indicator.
            .CLKIN1(clkInput),            // 1-bit input: Clock input.
            .PWRDWN(1'b0),                // 1-bit input: Power-down control.
            .RST(mmcmReset)               // 1-bit input: Reset.
        );
    `else
        // BEHAVIORAL MODEL FOR SIMULATION
        // This model generates the required frequencies using simple counters.
        
        reg [7:0] lockDelay;           // Delay before asserting lock.
        reg [5:0] divCounter100;       // Counter for 100MHz (divide by 1).
        reg [5:0] divCounter25;        // Counter for 25MHz (divide by 4).
        reg [5:0] divCounter50;        // Counter for 50MHz (divide by 2).
        reg [7:0] divCounter12_5;      // Counter for 12.5MHz (divide by 8).
        reg [5:0] divCounter87_5;      // Counter for 87.5MHz (special timing).
        reg [5:0] divCounter75;        // Counter for ~77.8MHz (divide by 1.28).
        
        reg clkOut100_reg;
        reg clkOut25_reg;
        reg clkOut50_reg;
        reg clkOut12_5_reg;
        reg clkOut87_5_reg;
        reg clkOut75_reg;
        
        // Lock simulation - assert lock after some delay.
        always @(posedge clkInput or posedge mmcmReset) begin
            if (mmcmReset) begin
                lockDelay <= 8'h00;
            end else begin
                if (lockDelay < 8'hFF) begin
                    lockDelay <= lockDelay + 1;
                end
            end
        end
        
        assign mmcmLocked = (lockDelay > 8'h20);  // Lock after 32 cycles.
        
        // Generate 100MHz (direct wire assignment for simulation).
        assign clkOut100 = mmcmReset ? 1'b0 : clkInput;
        
        // Generate 50MHz (divide by 2).
        always @(posedge clkInput or posedge mmcmReset) begin
            if (mmcmReset) begin
                divCounter50 <= 6'h0;
                clkOut50_reg <= 1'b0;
            end else begin
                divCounter50 <= divCounter50 + 1;
                if (divCounter50 == 6'h1) begin  // Toggle every 2 cycles = 50MHz.
                    clkOut50_reg <= ~clkOut50_reg;
                    divCounter50 <= 6'h0;
                end
            end
        end
        
        // Generate 25MHz (divide by 4).
        always @(posedge clkInput or posedge mmcmReset) begin
            if (mmcmReset) begin
                divCounter25 <= 6'h0;
                clkOut25_reg <= 1'b0;
            end else begin
                divCounter25 <= divCounter25 + 1;
                if (divCounter25 == 6'h3) begin  // Toggle every 4 cycles = 25MHz.
                    clkOut25_reg <= ~clkOut25_reg;
                    divCounter25 <= 6'h0;
                end
            end
        end
        
        // Generate 12.5MHz (divide by 8).
        always @(posedge clkInput or posedge mmcmReset) begin
            if (mmcmReset) begin
                divCounter12_5 <= 8'h0;
                clkOut12_5_reg <= 1'b0;
            end else begin
                divCounter12_5 <= divCounter12_5 + 1;
                if (divCounter12_5 == 8'h7) begin  // Toggle every 8 cycles = 12.5MHz.
                    clkOut12_5_reg <= ~clkOut12_5_reg;
                    divCounter12_5 <= 8'h0;
                end
            end
        end
        
        // Generate 87.5MHz (approximate - difficult to get exact in behavioral model).
        always @(posedge clkInput or posedge mmcmReset) begin
            if (mmcmReset) begin
                divCounter87_5 <= 6'h0;
                clkOut87_5_reg <= 1'b0;
            end else begin
                divCounter87_5 <= divCounter87_5 + 1;
                // Approximate 87.5MHz by toggling roughly every 1.14 cycles
                if (divCounter87_5 == 6'h0 || divCounter87_5 == 6'h2) begin
                    clkOut87_5_reg <= ~clkOut87_5_reg;
                end
                if (divCounter87_5 == 6'h2) begin
                    divCounter87_5 <= 6'h0;
                end
            end
        end
        
        // Generate ~77.8MHz (approximate with 9:10 ratio).
        always @(posedge clkInput or posedge mmcmReset) begin
            if (mmcmReset) begin
                divCounter75 <= 6'h0;
                clkOut75_reg <= 1'b0;
            end else begin
                divCounter75 <= divCounter75 + 1;
                // Toggle pattern to approximate 77.8MHz.
                if (divCounter75 == 6'h1 || divCounter75 == 6'h3) begin
                    clkOut75_reg <= ~clkOut75_reg;
                end
                if (divCounter75 == 6'h4) begin
                    divCounter75 <= 6'h0;
                end
            end
        end
        
        assign clkOut50 = clkOut50_reg;
        assign clkOut25 = clkOut25_reg;
        assign clkOut12_5 = clkOut12_5_reg;
        assign clkOut87_5 = clkOut87_5_reg;
        assign clkOut75 = clkOut75_reg;
        
        assign clkFeedback = clkInput;  // Simple feedback for simulation.
    `endif

    
    // FREQUENCY SELECTION AND TRANSITION MANAGEMENT
    // Safely transition between different frequency levels with proper sequencing.
    always @(posedge clkInput or negedge reset) begin
        if (!reset) begin
            targetFrequencyLevel <= 3'b010;     // Default to 50MHz.
            actualFrequencyLevel <= 3'b010;     // Start at 50MHz.
            previousFrequencyLevel <= 3'b010;   // Initialize previous level.
            stabilityCounter <= 8'h00;          // Reset stability counter.
            transitionTimer <= 8'h00;           // Reset transition timer.
            lockCounter <= 16'h0000;            // Reset lock counter.
            clockTransition <= 1'b0;            // Not in transition.
        end else if (clockLocked) begin
            // Increment lock counter while locked.
            if (lockCounter < 16'hFFFF) begin
                lockCounter <= lockCounter + 1;
            end
            
            // DETERMINE TARGET FREQUENCY BASED ON INPUTS
            if (emergencyMode || thermalThrottle) begin
                // Emergency mode or thermal throttling forces minimum frequency.
                targetFrequencyLevel <= 3'b000;  // 12.5MHz.
            end else if (powerBudget < 8'd50) begin
                // Low power budget limits frequency.
                targetFrequencyLevel <= (frequencyLevel > 3'b001) ? 3'b001 : frequencyLevel;  // Max 25MHz.
            end else if (powerBudget < 8'd80) begin
                // Medium power budget allows moderate frequencies.
                targetFrequencyLevel <= (frequencyLevel > 3'b010) ? 3'b010 : frequencyLevel;  // Max 50MHz.
            end else begin
                // High power budget allows all frequencies.
                targetFrequencyLevel <= frequencyLevel;
            end
            
            // FREQUENCY TRANSITION MANAGEMENT
            if (targetFrequencyLevel != actualFrequencyLevel) begin
                // Start transition process.
                clockTransition <= 1'b1;
                transitionTimer <= transitionTimer + 1;
                
                // Allow transition after sufficient delay for stability.
                if (transitionTimer >= 8'hFF) begin
                    previousFrequencyLevel <= actualFrequencyLevel;
                    actualFrequencyLevel <= targetFrequencyLevel;
                    transitionTimer <= 8'h00;
                    stabilityCounter <= 8'h00;  // Reset stability counter.
                end
            end else begin
                // No transition needed, increment stability.
                clockTransition <= 1'b0;
                transitionTimer <= 8'h00;
                if (stabilityCounter < 8'hFF) begin
                    stabilityCounter <= stabilityCounter + 1;
                end
            end
        end else begin
            // MMCM not locked, reset counters.
            lockCounter <= 16'h0000;
            stabilityCounter <= 8'h00;
            clockTransition <= 1'b0;
        end
    end
    
    // CLOCK OUTPUT MULTIPLEXING
    // Select the appropriate clock based on the current frequency level.
    always @(*) begin
        case (actualFrequencyLevel)
            3'b000: clkCoreInternal = clkOut12_5;   // 12.5MHz.
            3'b001: clkCoreInternal = clkOut25;     // 25MHz.
            3'b010: clkCoreInternal = clkOut50;     // 50MHz.
            3'b011: clkCoreInternal = clkOut75;     // 75MHz.
            3'b100: clkCoreInternal = clkOut87_5;   // 87.5MHz.
            3'b101: clkCoreInternal = clkOut100;    // 100MHz.
            3'b110: clkCoreInternal = clkOut100;    // 100MHz (high performance).
            3'b111: clkCoreInternal = clkOut100;    // 100MHz (maximum).
            default: clkCoreInternal = clkOut50;    // Default to 50MHz.
        endcase
    end
    
    // OUTPUT CLOCK ASSIGNMENTS
    assign clkCore = clkCoreInternal;       // Core clock.
    assign clkMemory = clkOut100;           // Memory always at 100MHz.
    assign clkPeripheral = clkOut25;        // Peripherals at 25MHz.
    assign clkDebug = clkOut25;             // Debug at 25MHz.
    
    // CLOCK STABILITY INDICATOR
    assign clockStable = clockLocked && (stabilityCounter > 8'h7F) && !clockTransition;
    
    // POWER CONSUMPTION ESTIMATION
    // Estimate power consumption based on active frequency level.
    assign clockPowerEstimate = POWERBASE + (getFrequencyMHz(actualFrequencyLevel) * POWERPERMHZ) / 8'd10;
    
    // FREQUENCY MEASUREMENT FOR TESTBENCH VERIFICATION
    // Measure the actual period of the core clock for testbench validation.
    always @(posedge clkInput or negedge reset) begin
        if (!reset) begin
            periodMeasureCounter <= 16'h0000;
            periodMeasureEnable <= 1'b0;
            coreClockPreviousEdge <= 1'b0;
            coreClockPeriod <= 16'h0000;
        end else if (clockLocked && clockStable) begin
            coreClockPreviousEdge <= clkCore;
            
            // Detect rising edge of core clock.
            if (clkCore && !coreClockPreviousEdge) begin
                if (periodMeasureEnable) begin
                    // Store measured period (in units of 0.1ns).
                    coreClockPeriod <= periodMeasureCounter;
                    periodMeasureCounter <= 16'h0000;
                end else begin
                    // Start measuring on first edge.
                    periodMeasureEnable <= 1'b1;
                    periodMeasureCounter <= 16'h0000;
                end
            end else begin
                // Increment counter every input clock cycle.
                if (periodMeasureCounter < 16'hFFFE) begin
                    periodMeasureCounter <= periodMeasureCounter + 1;
                end
            end
        end
    end

endmodule