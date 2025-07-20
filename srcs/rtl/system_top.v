`timescale 1ns / 1ps

// COMPLETE RISC-V SYSTEM WITH ENHANCED FEATURES
// Engineer: Sadad Haidari
// 
// This integrates the enhanced RISC-V processor with working I/O interface
// Features: Adaptive Branch Prediction + Intelligent Power Management

module system_top (
    // Clock
    input wire clk,
    
    // Working I/O Interface
    input wire [3:0] btn,  // Working buttons (active LOW)
    input wire [3:0] sw,   // Working switches  
    output wire [3:0] led, // Working LEDs (LD0-LD3)
    output wire led5_r, led5_g, led5_b,  // RGB LD5
    output wire led6_r, led6_g, led6_b,  // RGB LD6
    
    // UART Debug Output
    output wire uart_tx
);

    // ======================================================================
    // SYSTEM CONTROL AND TIMING
    // ======================================================================
    
    // Master counter for all timing
    reg [26:0] counter;
    always @(posedge clk) begin
        counter <= counter + 1;
    end
    
    // Multiple clock domains for processor and display
    wire displayClock = counter[20];    // ~60 Hz for LED updates
    wire processorClock = counter[3];   // ~15.6 MHz for processor (divide by 16)
    wire heartbeat = counter[25];       // ~1.5 Hz system heartbeat

    // ======================================================================
    // BUTTON AND SWITCH INTERFACE
    // ======================================================================
    
    // Clean button signals (handle active LOW)
    reg [3:0] btn_sync1, btn_sync2, btn_clean;
    always @(posedge clk) begin
        btn_sync1 <= ~btn;  // Invert active LOW buttons
        btn_sync2 <= btn_sync1;
        btn_clean <= btn_sync2;  // Synchronized button signals
    end
    
    // Button edge detection for single-press actions
    reg [3:0] btn_last;
    wire [3:0] btn_pressed;
    always @(posedge displayClock) begin
        btn_last <= btn_clean;
    end
    assign btn_pressed = btn_clean & ~btn_last;  // Rising edge detection

    // Switch interface (working perfectly)
    wire [3:0] sw_clean = sw;

    // ======================================================================
    // PROCESSOR CONTROL STATE MACHINE
    // ======================================================================
    
    // Processor control states
    localparam STATE_RESET      = 3'b000;
    localparam STATE_READY      = 3'b001;
    localparam STATE_RUNNING    = 3'b010;
    localparam STATE_PAUSED     = 3'b011;
    localparam STATE_ANALYSIS   = 3'b100;
    
    reg [2:0] processorState;
    reg [7:0] stateTimer;
    reg processorEnabled;
    reg [31:0] demoInstructionCount;
    
    // State machine for processor control
    always @(posedge displayClock) begin
        if (btn_pressed[0]) begin  // BTN0 = Reset
            processorState <= STATE_RESET;
            stateTimer <= 8'h0;
            processorEnabled <= 1'b0;
            demoInstructionCount <= 32'h0;
        end else begin
            case (processorState)
                STATE_RESET: begin
                    processorEnabled <= 1'b0;
                    if (stateTimer < 8'd10) begin
                        stateTimer <= stateTimer + 1;
                    end else begin
                        processorState <= STATE_READY;
                        stateTimer <= 8'h0;
                    end
                end
                
                STATE_READY: begin
                    processorEnabled <= 1'b0;
                    if (btn_pressed[1]) begin  // BTN1 = Start/Resume
                        processorState <= STATE_RUNNING;
                        processorEnabled <= 1'b1;
                    end
                end
                
                STATE_RUNNING: begin
                    processorEnabled <= 1'b1;
                    if (btn_pressed[1]) begin  // BTN1 = Pause
                        processorState <= STATE_PAUSED;
                        processorEnabled <= 1'b0;
                    end else if (btn_pressed[2]) begin  // BTN2 = Analysis Mode
                        processorState <= STATE_ANALYSIS;
                    end else if (demoInstructionCount >= 32'd100) begin  // Auto-pause after 100 instructions
                        processorState <= STATE_READY;
                        demoInstructionCount <= 32'h0;
                        processorEnabled <= 1'b0;
                    end
                end
                
                STATE_PAUSED: begin
                    processorEnabled <= 1'b0;
                    if (btn_pressed[1]) begin  // BTN1 = Resume
                        processorState <= STATE_RUNNING;
                        processorEnabled <= 1'b1;
                    end
                end
                
                STATE_ANALYSIS: begin
                    // Analysis mode - processor running but showing detailed stats
                    processorEnabled <= 1'b1;
                    if (btn_pressed[2]) begin  // BTN2 = Exit Analysis
                        processorState <= STATE_RUNNING;
                    end
                end
                
                default: begin
                    processorState <= STATE_RESET;
                end
            endcase
        end
    end

    // ======================================================================
    // INSTRUCTION GENERATOR
    // ======================================================================
    
    reg [31:0] currentInstruction;
    reg validInstructionReg;
    reg [7:0] instructionPattern;
    
    always @(posedge processorClock) begin
        if (processorState == STATE_RESET) begin
            currentInstruction <= 32'h00000013;  // NOP
            validInstructionReg <= 1'b0;
            instructionPattern <= 8'h0;
        end else if (processorEnabled && requestNextInstruction) begin
            validInstructionReg <= 1'b1;
            instructionPattern <= instructionPattern + 1;
            demoInstructionCount <= demoInstructionCount + 1;
            
            // Enhanced instruction patterns for comprehensive testing
            case (instructionPattern[4:0])
                // Arithmetic operations
                5'h00: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
                5'h01: currentInstruction <= 32'h002080B3; // ADD  x1, x1, x2
                5'h02: currentInstruction <= 32'h40208133; // SUB  x2, x1, x2
                5'h03: currentInstruction <= 32'h0020F1B3; // AND  x3, x1, x2
                5'h04: currentInstruction <= 32'h0020E233; // OR   x4, x1, x2
                5'h05: currentInstruction <= 32'h0020C2B3; // XOR  x5, x1, x2
                
                // Shift operations
                5'h06: currentInstruction <= 32'h00209333; // SLL  x6, x1, x2
                5'h07: currentInstruction <= 32'h0020D3B3; // SRL  x7, x1, x2
                5'h08: currentInstruction <= 32'h4020D433; // SRA  x8, x1, x2
                
                // Branch operations (for branch predictor testing)
                5'h09: currentInstruction <= 32'h00208063; // BEQ  x1, x2, +0
                5'h0A: currentInstruction <= 32'h00209063; // BNE  x1, x2, +0
                5'h0B: currentInstruction <= 32'h0020C063; // BLT  x1, x2, +0
                5'h0C: currentInstruction <= 32'h0020D063; // BGE  x1, x2, +0
                
                // Comparison operations  
                5'h0D: currentInstruction <= 32'h0020A493; // SLT  x9, x1, x2
                5'h0E: currentInstruction <= 32'h0020B513; // SLTU x10, x1, x2
                
                // Immediate operations
                5'h0F: currentInstruction <= 32'h00210593; // ADDI x11, x2, 2
                5'h10: currentInstruction <= 32'h00520613; // ADDI x12, x4, 5
                5'h11: currentInstruction <= 32'h FF810693; // ADDI x13, x2, -8
                
                // More complex patterns
                5'h12: currentInstruction <= 32'h00A30713; // ADDI x14, x6, 10
                5'h13: currentInstruction <= 32'h40E70793; // SUB  x15, x14, x14
                5'h14: currentInstruction <= 32'h00F76813; // OR   x16, x14, x15
                5'h15: currentInstruction <= 32'h01080893; // ADDI x17, x16, 16
                
                // Pattern repeats with variations
                default: currentInstruction <= 32'h00108093; // ADDI x1, x1, 1
            endcase
        end else begin
            validInstructionReg <= 1'b0;
        end
    end

    // ======================================================================
    // PROCESSOR INTERFACE SIGNALS
    // ======================================================================
    
    wire [31:0] instruction = currentInstruction;
    wire validInstruction = validInstructionReg;
    wire requestNextInstruction;
    wire instructionComplete;
    
    // External interface inputs
    wire [7:0] powerBudget = {sw_clean[3], sw_clean[2], 6'b111111};  // SW3,SW2 control power budget
    wire [7:0] thermalReading = sw_clean[1] ? 8'hE0 : 8'h60;        // SW1 simulates thermal stress
    wire [7:0] batteryLevel = sw_clean[0] ? 8'h30 : 8'hF0;          // SW0 simulates battery level
    wire performanceMode = btn_clean[3];                            // BTN3 enables performance mode
    
    // Enhanced performance monitoring outputs
    wire [31:0] totalInstructions, totalCycles;
    wire [7:0] branchAccuracy;
    wire [31:0] totalOperationsALU, totalRegAccesses;
    
    // Workload classification outputs
    wire [2:0] currentWorkloadFormat;
    wire [3:0] workloadConfidence;
    wire [7:0] computeToll, memToll, controlToll, complexPattern;
    wire workloadClassificationValid;
    
    // Power management outputs
    wire [2:0] currentPowerState;
    wire [2:0] clockFrequencyLevel, voltageLevel;
    wire [7:0] currentTotalPower;
    wire [7:0] powerEfficiency, temperatureEstimate;
    wire [15:0] energySaved;
    wire powerOptimizationActive, thermalThrottle;
    
    // Component power gating status
    wire powerGateALU, powerGateRegister, powerGateBranchPredictor, powerGateCache;
    
    // Debug signals for UART output
    wire [31:0] instructionDebug = instruction;
    wire [31:0] currentPCDebug;
    wire [2:0] pipelineStageDebug;
    wire [31:0] resultALUDebug;
    wire [4:0] rs1Debug, rs2Debug, rdDebug;
    wire [31:0] rsData1Debug, rsData2Debug;

    // ======================================================================
    // ENHANCED RISC-V PROCESSOR CORE
    // ======================================================================
    
    enhanced_core processorCore (
        .clk(processorClock),
        .reset(~(processorState == STATE_RESET)),  // Active low reset
        
        // Instruction Interface
        .instruction(instruction),
        .validInstruction(validInstruction),
        .requestNextInstruction(requestNextInstruction),
        
        // External Power/Thermal Interface
        .powerBudget(powerBudget),
        .thermalReading(thermalReading),
        .batteryLevel(batteryLevel),
        .performanceMode(performanceMode),
        
        // Processor Status Outputs
        .instructionComplete(instructionComplete),
        .branchTaken(),
        .branchTarget(),
        
        // Enhanced Performance Monitoring
        .totalInstructions(totalInstructions),
        .totalCycles(totalCycles),
        .totalBranches(),
        .correctPredictions(),
        .branchAccuracy(branchAccuracy),
        .totalOperationsALU(totalOperationsALU),
        .totalRegAccesses(totalRegAccesses),
        
        // Workload Classification Outputs
        .currentWorkloadFormat(currentWorkloadFormat),
        .workloadConfidence(workloadConfidence),
        .computeToll(computeToll),
        .memToll(memToll),
        .controlToll(controlToll),
        .complexPattern(complexPattern),
        .workloadClassificationValid(workloadClassificationValid),
        
        // Power Management Outputs
        .currentPowerState(currentPowerState),
        .clockFrequencyLevel(clockFrequencyLevel),
        .voltageLevel(voltageLevel),
        .currentTotalPower(currentTotalPower),
        .powerEfficiency(powerEfficiency),
        .temperatureEstimate(temperatureEstimate),
        .energySaved(energySaved),
        .powerOptimizationActive(powerOptimizationActive),
        .thermalThrottle(thermalThrottle),
        
        // Component Power Gating Status
        .powerGateALU(powerGateALU),
        .powerGateRegister(powerGateRegister),
        .powerGateBranchPredictor(powerGateBranchPredictor),
        .powerGateCache(powerGateCache),
        
        // Debug outputs (connected for UART debug)
        .rs1Debug(rs1Debug),
        .rs2Debug(rs2Debug),
        .rdDebug(rdDebug),
        .rsData1Debug(rsData1Debug),
        .rsData2Debug(rsData2Debug),
        .resultALUDebug(resultALUDebug),
        .currentPC(currentPCDebug),
        .pipelineStage(pipelineStageDebug),
        .adaptationRate(),
        .powerTrend()
    );

    // ======================================================================
    // UART DEBUG OUTPUT
    // ======================================================================
    
    uart_debug debugOutput (
        .clk(clk),
        .reset(processorState != STATE_RESET),
        
        // Processor signals to monitor
        .instructionComplete(instructionComplete),
        .instruction(instructionDebug),
        .currentPC(currentPCDebug),
        .pipelineStage(pipelineStageDebug),
        .resultALU(resultALUDebug),
        .rs1(rs1Debug),
        .rs2(rs2Debug), 
        .rd(rdDebug),
        .rsData1(rsData1Debug),
        .rsData2(rsData2Debug),
        
        // Performance monitoring
        .totalInstructions(totalInstructions),
        .totalCycles(totalCycles),
        .branchAccuracy(branchAccuracy),
        .workloadFormat(currentWorkloadFormat),
        .workloadConfidence(workloadConfidence),
        .currentPower(currentTotalPower),
        .powerState(currentPowerState),
        .powerOptimizationActive(powerOptimizationActive),
        .thermalThrottle(thermalThrottle),
        
        // UART output
        .uart_tx(uart_tx)
    );

    // ======================================================================
    // CORRECTED LED DISPLAY SYSTEM
    // ======================================================================
    
    // LED Display Controller
    reg [7:0] instructionActivityCount;
    reg [7:0] performanceDisplayCount;
    
    always @(posedge displayClock) begin
        // Instruction activity tracking
        if (instructionComplete) begin
            instructionActivityCount <= 8'd255;  // Bright flash on instruction completion
        end else if (instructionActivityCount > 0) begin
            instructionActivityCount <= instructionActivityCount - 1;
        end
        
        // Performance display counter
        performanceDisplayCount <= performanceDisplayCount + 1;
    end

    // Regular LEDs (LD0-LD3)
    assign led[0] = heartbeat;  // System heartbeat
    assign led[1] = (processorState == STATE_RUNNING) ? 
                    (instructionActivityCount > 0 ? 1'b1 : displayClock) :
                    (processorState == STATE_READY) ? heartbeat : 1'b0;
    assign led[2] = (processorState == STATE_ANALYSIS) ? performanceDisplayCount[6] :
                    (branchAccuracy > 8'd75) ? 1'b1 : 1'b0;
    assign led[3] = (processorState == STATE_PAUSED) ? heartbeat :
                    powerOptimizationActive;

    // RGB LED LD5 - Processor Status
    assign led5_r = (branchAccuracy > 8'd90) ? 1'b1 :           // Excellent prediction
                    (branchAccuracy > 8'd75) ? heartbeat :      // Good prediction  
                    (branchAccuracy > 8'd50) ? displayClock : 1'b0; // Learning
                    
    assign led5_g = sw_clean[2] ? 1'b1 :                        // Direct switch control
                    (workloadClassificationValid && 
                     (currentWorkloadFormat == 3'b001)) ? heartbeat : 1'b0; // Compute workload
                     
    assign led5_b = sw_clean[3] ? 1'b1 :                        // Direct switch control
                    (batteryLevel < 8'h60) ? displayClock :    // Low battery warning
                    powerOptimizationActive ? heartbeat : 1'b0; // Power optimization

    // RGB LED LD6 - Core Status  
    assign led6_r = (thermalThrottle) ? displayClock :          // Thermal throttle warning
                    (currentPowerState >= 3'b100) ? 1'b1 :     // High power state
                    (currentPowerState >= 3'b010) ? heartbeat : 1'b0; // Normal power
                    
    assign led6_g = (processorState == STATE_RUNNING) ? 1'b1 :  // Solid when running
                    (processorState == STATE_READY) ? heartbeat : // Heartbeat when ready
                    (processorState == STATE_ANALYSIS) ? displayClock : 1'b0; // Fast blink in analysis
                    
    assign led6_b = (workloadClassificationValid && 
                     (currentWorkloadFormat == 3'b011)) ? 1'b1 : // Control workload
                    (workloadClassificationValid && 
                     (currentWorkloadFormat != 3'b000)) ? heartbeat : 1'b0; // Any classified workload

    // UART TX is connected to pin Y19 for external USB-to-serial converter

endmodule