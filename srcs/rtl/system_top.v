// ================================================================
// SYSTEM TOP FIX - CORRECTED RESET POLARITY AND INSTRUCTION HANDSHAKE
// Fixed reset polarity issue and improved instruction generation timing
// ================================================================

`timescale 1ns / 1ps

module system_top (
    // ================================================================
    // FPGA BOARD INTERFACE
    // ================================================================
    
    // Clock and reset from Z7-20 board.
    input wire clk,               // 100MHz board clock (CLK100MHZ).
    input wire btnC,              // Center button for system reset.
    input wire btnU,              // Up button for demo control.
    input wire btnD,              // Down button for demo control.
    input wire btnL,              // Left button for frequency control.
    input wire btnR,              // Right button for frequency control.
    
    // Switch inputs for system control.
    input wire [15:0] sw,         // 16 switches for various controls.
    
    // LED outputs for status display.
    output wire [15:0] led,       // 16 LEDs for system status.
    
    // 7-segment display for detailed status.
    output wire [6:0] seg,        // 7-segment display segments.
    output wire [3:0] an,         // 7-segment display anodes.
    output wire dp,               // 7-segment decimal point.
    
    // RGB LEDs for advanced status indication.
    output wire led16_b,          // LED16 blue.
    output wire led16_g,          // LED16 green.
    output wire led16_r,          // LED16 red.
    output wire led17_b,          // LED17 blue.
    output wire led17_g,          // LED17 green.
    output wire led17_r,          // LED17 red.
    
    // UART interface for debugging (optional).
    output wire uart_txd_in,      // UART transmit.
    input wire uart_rxd_out,      // UART receive.
    
    // Debug output for processor reset signal.
    output wire debug_processor_reset  // Debug output for processor reset signal.
);

    // ================================================================
    // INTERNAL SIGNALS AND PARAMETERS
    // ================================================================
    
    // System clocks and resets.
    wire clkCore;                 // Variable frequency processor clock.
    wire clkMemory;               // Memory interface clock.
    wire clkPeripheral;           // Peripheral clock.
    wire clkDebug;                // Debug clock.
    wire systemResetRaw;          // Raw reset from button.
    reg systemReset;              // Synchronized system reset (ACTIVE LOW).
    wire processorReset;          // Processor domain reset (ACTIVE LOW).
    
    // Clock management signals.
    wire clockLocked;             // Clock stability indicator.
    wire clockStable;             // Clock stability indicator.
    reg [2:0] frequencyLevel;     // Current frequency level.
    reg [2:0] actualFrequencyLevel; // Actual frequency from clock manager.
    wire [2:0] frequencyLevel_wire;
    assign frequencyLevel_wire = frequencyLevel;
    wire thermalThrottle;         // Thermal throttling active.
    
    // Button debouncing signals.
    wire btnCDebounced;           // Debounced center button.
    wire btnUDebounced;           // Debounced up button.
    wire btnDDebounced;           // Debounced down button.
    wire btnLDebounced;           // Debounced left button.
    wire btnRDebounced;           // Debounced right button.
    
    // Power management and control.
    wire powerOptimizationActive; // Power optimization enabled.
    wire [7:0] powerBudget;       // Power budget for system.
    wire [7:0] thermalReading;    // Simulated thermal reading.
    wire [7:0] batteryLevel;      // Simulated battery level.
    wire performanceMode;         // Performance mode flag.
    
    // Processor core interface signals.
    wire [31:0] currentPC;        // Program counter value.
    wire [31:0] totalInstructions; // Instructions executed.
    wire [31:0] totalCycles;      // Processor cycles.
    wire [31:0] totalBranches;    // Branch instructions.
    wire [7:0] branchAccuracy;    // Branch prediction accuracy.
    wire [7:0] currentTotalPower; // Total power consumption.
    wire [2:0] currentPowerState; // Current power state.
    wire [2:0] currentWorkloadFormat; // Workload classification.
    wire instructionComplete;    // Instruction completion flag.
    wire requestNextInstruction; // Instruction request from enhanced core.
    
    // Demo program control.
    reg [31:0] demoModeCounter;   // Demo mode timer.
    reg [2:0] demoPhase;          // Current demo phase.
    reg demoActive;               // Demo mode active.
    
    // ================================================================
    // CORRECTED INSTRUCTION GENERATION
    // ================================================================
    
    // Instruction generation for demo.
    reg [31:0] currentInstruction; // Current instruction.
    reg validInstruction;         // Instruction validity flag.
    reg [31:0] instructionCounter; // Demo instruction counter.
    reg [7:0] postResetDelay;     // Delay after reset before starting instructions.
    
    // Status display control.
    wire [31:0] displayValue;     // Value to display on 7-segment.
    wire [3:0] displayMode;       // Display mode selector.

    // Reset synchronization registers.
    reg [2:0] resetSyncReg;       // Reset synchronizer chain.
    
    // Clock management stub for simulation.
    reg clockManagerLocked;       // Internal lock signal.
    reg [7:0] lockCounter;        // Lock time counter.
    
    // Initialize clock management signals.
    initial begin
        clockManagerLocked = 1'b0;
        lockCounter = 8'd0;
    end

    // ================================================================
    // INPUT DEBOUNCING
    // ================================================================
    
    // Button debouncer instances for clean input signals.
    debouncer #(.DEBOUNCE_DELAY(20'd10000)) btnCDeb (
        .clk(clk),
        .buttonIn(btnC),
        .buttonOut(btnCDebounced)
    );
    
    debouncer #(.DEBOUNCE_DELAY(20'd10000)) btnUDeb (
        .clk(clk),
        .buttonIn(btnU),
        .buttonOut(btnUDebounced)
    );
    
    debouncer #(.DEBOUNCE_DELAY(20'd10000)) btnDDeb (
        .clk(clk),
        .buttonIn(btnD),
        .buttonOut(btnDDebounced)
    );
    
    debouncer #(.DEBOUNCE_DELAY(20'd10000)) btnLDeb (
        .clk(clk),
        .buttonIn(btnL),
        .buttonOut(btnLDebounced)
    );
    
    debouncer #(.DEBOUNCE_DELAY(20'd10000)) btnRDeb (
        .clk(clk),
        .buttonIn(btnR),
        .buttonOut(btnRDebounced)
    );

    // ================================================================
    // RESET SYNCHRONIZATION
    // ================================================================
    
    // Raw reset assignment.
    assign systemResetRaw = btnCDebounced;
    
    // Reset synchronization for better simulation performance.
    always @(posedge clk or posedge systemResetRaw) begin
        if (systemResetRaw) begin
            resetSyncReg <= 3'b000;
            systemReset <= 1'b0;
        end else begin
            resetSyncReg <= {resetSyncReg[1:0], 1'b1};
            systemReset <= resetSyncReg[2];
        end
    end
    
    // Processor reset depends on system reset and clock lock - ACTIVE LOW for enhanced_core.
    // Remove circular dependency by making processor reset independent of clock lock initially.
    assign processorReset = systemReset;
    
    // Debug output for processor reset signal.
    assign debug_processor_reset = processorReset;

    // ================================================================
    // SIMPLIFIED CLOCK MANAGEMENT FOR SIMULATION
    // ================================================================
    
    // For simulation, use simplified clock management to avoid complexity.
    // Remove dependency on systemReset to avoid circular dependency.
    always @(posedge clk) begin
        if (lockCounter < 8'd50) begin
            lockCounter <= lockCounter + 8'd1;
            clockManagerLocked <= 1'b0;
        end else begin
            clockManagerLocked <= 1'b1;
        end
    end
    
    // Clock assignments.
    assign clkCore = clk;         // Use input clock directly for simulation.
    assign clkMemory = clk;       // Use input clock directly for simulation.
    assign clkPeripheral = clk;   // Use input clock directly for simulation.
    assign clkDebug = clk;        // Use input clock directly for simulation.
    assign clockLocked = clockManagerLocked;
    assign clockStable = clockManagerLocked;

    // ================================================================
    // SYSTEM CONTROL AND DEMO LOGIC
    // ================================================================
    
    // Control signal assignments from switches.
    assign powerOptimizationActive = sw[15]; // Switch 15 enables power optimization.
    assign powerBudget = {sw[14:12], 5'b11111}; // Switches 14-12 control power budget.
    assign thermalReading = {sw[11:8], 4'b0000}; // Switches 11-8 simulate thermal sensor.
    assign batteryLevel = 8'hC0;          // Simulated high battery level.
    assign performanceMode = sw[7];       // Switch 7 controls performance mode.
    
    // Frequency level control.
    always @(posedge clkPeripheral or negedge processorReset) begin
        if (!processorReset) begin
            frequencyLevel <= 3'b010; // Default to safe level.
            actualFrequencyLevel <= 3'b010;
        end else begin
            if (sw[6]) begin
                frequencyLevel <= {1'b0, sw[2:1]}; // Use switch control.
                actualFrequencyLevel <= {1'b0, sw[2:1]};
            end else begin
                frequencyLevel <= 3'b010; // Default safe level.
                actualFrequencyLevel <= 3'b010;
            end
        end
    end
    
    // Demo mode control logic.
    always @(posedge clkPeripheral or negedge processorReset) begin
        if (!processorReset) begin
            demoActive <= 1'b0;
            demoPhase <= 3'd0;
            demoModeCounter <= 32'd0;
        end else begin
            // Demo mode activation.
            if (btnUDebounced && !demoActive) begin
                demoActive <= 1'b1;
                demoPhase <= 3'd1;
                demoModeCounter <= 32'd0;
            end else if (btnDDebounced) begin
                demoActive <= 1'b0;
                demoPhase <= 3'd0;
            end
            
            // Demo phase progression.
            if (demoActive) begin
                demoModeCounter <= demoModeCounter + 32'd1;
                
                // Change demo phase every 500k cycles for simulation.
                if (demoModeCounter >= 32'd500000) begin
                    demoModeCounter <= 32'd0;
                    demoPhase <= (demoPhase == 3'd7) ? 3'd1 : demoPhase + 3'd1;
                end
            end
        end
    end

    // ================================================================
    // CORRECTED INSTRUCTION GENERATION WITH PROPER TIMING
    // ================================================================
    
    // Generate simple RISC-V instructions with proper handshake protocol.
    always @(posedge clkCore or negedge processorReset) begin
        if (!processorReset) begin
            currentInstruction <= 32'h00000013; // NOP instruction (ADDI x0, x0, 0).
            validInstruction <= 1'b0;
            instructionCounter <= 32'd0;
            postResetDelay <= 8'd0;
        end else begin
            // Wait for processor to fully initialize after reset.
            if (postResetDelay < 8'd20) begin
                postResetDelay <= postResetDelay + 1;
                validInstruction <= 1'b0;
                currentInstruction <= 32'h00000013; // Keep providing NOP during startup.
            end else begin
                // Provide instructions based on request signal from enhanced_core.
                if (requestNextInstruction) begin
                    // Core is requesting next instruction - provide new one.
                    instructionCounter <= instructionCounter + 1;
                    validInstruction <= 1'b1;
                    
                    // Generate different instruction patterns based on demo phase.
                    case (demoPhase)
                        3'd1: begin
                            // Phase 1: Arithmetic operations.
                            case (instructionCounter[3:0])
                                4'h0: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                                4'h1: currentInstruction <= 32'h002080B3; // ADD  x1, x1, x2
                                4'h2: currentInstruction <= 32'h40208133; // SUB  x2, x1, x2
                                4'h3: currentInstruction <= 32'h0020F1B3; // AND  x3, x1, x2
                                4'h4: currentInstruction <= 32'h0020E233; // OR   x4, x1, x2
                                4'h5: currentInstruction <= 32'h0020C2B3; // XOR  x5, x1, x2
                                4'h6: currentInstruction <= 32'h00209333; // SLL  x6, x1, x2
                                4'h7: currentInstruction <= 32'h0020D3B3; // SRL  x7, x1, x2
                                4'h8: currentInstruction <= 32'h4020D433; // SRA  x8, x1, x2
                                4'h9: currentInstruction <= 32'h0020A4B3; // SLT  x9, x1, x2
                                4'hA: currentInstruction <= 32'h0020B533; // SLTU x10, x1, x2
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                        
                        3'd2: begin
                            // Phase 2: Immediate operations.
                            case (instructionCounter[3:0])
                                4'h0: currentInstruction <= 32'h00508093; // ADDI x1, x1, 5
                                4'h1: currentInstruction <= 32'h0070F113; // ANDI x2, x1, 7
                                4'h2: currentInstruction <= 32'h00A0E193; // ORI  x3, x1, 10
                                4'h3: currentInstruction <= 32'h00C0C213; // XORI x4, x1, 12
                                4'h4: currentInstruction <= 32'h00309293; // SLLI x5, x1, 3
                                4'h5: currentInstruction <= 32'h0040D313; // SRLI x6, x1, 4
                                4'h6: currentInstruction <= 32'h4050D393; // SRAI x7, x1, 5
                                4'h7: currentInstruction <= 32'h00A0A413; // SLTI x8, x1, 10
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                        
                        3'd3: begin
                            // Phase 3: Branch-heavy workload.
                            case (instructionCounter[2:0])
                                3'h0: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                                3'h1: currentInstruction <= 32'h00208113; // ADDI x2, x1, 2
                                3'h2: currentInstruction <= 32'h00208063; // BEQ  x1, x2, +0
                                3'h3: currentInstruction <= 32'h00209063; // BNE  x1, x2, +0
                                3'h4: currentInstruction <= 32'h0020C063; // BLT  x1, x2, +0
                                3'h5: currentInstruction <= 32'h0020D063; // BGE  x1, x2, +0
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                        
                        default: begin
                            // Default: Simple continuous instruction pattern.
                            case (instructionCounter[2:0])
                                3'h0: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                                3'h1: currentInstruction <= 32'h002080B3; // ADD  x1, x1, x2
                                3'h2: currentInstruction <= 32'h40208133; // SUB  x2, x1, x2
                                3'h3: currentInstruction <= 32'h0020F1B3; // AND  x3, x1, x2
                                3'h4: currentInstruction <= 32'h00208063; // BEQ  x1, x2, +0
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                    endcase
                end else if (instructionCounter == 32'd0) begin
                    // Provide first instruction after startup delay.
                    validInstruction <= 1'b1;
                    currentInstruction <= 32'h00108093; // Start with ADDI x1, x1, 1.
                    instructionCounter <= 32'd1;
                end else if (instructionComplete) begin
                    // Instruction completed - provide next instruction.
                    instructionCounter <= instructionCounter + 1;
                    validInstruction <= 1'b1;
                    
                    // Generate next instruction based on demo phase.
                    case (demoPhase)
                        3'd1: begin
                            // Phase 1: Arithmetic operations.
                            case (instructionCounter[3:0])
                                4'h0: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                                4'h1: currentInstruction <= 32'h002080B3; // ADD  x1, x1, x2
                                4'h2: currentInstruction <= 32'h40208133; // SUB  x2, x1, x2
                                4'h3: currentInstruction <= 32'h0020F1B3; // AND  x3, x1, x2
                                4'h4: currentInstruction <= 32'h0020E233; // OR   x4, x1, x2
                                4'h5: currentInstruction <= 32'h0020C2B3; // XOR  x5, x1, x2
                                4'h6: currentInstruction <= 32'h00209333; // SLL  x6, x1, x2
                                4'h7: currentInstruction <= 32'h0020D3B3; // SRL  x7, x1, x2
                                4'h8: currentInstruction <= 32'h4020D433; // SRA  x8, x1, x2
                                4'h9: currentInstruction <= 32'h0020A4B3; // SLT  x9, x1, x2
                                4'hA: currentInstruction <= 32'h0020B533; // SLTU x10, x1, x2
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                        
                        3'd2: begin
                            // Phase 2: Immediate operations.
                            case (instructionCounter[3:0])
                                4'h0: currentInstruction <= 32'h00508093; // ADDI x1, x1, 5
                                4'h1: currentInstruction <= 32'h0070F113; // ANDI x2, x1, 7
                                4'h2: currentInstruction <= 32'h00A0E193; // ORI  x3, x1, 10
                                4'h3: currentInstruction <= 32'h00C0C213; // XORI x4, x1, 12
                                4'h4: currentInstruction <= 32'h00309293; // SLLI x5, x1, 3
                                4'h5: currentInstruction <= 32'h0040D313; // SRLI x6, x1, 4
                                4'h6: currentInstruction <= 32'h4050D393; // SRAI x7, x1, 5
                                4'h7: currentInstruction <= 32'h00A0A413; // SLTI x8, x1, 10
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                        
                        3'd3: begin
                            // Phase 3: Branch-heavy workload.
                            case (instructionCounter[2:0])
                                3'h0: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                                3'h1: currentInstruction <= 32'h00208113; // ADDI x2, x1, 2
                                3'h2: currentInstruction <= 32'h00208063; // BEQ  x1, x2, +0
                                3'h3: currentInstruction <= 32'h00209063; // BNE  x1, x2, +0
                                3'h4: currentInstruction <= 32'h0020C063; // BLT  x1, x2, +0
                                3'h5: currentInstruction <= 32'h0020D063; // BGE  x1, x2, +0
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                        
                        default: begin
                            // Default: Simple continuous instruction pattern.
                            case (instructionCounter[2:0])
                                3'h0: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                                3'h1: currentInstruction <= 32'h002080B3; // ADD  x1, x1, x2
                                3'h2: currentInstruction <= 32'h40208133; // SUB  x2, x1, x2
                                3'h3: currentInstruction <= 32'h0020F1B3; // AND  x3, x1, x2
                                3'h4: currentInstruction <= 32'h00208063; // BEQ  x1, x2, +0
                                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                            endcase
                        end
                    endcase
                end else begin
                    // Hold current instruction until instruction completes.
                    validInstruction <= 1'b1;
                end
            end
        end
    end

    // ================================================================
    // ENHANCED RISC-V PROCESSOR CORE
    // ================================================================
    
    enhanced_core processorCore (
        .clk(clkCore),
        .reset(processorReset),
        .instruction(currentInstruction),
        .validInstruction(validInstruction),
        .requestNextInstruction(requestNextInstruction),
        .powerBudget(powerBudget),
        .thermalReading(thermalReading),
        .batteryLevel(batteryLevel),
        .performanceMode(performanceMode),
        .instructionComplete(instructionComplete),
        .branchTaken(),
        .branchTarget(),
        .totalInstructions(totalInstructions),
        .totalCycles(totalCycles),
        .totalBranches(totalBranches),
        .correctPredictions(),
        .branchAccuracy(branchAccuracy),
        .totalOperationsALU(),
        .totalRegAccesses(),
        .currentWorkloadFormat(currentWorkloadFormat),
        .workloadConfidence(),
        .computeToll(),
        .memToll(),
        .controlToll(),
        .complexPattern(),
        .workloadClassificationValid(),
        .currentPowerState(currentPowerState),
        .clockFrequencyLevel(frequencyLevel_wire),
        .voltageLevel(),
        .currentTotalPower(currentTotalPower),
        .powerEfficiency(),
        .temperatureEstimate(),
        .energySaved(),
        .powerOptimizationActive(),
        .thermalThrottle(thermalThrottle),
        .powerGateALU(),
        .powerGateRegister(),
        .powerGateBranchPredictor(),
        .powerGateCache(),
        .rs1Debug(),
        .rs2Debug(),
        .rdDebug(),
        .rsData1Debug(),
        .rsData2Debug(),
        .resultALUDebug(),
        .currentPC(currentPC),
        .pipelineStage(),
        .adaptationRate(),
        .powerTrend()
    );

    // ================================================================
    // LED STATUS DISPLAY
    // ================================================================
    
    led_display statusDisplay (
        .clk(clkPeripheral),
        .reset(~processorReset),
        .clockLocked(clockLocked),
        .processorActive(processorReset),
        .frequencyLevel({1'b0, actualFrequencyLevel}),
        .powerState({1'b0, currentPowerState}),
        .workloadFormat({1'b0, currentWorkloadFormat}),
        .thermalThrottle(thermalThrottle),
        .branchAccuracy({8'b0, branchAccuracy}),
        .demoActive(demoActive),
        .demoPhase(demoPhase),
        .switchInputs(sw[14:0]),
        .led(led),
        .led16_r(led16_r),
        .led16_g(led16_g),
        .led16_b(led16_b),
        .led17_r(led17_r),
        .led17_g(led17_g),
        .led17_b(led17_b)
    );

    // ================================================================
    // 7-SEGMENT DISPLAY CONTROL
    // ================================================================
    
    // Display mode selection based on switches.
    assign displayMode = sw[3:0];
    
    // Multiplex display value based on mode.
    assign displayValue = (displayMode == 4'h0) ? currentPC :
                         (displayMode == 4'h1) ? totalInstructions :
                         (displayMode == 4'h2) ? totalCycles :
                         (displayMode == 4'h3) ? {24'h0, branchAccuracy} :
                         (displayMode == 4'h4) ? {24'h0, currentTotalPower} :
                         (displayMode == 4'h5) ? instructionCounter :
                         (displayMode == 4'h6) ? {29'h0, actualFrequencyLevel} :
                         (displayMode == 4'h7) ? {29'h0, currentPowerState} :
                         (displayMode == 4'h8) ? {29'h0, currentWorkloadFormat} :
                         (displayMode == 4'h9) ? currentInstruction :
                         32'hDEADBEEF;
    
    // 7-segment display controller.
    seven_segment_display displayController (
        .clk(clkPeripheral),
        .reset(~processorReset),
        .value(displayValue),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // ================================================================
    // UART DEBUG INTERFACE
    // ================================================================
    
    // Simple UART transmitter for debugging output.
    uart_transmitter debugUART (
        .clk(clkDebug),
        .reset(~processorReset),
        .transmitEnable(sw[13]),
        .programCounter(currentPC),
        .instructionCounter(totalInstructions),
        .branchAccuracy(branchAccuracy),
        .powerState({1'b0, currentPowerState}),
        .uart_tx(uart_txd_in)
    );

endmodule

// ================================================================
// BUTTON DEBOUNCER MODULE
// ================================================================

module debouncer #(
    parameter DEBOUNCE_DELAY = 20'd10000
)(
    input wire clk,
    input wire buttonIn,
    output reg buttonOut
);

    reg [19:0] counter;
    reg buttonSync;
    
    initial begin
        buttonOut = 1'b0;
        counter = 20'd0;
        buttonSync = 1'b0;
    end
    
    always @(posedge clk) begin
        buttonSync <= buttonIn;
        
        if (buttonOut == buttonSync) begin
            counter <= 20'd0;
        end else begin
            counter <= counter + 20'd1;
            if (counter >= DEBOUNCE_DELAY) begin
                buttonOut <= buttonSync;
            end
        end
    end

endmodule

// ================================================================
// 7-SEGMENT DISPLAY CONTROLLER
// ================================================================

module seven_segment_display (
    input wire clk,
    input wire reset,
    input wire [31:0] value,
    output reg [6:0] seg,
    output reg [3:0] an,
    output reg dp
);

    parameter REFRESH_RATE = 16'd5000;
    
    reg [15:0] refreshCounter;
    reg [1:0] digitSelect;
    reg [3:0] currentDigit;
    
    initial begin
        refreshCounter = 16'd0;
        digitSelect = 2'd0;
        seg = 7'b1111111;
        an = 4'b1111;
        dp = 1'b1;
    end
    
    always @(posedge clk) begin
        if (reset) begin
            refreshCounter <= 16'd0;
            digitSelect <= 2'd0;
        end else begin
            refreshCounter <= refreshCounter + 16'd1;
            if (refreshCounter == 16'd0) begin
                digitSelect <= digitSelect + 2'd1;
            end
        end
    end
    
    always @(*) begin
        case (digitSelect)
            2'd0: currentDigit = value[3:0];
            2'd1: currentDigit = value[7:4];
            2'd2: currentDigit = value[11:8];
            2'd3: currentDigit = value[15:12];
        endcase
    end
    
    always @(*) begin
        an = 4'b1111;
        an[digitSelect] = 1'b0;
    end
    
    always @(*) begin
        dp = 1'b1;
        case (currentDigit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
        endcase
    end

endmodule

// ================================================================
// UART TRANSMITTER
// ================================================================

module uart_transmitter (
    input wire clk,
    input wire reset,
    input wire transmitEnable,
    input wire [31:0] programCounter,
    input wire [31:0] instructionCounter,
    input wire [7:0] branchAccuracy,
    input wire [3:0] powerState,
    output reg uart_tx
);

    parameter BAUD_RATE = 16'd434;
    
    reg [15:0] baudCounter;
    reg [7:0] transmitData;
    reg [3:0] bitIndex;
    reg transmitting;
    reg [31:0] transmitTimer;
    
    initial begin
        uart_tx = 1'b1;
        transmitting = 1'b0;
        transmitTimer = 32'd0;
        baudCounter = 16'd0;
        bitIndex = 4'd0;
    end
    
    always @(posedge clk) begin
        if (reset) begin
            uart_tx <= 1'b1;
            transmitting <= 1'b0;
            transmitTimer <= 32'd0;
            baudCounter <= 16'd0;
            bitIndex <= 4'd0;
        end else if (transmitEnable) begin
            transmitTimer <= transmitTimer + 32'd1;
            
            if (transmitTimer >= 32'd250000 && !transmitting) begin
                transmitTimer <= 32'd0;
                transmitting <= 1'b1;
                transmitData <= 8'h50; // ASCII 'P'
                bitIndex <= 4'd0;
                baudCounter <= 16'd0;
            end
            
            if (transmitting) begin
                baudCounter <= baudCounter + 16'd1;
                if (baudCounter >= BAUD_RATE) begin
                    baudCounter <= 16'd0;
                    bitIndex <= bitIndex + 4'd1;
                    
                    case (bitIndex)
                        4'd0: uart_tx <= 1'b0;
                        4'd1: uart_tx <= transmitData[0];
                        4'd2: uart_tx <= transmitData[1];
                        4'd3: uart_tx <= transmitData[2];
                        4'd4: uart_tx <= transmitData[3];
                        4'd5: uart_tx <= transmitData[4];
                        4'd6: uart_tx <= transmitData[5];
                        4'd7: uart_tx <= transmitData[6];
                        4'd8: uart_tx <= transmitData[7];
                        4'd9: uart_tx <= 1'b1;
                        default: begin
                            uart_tx <= 1'b1;
                            transmitting <= 1'b0;
                        end
                    endcase
                end
            end
        end else begin
            uart_tx <= 1'b1;
        end
    end

endmodule