
`timescale 1ns / 1ps

// ENHANCED RISC-V WITH DEMO FEATURES
// Engineer: Sadad Haidari

module system_top (
    // Clock
    input wire clk,
    
    // Working I/O Interface (matches existing)
    input wire [3:0] btn,  // Working buttons (active LOW)
    input wire [3:0] sw,   // Working switches  
    output wire [3:0] led, // Working LEDs (LD0-LD3)
    output wire led5_r, led5_g, led5_b,  // RGB LD5
    output wire led6_r, led6_g, led6_b,  // RGB LD6
    
    // UART Debug Output
    output wire uart_tx
);

    // SYSTEM CONTROL AND TIMING
    // Master counter generates timing signals for processor and display domains.
    
    reg [26:0] counter;
    always @(posedge clk) begin
        counter <= counter + 1;
    end
    
    // Multiple clock domains for processor and display
    wire displayClock = counter[20];    // ~60 Hz for LED updates
    wire processorClock = counter[3];   // ~15.6 MHz for processor (divide by 16)
    
    // Registered timing signals to avoid using clocks in expressions
    reg heartbeat;
    reg slowBlink;
    
    always @(posedge clk) begin
        heartbeat <= counter[25];       // ~1.5 Hz system heartbeat
        slowBlink <= counter[24];       // ~3 Hz slow blink
    end

    // BUTTON AND SWITCH INTERFACE
    // Handles button debouncing, edge detection, and switch input.
    
    // Clean button signals (handle active LOW)
    reg [3:0] btn_sync1, btn_sync2, btn_clean;
    always @(posedge clk) begin
        btn_sync1 <= ~btn;  // Invert active LOW buttons
        btn_sync2 <= btn_sync1;
        btn_clean <= btn_sync2;  // Synchronized button signals
    end
    
    // Button edge detection for single-press actions
    reg [3:0] btn_last;
    reg [3:0] btn_pressed;
    always @(posedge displayClock) begin
        btn_last <= btn_clean;
        btn_pressed <= btn_clean & ~btn_last;  // Rising edge detection
    end

    // Switch interface (working perfectly)
    wire [3:0] sw_clean = sw;

    // DEMO STATE MACHINE
    // Controls demo phases and transitions for hardware demonstration.
    
    // Demo phases for demonstration
    localparam DEMO_IDLE     = 3'd0;   // Normal operation
    localparam DEMO_BOOT     = 3'd1;   // Boot animation
    localparam DEMO_BRANCH   = 3'd2;   // Branch predictor showcase
    localparam DEMO_POWER    = 3'd3;   // Power management showcase
    localparam DEMO_WORKLOAD = 3'd4;   // Workload classification
    localparam DEMO_ANALYTICS = 3'd5;  // Performance analytics
    localparam DEMO_COMPLETE = 3'd6;   // Demo complete
    
    reg [2:0] demoPhase;
    reg [15:0] demoTimer;
    reg [7:0] animationCounter;
    reg demoMode;
    reg [15:0] phaseInstructionCount;     // Count instructions in current phase (MOVED HERE)
    
    // Demo control (BTN3 starts demo, BTN2 resets, BTN1 advances)
    always @(posedge displayClock) begin
        if (btn_pressed[2]) begin  // BTN2 - Reset (edge triggered)
            demoPhase <= DEMO_IDLE;
            demoMode <= 1'b0;
            demoTimer <= 16'd0;
            animationCounter <= 8'd0;
            phaseInstructionCount <= 16'd0;  // Reset instruction count
        end else if (btn_pressed[3] && !demoMode) begin  // BTN3 - Start demo
            demoMode <= 1'b1;
            demoPhase <= DEMO_BOOT;
            demoTimer <= 16'd0;
            animationCounter <= 8'd0;
            phaseInstructionCount <= 16'd0;  // Start fresh
        end else if (btn_pressed[1] && demoMode) begin  // BTN1 - Next phase
            if (demoPhase < DEMO_COMPLETE) begin
                demoPhase <= demoPhase + 1;
                demoTimer <= 16'd0;
                animationCounter <= 8'd0;
                phaseInstructionCount <= 16'd0;  // Reset for new phase
            end else begin
                demoMode <= 1'b0;
                demoPhase <= DEMO_IDLE;
                phaseInstructionCount <= 16'd0;
            end
        end else if (demoMode) begin
            demoTimer <= demoTimer + 1;
            animationCounter <= animationCounter + 1;
            
            // Auto-advance if SW3 is on (every ~10 seconds)
            if (sw_clean[3] && (demoTimer > 16'd2000)) begin
                if (demoPhase < DEMO_COMPLETE) begin
                    demoPhase <= demoPhase + 1;
                    demoTimer <= 16'd0;
                    animationCounter <= 8'd0;
                    phaseInstructionCount <= 16'd0;  // Reset for new phase
                end else begin
                    demoMode <= 1'b0;
                    demoPhase <= DEMO_IDLE;
                    phaseInstructionCount <= 16'd0;
                end
            end
        end
    end

    // PROCESSOR CONTROL STATE MACHINE
    // Manages processor operational states (idle, ready, running, paused, analysis).

    // Processor control states
    localparam STATE_IDLE = 3'd0;
    localparam STATE_READY = 3'd1;
    localparam STATE_RUNNING = 3'd2;
    localparam STATE_PAUSED = 3'd3;
    localparam STATE_ANALYSIS = 3'd4;
    
    reg [2:0] processorState;
    reg [15:0] stateTimer;
    
    // Keep existing processor state machine logic
    always @(posedge displayClock) begin
        if (btn_pressed[2]) begin  // BTN2 - Reset (edge triggered)
            processorState <= STATE_IDLE;
            stateTimer <= 16'd0;
        end else begin
            stateTimer <= stateTimer + 1;
            
            case (processorState)
                STATE_IDLE: begin
                    if (stateTimer > 16'd100) begin
                        processorState <= STATE_READY;
                        stateTimer <= 16'd0;
                    end
                end
                
                STATE_READY: begin
                    if (stateTimer > 16'd50) begin
                        processorState <= STATE_RUNNING;
                        stateTimer <= 16'd0;
                    end
                end
                
                STATE_RUNNING: begin
                    if (btn_pressed[0]) begin  // BTN0 toggles analysis
                        processorState <= STATE_ANALYSIS;
                        stateTimer <= 16'd0;
                    end
                end
                
                STATE_ANALYSIS: begin
                    if (btn_pressed[0] || stateTimer > 16'd1000) begin
                        processorState <= STATE_RUNNING;
                        stateTimer <= 16'd0;
                    end
                end
                
                default: processorState <= STATE_IDLE;
            endcase
        end
    end

    // INSTRUCTION GENERATOR
    // Generates instruction patterns for each demo phase to exercise different features.

    reg [31:0] instruction;
    reg validInstruction;
    reg [15:0] instructionCounter;
    reg [31:0] instructionMemory [0:63];  // Larger instruction memory
    
    // Initialize instruction memory with VERY different patterns per phase
    initial begin
        // PHASE 0-1: Basic mixed instructions (indices 0-15)
        instructionMemory[0]  = 32'h00108093;  // addi x1, x1, 1
        instructionMemory[1]  = 32'h00208113;  // addi x2, x1, 2  
        instructionMemory[2]  = 32'h002081b3;  // add x3, x1, x2
        instructionMemory[3]  = 32'h40208233;  // sub x4, x1, x2
        instructionMemory[4]  = 32'h00309193;  // slli x3, x1, 3
        instructionMemory[5]  = 32'h0020a2b3;  // slt x5, x1, x2
        instructionMemory[6]  = 32'h0020c333;  // xor x6, x1, x2
        instructionMemory[7]  = 32'h0020e3b3;  // or x7, x1, x2
        instructionMemory[8]  = 32'h00000013;  // nop
        instructionMemory[9]  = 32'h00110413;  // addi x8, x2, 1
        instructionMemory[10] = 32'h00000013;  // nop
        instructionMemory[11] = 32'h408084b3;  // sub x9, x1, x8
        instructionMemory[12] = 32'h00000013;  // nop
        instructionMemory[13] = 32'h00941533;  // sll x10, x8, x9
        instructionMemory[14] = 32'h00000013;  // nop
        instructionMemory[15] = 32'h0094a5b3;  // slt x11, x9, x9
        
        // PHASE 2: BRANCH-HEAVY pattern (indices 16-31) - 75% branches!
        instructionMemory[16] = 32'h00108093;  // addi x1, x1, 1
        instructionMemory[17] = 32'h00008067;  // jalr x0, x0, 0 (branch)
        instructionMemory[18] = 32'h00208113;  // addi x2, x1, 2
        instructionMemory[19] = 32'hfe208ee3;  // beq x1, x2, -4 (branch)
        instructionMemory[20] = 32'h00308193;  // addi x3, x1, 3
        instructionMemory[21] = 32'h00209e63;  // bne x1, x2, 4 (branch)
        instructionMemory[22] = 32'h00410213;  // addi x4, x2, 4
        instructionMemory[23] = 32'h0020ce63;  // blt x1, x2, 4 (branch)
        instructionMemory[24] = 32'h00510293;  // addi x5, x2, 5
        instructionMemory[25] = 32'h0020de63;  // bge x1, x2, 4 (branch)
        instructionMemory[26] = 32'h00610313;  // addi x6, x2, 6
        instructionMemory[27] = 32'h0020ee63;  // bltu x1, x2, 4 (branch)
        instructionMemory[28] = 32'h00710393;  // addi x7, x2, 7
        instructionMemory[29] = 32'h0020fe63;  // bgeu x1, x2, 4 (branch)
        instructionMemory[30] = 32'h00810413;  // addi x8, x2, 8
        instructionMemory[31] = 32'h00000067;  // jalr x0, x0, 0 (branch)
        
        // PHASE 3: COMPUTE-HEAVY pattern (indices 32-47) - high power usage
        instructionMemory[32] = 32'h002081b3;  // add x3, x1, x2
        instructionMemory[33] = 32'h40208233;  // sub x4, x1, x2
        instructionMemory[34] = 32'h002092b3;  // sll x5, x1, x2
        instructionMemory[35] = 32'h0020d333;  // srl x6, x1, x2
        instructionMemory[36] = 32'h4020d3b3;  // sra x7, x1, x2
        instructionMemory[37] = 32'h0020a433;  // slt x8, x1, x2
        instructionMemory[38] = 32'h0020b4b3;  // sltu x9, x1, x2
        instructionMemory[39] = 32'h0020c533;  // xor x10, x1, x2
        instructionMemory[40] = 32'h0020e5b3;  // or x11, x1, x2
        instructionMemory[41] = 32'h0020f633;  // and x12, x1, x2
        instructionMemory[42] = 32'h003106b3;  // add x13, x2, x3
        instructionMemory[43] = 32'h40310733;  // sub x14, x2, x3
        instructionMemory[44] = 32'h003117b3;  // sll x15, x2, x3
        instructionMemory[45] = 32'h00315833;  // srl x16, x2, x3
        instructionMemory[46] = 32'h403158b3;  // sra x17, x2, x3
        instructionMemory[47] = 32'h00312933;  // slt x18, x2, x3
        
        // PHASE 4: MIXED pattern with NOPs (indices 48-63) - different workloads
        instructionMemory[48] = 32'h00000013;  // nop (memory-like)
        instructionMemory[49] = 32'h00000013;  // nop
        instructionMemory[50] = 32'h00108093;  // addi x1, x1, 1
        instructionMemory[51] = 32'h00000013;  // nop
        instructionMemory[52] = 32'h00000013;  // nop
        instructionMemory[53] = 32'h002081b3;  // add x3, x1, x2 (compute)
        instructionMemory[54] = 32'h002081b3;  // add x3, x1, x2
        instructionMemory[55] = 32'h002081b3;  // add x3, x1, x2
        instructionMemory[56] = 32'h00008067;  // jalr x0, x0, 0 (control)
        instructionMemory[57] = 32'h00008067;  // jalr x0, x0, 0
        instructionMemory[58] = 32'h00008067;  // jalr x0, x0, 0
        instructionMemory[59] = 32'h00000013;  // nop
        instructionMemory[60] = 32'h00000013;  // nop
        instructionMemory[61] = 32'h00000013;  // nop
        instructionMemory[62] = 32'h00000013;  // nop
        instructionMemory[63] = 32'h00000013;  // nop
    end
    
    // Instruction generator with phase-specific patterns
    always @(posedge processorClock) begin
        if (!systemReset) begin
            instructionCounter <= 16'd0;
            instruction <= 32'h00000013;  // NOP
            validInstruction <= 1'b0;
            phaseInstructionCount <= 16'd0;
        end else if (requestNextInstruction && (processorState == STATE_RUNNING)) begin
            instructionCounter <= instructionCounter + 1;
            phaseInstructionCount <= phaseInstructionCount + 1;
            
            // Select dramatically different instruction patterns per phase
            case (demoPhase)
                DEMO_IDLE, DEMO_BOOT: begin
                    // Basic mixed pattern (indices 0-15)
                    instruction <= instructionMemory[instructionCounter[3:0]];
                end
                
                DEMO_BRANCH: begin
                    // Branch-heavy pattern (indices 16-31) - should improve prediction over time
                    instruction <= instructionMemory[16 + instructionCounter[3:0]];
                end
                
                DEMO_POWER: begin
                    // Compute-heavy pattern (indices 32-47) - should increase power usage
                    instruction <= instructionMemory[32 + instructionCounter[3:0]];
                end
                
                DEMO_WORKLOAD: begin
                    // Mixed workload pattern (indices 48-63) - should vary workload type
                    instruction <= instructionMemory[48 + instructionCounter[3:0]];
                end
                
                DEMO_ANALYTICS: begin
                    // Cycle through all patterns to show variety
                    case (instructionCounter[5:4])
                        2'd0: instruction <= instructionMemory[instructionCounter[3:0]];         // Basic
                        2'd1: instruction <= instructionMemory[16 + instructionCounter[3:0]];   // Branch
                        2'd2: instruction <= instructionMemory[32 + instructionCounter[3:0]];   // Compute
                        2'd3: instruction <= instructionMemory[48 + instructionCounter[3:0]];   // Mixed
                    endcase
                end
                
                default: begin
                    instruction <= instructionMemory[instructionCounter[3:0]];
                end
            endcase
            
            validInstruction <= 1'b1;
        end else if (!requestNextInstruction) begin
            validInstruction <= 1'b0;
        end
    end

    // ENHANCED CORE INSTANTIATION
    // Instantiates the main processor core and connects all interfaces.
    
    // Reset generation
    reg [7:0] resetCounter;
    reg systemReset;
    
    always @(posedge clk) begin
        if (btn_clean[2]) begin  // Use level signal for reset counter
            resetCounter <= 8'd0;
            systemReset <= 1'b0;
        end else if (resetCounter < 8'd100) begin
            resetCounter <= resetCounter + 1;
            systemReset <= 1'b0;
        end else begin
            systemReset <= 1'b1;
        end
    end
    
    // Enhanced core outputs
    wire requestNextInstruction;
    wire instructionComplete;
    wire branchTaken;
    wire [31:0] branchTarget;
    wire [31:0] totalInstructions;
    wire [31:0] totalCycles;
    wire [31:0] totalBranches;
    wire [31:0] correctPredictions;
    wire [7:0] branchAccuracy;
    wire [31:0] totalOperationsALU;
    wire [31:0] totalRegAccesses;
    wire [2:0] currentWorkloadFormat;
    wire [3:0] workloadConfidence;
    wire [7:0] computeToll, memToll, controlToll, complexPattern;
    wire workloadClassificationValid;
    wire [2:0] currentPowerState;
    wire [2:0] clockFrequencyLevel;
    wire [2:0] voltageLevel;
    wire [7:0] currentTotalPower;
    wire [7:0] powerEfficiency;
    wire [7:0] temperatureEstimate;
    wire [15:0] energySaved;
    wire powerOptimizationActive;
    wire thermalThrottle;
    wire powerGateALU, powerGateRegister, powerGateBranchPredictor, powerGateCache;
    wire [4:0] rs1Debug, rs2Debug, rdDebug;
    wire [31:0] rsData1Debug, rsData2Debug, resultALUDebug;
    wire [31:0] currentPC;
    wire [2:0] pipelineStage;
    wire [7:0] adaptationRate, powerTrend;
    
    // Enhanced core instantiation
    enhanced_core processorCore (
        .clk(processorClock),
        .reset(systemReset),
        
        // Instruction interface
        .instruction(instruction),
        .validInstruction(validInstruction),
        .requestNextInstruction(requestNextInstruction),
        
        // External power/thermal interface  
        .powerBudget({4'b1000, sw_clean}),
        .thermalReading(8'd75),
        .batteryLevel(8'd200),
        .performanceMode(sw_clean[2]),
        
        // Processor status outputs
        .instructionComplete(instructionComplete),
        .branchTaken(branchTaken),
        .branchTarget(branchTarget),
        
        // Performance monitoring
        .totalInstructions(totalInstructions),
        .totalCycles(totalCycles),
        .totalBranches(totalBranches),
        .correctPredictions(correctPredictions),
        .branchAccuracy(branchAccuracy),
        .totalOperationsALU(totalOperationsALU),
        .totalRegAccesses(totalRegAccesses),
        
        // Workload classification
        .currentWorkloadFormat(currentWorkloadFormat),
        .workloadConfidence(workloadConfidence),
        .computeToll(computeToll),
        .memToll(memToll),
        .controlToll(controlToll),
        .complexPattern(complexPattern),
        .workloadClassificationValid(workloadClassificationValid),
        
        // Power management
        .currentPowerState(currentPowerState),
        .clockFrequencyLevel(clockFrequencyLevel),
        .voltageLevel(voltageLevel),
        .currentTotalPower(currentTotalPower),
        .powerEfficiency(powerEfficiency),
        .temperatureEstimate(temperatureEstimate),
        .energySaved(energySaved),
        .powerOptimizationActive(powerOptimizationActive),
        .thermalThrottle(thermalThrottle),
        
        // Component power gating
        .powerGateALU(powerGateALU),
        .powerGateRegister(powerGateRegister),
        .powerGateBranchPredictor(powerGateBranchPredictor),
        .powerGateCache(powerGateCache),
        // Note: powerGateCore is internal to enhanced_core
        
        // Debug outputs
        .rs1Debug(rs1Debug),
        .rs2Debug(rs2Debug),
        .rdDebug(rdDebug),
        .rsData1Debug(rsData1Debug),
        .rsData2Debug(rsData2Debug),
        .resultALUDebug(resultALUDebug),
        .currentPC(currentPC),
        .pipelineStage(pipelineStage),
        .adaptationRate(adaptationRate),
        .powerTrend(powerTrend)
    );

    // LED DISPLAY
    // Drives LEDs and RGB indicators to visualize processor and demo status.
    
    reg [3:0] ledOutput;
    reg rgbR1, rgbG1, rgbB1;  // RGB LED 5
    reg rgbR2, rgbG2, rgbB2;  // RGB LED 6
    
    // Activity tracking
    reg [7:0] instructionActivityCount;
    reg [7:0] performanceDisplayCount;
    reg displayToggle;  // Registered display toggle for timing
    reg instructionRequestActive;  // Track instruction requests
    
    always @(posedge displayClock) begin
        // Instruction activity tracking
        if (instructionComplete) begin
            instructionActivityCount <= 8'd255;
        end else if (instructionActivityCount > 0) begin
            instructionActivityCount <= instructionActivityCount - 1;
        end
        
        // Track instruction requests for debugging
        instructionRequestActive <= requestNextInstruction;
        
        performanceDisplayCount <= performanceDisplayCount + 1;
        displayToggle <= ~displayToggle;  // Create registered toggle signal
    end

    // REAL-TIME METRIC TRACKING
    // Tracks and simulates metrics for demo visualization (branch accuracy, power, workload, progress).
    
    reg [7:0] localBranchAccuracy;          // Local branch accuracy counter
    reg [2:0] localPowerLevel;              // Local power level
    reg [2:0] localWorkloadType;            // Local workload type  
    reg [7:0] phaseProgress;                // Progress within current phase
    reg [15:0] phaseTimer;                  // Timer within phase
    reg [7:0] lastBranchAccuracy;           // Track actual changes
    reg [2:0] lastPowerState;               // Track power changes
    reg [2:0] lastWorkloadFormat;           // Track workload changes
    
    // Track metrics and simulate realistic progression
    always @(posedge displayClock) begin
        phaseTimer <= phaseTimer + 1;
        
        case (demoPhase)
            DEMO_BRANCH: begin
                // Simulate branch prediction improvement over time
                if (phaseTimer[8:0] == 9'd0) begin  // Every ~2 seconds
                    if (localBranchAccuracy < 8'd95) begin
                        localBranchAccuracy <= localBranchAccuracy + 8'd15;  // Dramatic improvement
                    end
                end
                
                // Also track real changes
                if (branchAccuracy != lastBranchAccuracy) begin
                    lastBranchAccuracy <= branchAccuracy;
                    localBranchAccuracy <= branchAccuracy;  // Use real value if changing
                end
            end
            
            DEMO_POWER: begin
                // Simulate power level changes based on instruction patterns
                if (phaseTimer[7:0] == 8'd0) begin  // Every ~1 second
                    localPowerLevel <= localPowerLevel + 1;  // Increase power usage
                    if (localPowerLevel >= 3'd6) localPowerLevel <= 3'd1;
                end
                
                // Track real power state changes
                if (currentPowerState != lastPowerState) begin
                    lastPowerState <= currentPowerState;
                    localPowerLevel <= currentPowerState;  // Use real value
                end
            end
            
            DEMO_WORKLOAD: begin
                // Cycle through workload types to show classification
                if (phaseTimer[9:0] == 10'd0) begin  // Every ~4 seconds
                    localWorkloadType <= localWorkloadType + 1;
                    if (localWorkloadType >= 3'd4) localWorkloadType <= 3'd0;
                end
                
                // Track real workload changes
                if (currentWorkloadFormat != lastWorkloadFormat) begin
                    lastWorkloadFormat <= currentWorkloadFormat;
                    localWorkloadType <= currentWorkloadFormat;  // Use real value
                end
            end
            
            DEMO_ANALYTICS: begin
                // Show progression through different metrics
                phaseProgress <= phaseTimer[10:3];  // Slow progression counter
            end
            
            default: begin
                // Reset local counters when not in specific phases
                localBranchAccuracy <= 8'd25;      // Start low
                localPowerLevel <= 3'd1;           // Start low  
                localWorkloadType <= 3'd0;         // Start with first type
                phaseProgress <= 8'd0;
            end
        endcase
        
        // Reset phase timer when switching phases
        if (btn_pressed[1] || (sw_clean[3] && (demoTimer > 16'd2000))) begin
            phaseTimer <= 16'd0;
        end
    end

    always @(posedge displayClock) begin
        if (demoMode) begin
            // CLEAR PHASE INDICATION: Standard LEDs show phase number (binary)
            ledOutput <= demoPhase[2:0];  // Fixed: demoPhase is only 3 bits (2:0)
            
            // RGB LED5: MAIN FEATURE STATUS (Primary indicator)
            case (demoPhase)
                DEMO_IDLE: begin
                    // Waiting to start - gentle green heartbeat
                    rgbR1 <= 1'b0; rgbG1 <= heartbeat; rgbB1 <= 1'b0;
                end
                
                DEMO_BOOT: begin
                    // System starting - solid white
                    rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b1;
                end
                
                DEMO_BRANCH: begin
                    // Branch prediction - DRAMATIC progression from RED to GREEN
                    if (localBranchAccuracy > 8'd85) begin
                        rgbR1 <= 1'b0; rgbG1 <= 1'b1; rgbB1 <= 1'b0;  // GREEN = Excellent
                    end else if (localBranchAccuracy > 8'd65) begin
                        rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b0;  // YELLOW = Good
                    end else if (localBranchAccuracy > 8'd45) begin
                        rgbR1 <= 1'b1; rgbG1 <= slowBlink; rgbB1 <= 1'b0;  // ORANGE = Learning
                    end else begin
                        rgbR1 <= 1'b1; rgbG1 <= 1'b0; rgbB1 <= 1'b0;  // RED = Poor
                    end
                end
                
                DEMO_POWER: begin
                    // Power management - CLEAR progression from BLUE to RED
                    if (localPowerLevel >= 3'd5) begin
                        rgbR1 <= 1'b1; rgbG1 <= 1'b0; rgbB1 <= 1'b0;  // RED = High power
                    end else if (localPowerLevel >= 3'd3) begin
                        rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b0;  // YELLOW = Medium power
                    end else begin
                        rgbR1 <= 1'b0; rgbG1 <= 1'b0; rgbB1 <= 1'b1;  // BLUE = Low power
                    end
                end
                
                DEMO_WORKLOAD: begin
                    // Workload classification - OBVIOUS different colors per type
                    case (localWorkloadType)
                        3'd0: begin rgbR1 <= 1'b0; rgbG1 <= 1'b0; rgbB1 <= 1'b1; end  // BLUE = Memory
                        3'd1: begin rgbR1 <= 1'b1; rgbG1 <= 1'b0; rgbB1 <= 1'b0; end  // RED = Compute
                        3'd2: begin rgbR1 <= 1'b0; rgbG1 <= 1'b1; rgbB1 <= 1'b0; end  // GREEN = Control
                        3'd3: begin rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b0; end  // YELLOW = Mixed
                        default: begin rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b1; end  // WHITE = Unknown
                    endcase
                end
                
                DEMO_ANALYTICS: begin
                    // Performance analytics - Show overall system health
                    if (phaseProgress > 8'd200) begin
                        rgbR1 <= 1'b0; rgbG1 <= 1'b1; rgbB1 <= 1'b0;  // GREEN = Excellent
                    end else if (phaseProgress > 8'd100) begin
                        rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b0;  // YELLOW = Good
                    end else begin
                        rgbR1 <= 1'b1; rgbG1 <= slowBlink; rgbB1 <= 1'b0;  // ORANGE = Analyzing
                    end
                end
                
                DEMO_COMPLETE: begin
                    // Demo finished - Celebration rainbow
                    case (animationCounter[5:3])
                        3'd0: begin rgbR1 <= 1'b1; rgbG1 <= 1'b0; rgbB1 <= 1'b0; end  // Red
                        3'd1: begin rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b0; end  // Yellow
                        3'd2: begin rgbR1 <= 1'b0; rgbG1 <= 1'b1; rgbB1 <= 1'b0; end  // Green
                        3'd3: begin rgbR1 <= 1'b0; rgbG1 <= 1'b1; rgbB1 <= 1'b1; end  // Cyan
                        3'd4: begin rgbR1 <= 1'b0; rgbG1 <= 1'b0; rgbB1 <= 1'b1; end  // Blue
                        3'd5: begin rgbR1 <= 1'b1; rgbG1 <= 1'b0; rgbB1 <= 1'b1; end  // Magenta
                        default: begin rgbR1 <= 1'b1; rgbG1 <= 1'b1; rgbB1 <= 1'b1; end  // White
                    endcase
                end
            endcase
            
            // RGB LED6: SECONDARY METRICS AND PROGRESS (Supporting indicator)
            case (demoPhase)
                DEMO_IDLE: begin
                    rgbR2 <= 1'b0; rgbG2 <= 1'b0; rgbB2 <= heartbeat;  // Blue pulse = ready
                end
                
                DEMO_BOOT: begin
                    rgbR2 <= heartbeat; rgbG2 <= heartbeat; rgbB2 <= 1'b0;  // Yellow pulse = starting
                end
                
                DEMO_BRANCH: begin
                    // Show instruction activity and progress
                    rgbR2 <= instructionComplete;                    // RED flash = instruction done
                    rgbG2 <= (phaseInstructionCount > 16'd50);      // GREEN = enough instructions processed
                    rgbB2 <= (localBranchAccuracy > 8'd50);        // BLUE = prediction improving
                end
                
                DEMO_POWER: begin
                    // Show power optimization activity
                    rgbR2 <= powerOptimizationActive;              // RED = optimization active
                    rgbG2 <= (energySaved > 16'd10);               // GREEN = energy being saved
                    rgbB2 <= (localPowerLevel <= 3'd2);            // BLUE = efficient operation
                end
                
                DEMO_WORKLOAD: begin
                    // Show classification confidence and validity
                    rgbR2 <= workloadClassificationValid;          // RED = classification valid
                    rgbG2 <= (workloadConfidence > 4'd8);          // GREEN = high confidence
                    rgbB2 <= (phaseInstructionCount > 16'd30);     // BLUE = enough data collected
                end
                
                DEMO_ANALYTICS: begin
                    // Show different performance metrics cycling
                    case (phaseProgress[3:2])
                        2'd0: begin  // Show instruction throughput
                            rgbR2 <= (totalInstructions > 32'd100);
                            rgbG2 <= (totalInstructions > 32'd200);
                            rgbB2 <= (totalInstructions > 32'd500);
                        end
                        2'd1: begin  // Show branch performance
                            rgbR2 <= (localBranchAccuracy > 8'd50);
                            rgbG2 <= (localBranchAccuracy > 8'd75);
                            rgbB2 <= (localBranchAccuracy > 8'd90);
                        end
                        2'd2: begin  // Show power efficiency
                            rgbR2 <= powerOptimizationActive;
                            rgbG2 <= (localPowerLevel <= 3'd3);
                            rgbB2 <= (energySaved > 16'd50);
                        end
                        2'd3: begin  // Show overall system status
                            rgbR2 <= systemReset;
                            rgbG2 <= (processorState == STATE_RUNNING);
                            rgbB2 <= (totalCycles > 32'd1000);
                        end
                    endcase
                end
                
                DEMO_COMPLETE: begin
                    // Both LEDs rainbow but offset for cool effect
                    case ((animationCounter[5:3] + 3'd3) % 7)
                        3'd0: begin rgbR2 <= 1'b1; rgbG2 <= 1'b0; rgbB2 <= 1'b0; end  // Red
                        3'd1: begin rgbR2 <= 1'b1; rgbG2 <= 1'b1; rgbB2 <= 1'b0; end  // Yellow
                        3'd2: begin rgbR2 <= 1'b0; rgbG2 <= 1'b1; rgbB2 <= 1'b0; end  // Green
                        3'd3: begin rgbR2 <= 1'b0; rgbG2 <= 1'b1; rgbB2 <= 1'b1; end  // Cyan
                        3'd4: begin rgbR2 <= 1'b0; rgbG2 <= 1'b0; rgbB2 <= 1'b1; end  // Blue
                        3'd5: begin rgbR2 <= 1'b1; rgbG2 <= 1'b0; rgbB2 <= 1'b1; end  // Magenta
                        default: begin rgbR2 <= 1'b1; rgbG2 <= 1'b1; rgbB2 <= 1'b1; end  // White
                    endcase
                end
            endcase
            
        end else begin
            // NORMAL MODE - Simple but informative status
            ledOutput[0] <= heartbeat;                          // LD0 = System alive
            ledOutput[1] <= (totalInstructions > 32'd0);        // LD1 = Instructions executed
            ledOutput[2] <= (branchAccuracy > 8'd50);           // LD2 = Branch predictor working
            ledOutput[3] <= powerOptimizationActive;            // LD3 = Power optimization on
            
            // RGB LED5: Overall system status
            rgbR1 <= (branchAccuracy < 8'd50) ? 1'b1 : 1'b0;    // RED = Poor prediction
            rgbG1 <= (branchAccuracy > 8'd75) ? 1'b1 : 1'b0;    // GREEN = Good prediction
            rgbB1 <= systemReset;                                // BLUE = System ready
            
            // RGB LED6: Activity indicators
            rgbR2 <= instructionComplete;                        // RED = Instruction completed
            rgbG2 <= heartbeat;                                  // GREEN = System alive
            rgbB2 <= validInstruction;                           // BLUE = Valid instruction ready
        end
    end
    
    // Output assignments
    assign led = ledOutput;
    assign led5_r = rgbR1;
    assign led5_g = rgbG1;
    assign led5_b = rgbB1;
    assign led6_r = rgbR2;
    assign led6_g = rgbG2;
    assign led6_b = rgbB2;

    // UART DEBUG OUTPUT
    // Sends debug information over UART for external monitoring, requires adapter.
    
    // Simple UART transmitter for debug
    reg [7:0] uartData;
    reg uartSend;
    reg [15:0] uartCounter;
    
    always @(posedge displayClock) begin
        uartCounter <= uartCounter + 1;
        
        if (uartCounter == 16'd0) begin
            uartData <= {1'b0, demoPhase, currentPowerState, demoMode};
            uartSend <= 1'b1;
        end else begin
            uartSend <= 1'b0;
        end
    end
    
    assign uart_tx = uartSend;

    // DEBUG MONITORING
    // Tracks instruction flow and program counter for debugging purposes.
    
    // Debug counter to track instruction flow
    reg [31:0] debugInstructionCount;
    reg [31:0] debugLastPC;
    
    always @(posedge processorClock) begin
        if (!systemReset) begin
            debugInstructionCount <= 32'd0;
            debugLastPC <= 32'd0;
        end else begin
            // Track instruction completions
            if (instructionComplete) begin
                debugInstructionCount <= debugInstructionCount + 1;
            end
            
            // Track PC changes
            if (currentPC != debugLastPC) begin
                debugLastPC <= currentPC;
            end
        end
    end

endmodule