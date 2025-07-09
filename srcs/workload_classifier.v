`timescale 1ns / 1ps

// WORKLOAD CLASSIFIER
// Engineer: Sadad Haidari

module workload_classifier (
    input wire clk,
    input wire reset,
    // Instruction Interface
    input wire instructionValid,
    input wire [6:0] opcode,
    input wire [2:0] fun3,
    input wire isBranch,
    input wire branchTaken,
    input wire [31:0] resultALU,
    input wire activeALU,
    input wire [3:0] opALU,
    input wire regWrite,
    input wire [4:0] regAddress,
    input wire [31:0] regData,
    // Performance Metrics Inputs
    input wire [31:0] totalInstructions,
    input wire [31:0] totalOperationsALU,
    input wire [31:0] totalRegAccesses,
    input wire [7:0] currentPower,
    // Workload Classification Outputs
    output reg [2:0] workloadFormat,
    output reg [3:0] workloadConfidence,
    output reg [7:0] computeToll,
    output reg [7:0] memToll,
    output reg [7:0] controlToll,
    output reg [7:0] complexPattern,
    // Adaptive Learning Outputs
    output reg [15:0] classificationCount,
    output reg [7:0] adaptationRate,
    output wire classificationValid
);

    // WORKLOAD FORMAT DEFINITIONS
    localparam WLUNKNOWN   = 3'b000;
    localparam WLCOMPUTE   = 3'b001;
    localparam WLMEMORY    = 3'b010;
    localparam WLCONTROL   = 3'b011;
    localparam WLMIXED     = 3'b100;
    localparam WLIDLE      = 3'b101;
    localparam WLSTREAMING = 3'b110;
    localparam WLIRREGULAR = 3'b111;

    // SIMPLIFIED FEATURE EXTRACTION PARAMETERS
    localparam WINDOWSIZE = 16;          // Smaller window for faster response
    localparam CONFIDENCETHRESHOLD = 4;  // Lower threshold for easier validation

    // INSTRUCTION PATTERN TRACKING
    reg [6:0] instructionWindow [0:WINDOWSIZE-1];
    reg [4:0] windowIndex;
    reg [31:0] windowInstructionCount;

    // SIMPLIFIED FEATURE EXTRACTION COUNTERS
    reg [7:0] computeOperationCount;
    reg [7:0] memOperationCount;
    reg [7:0] branchOperationCount;
    reg [7:0] sequentialCount;
    reg [7:0] irregularCount;
    reg [7:0] activeInstructionCount;
    reg [7:0] idleCount;

    // SIMPLIFIED TEMPORAL ANALYSIS
    reg [15:0] shortTerm;
    reg [31:0] longTerm;
    reg [7:0] activityTrend;

    // ADAPTIVE LEARNING PARAMETERS
    reg [7:0] learningRate;
    reg [7:0] stableCounter;
    reg [2:0] previousWLF;

    // CLASSIFICATION TIMING
    reg [5:0] classificationTimer;

    integer i;

    // INITIALIZATION
    initial begin
        workloadFormat = WLUNKNOWN;
        workloadConfidence = 4'h0;
        computeToll = 8'h0;
        memToll = 8'h0;
        controlToll = 8'h0;
        complexPattern = 8'h0;
        classificationCount = 16'h0;
        adaptationRate = 8'h10;

        windowIndex = 5'h0;
        windowInstructionCount = 32'h0;
        computeOperationCount = 8'h0;
        memOperationCount = 8'h0;
        branchOperationCount = 8'h0;
        sequentialCount = 8'h0;
        irregularCount = 8'h0;
        activeInstructionCount = 8'h0;
        idleCount = 8'h0;
        classificationTimer = 6'h0;

        shortTerm = 16'h0;
        longTerm = 32'h0;
        activityTrend = 8'h80;

        learningRate = 8'h20;
        stableCounter = 8'h0;
        previousWLF = WLUNKNOWN;

        // Initialize arrays
        for (i = 0; i < WINDOWSIZE; i = i + 1) begin
            instructionWindow[i] = 7'h0;
        end
    end

    // SIMPLIFIED FEATURE EXTRACTION LOGIC
    always @(*) begin
        // Calculate intensity metrics
        if (activeInstructionCount >= 2) begin
            computeToll = (computeOperationCount * 255) / activeInstructionCount;
            memToll = (memOperationCount * 255) / activeInstructionCount;
            controlToll = (branchOperationCount * 255) / activeInstructionCount;
            
            // Clamp values
            if (computeToll > 255) computeToll = 255;
            if (memToll > 255) memToll = 255;
            if (controlToll > 255) controlToll = 255;
        end else begin
            computeToll = 8'h0;
            memToll = 8'h0;
            controlToll = 8'h0;
        end

        // Simplified complexity calculation
        if (activeInstructionCount >= 2) begin
            complexPattern = (irregularCount * 200) / activeInstructionCount;
            if (complexPattern > 255) complexPattern = 255;
        end else begin
            complexPattern = 8'h0;
        end

        // Adaptive learning rate
        if (stableCounter > 8) begin
            adaptationRate = 8'h08;
        end else if (stableCounter > 4) begin
            adaptationRate = 8'h10;
        end else begin
            adaptationRate = 8'h20;
        end
    end

    // MAIN CLASSIFICATION LOGIC
    always @(posedge clk) begin
        if (!reset) begin
            // Reset all state
            workloadFormat <= WLUNKNOWN;
            workloadConfidence <= 4'h0;
            classificationCount <= 16'h0;
            windowIndex <= 5'h0;
            windowInstructionCount <= 32'h0;
            computeOperationCount <= 8'h0;
            memOperationCount <= 8'h0;
            branchOperationCount <= 8'h0;
            sequentialCount <= 8'h0;
            irregularCount <= 8'h0;
            activeInstructionCount <= 8'h0;
            idleCount <= 8'h0;
            classificationTimer <= 6'h0;
            shortTerm <= 16'h0;
            longTerm <= 32'h0;
            stableCounter <= 8'h0;
            previousWLF <= WLUNKNOWN;

            // Reset arrays
            for (i = 0; i < WINDOWSIZE; i = i + 1) begin
                instructionWindow[i] <= 7'h0;
            end
        end else begin
            // Increment classification timer
            classificationTimer <= classificationTimer + 1;
            
            // Track activity versus idle
            if (instructionValid) begin
                activeInstructionCount <= (activeInstructionCount < 255) ? activeInstructionCount + 1 : 255;
                idleCount <= 8'h0;
                
                // Track instruction types based on opcode
                case (opcode)
                    7'b0110011, 7'b0010011: begin // R-type and I-type arithmetic
                        computeOperationCount <= (computeOperationCount < 255) ? computeOperationCount + 1 : 255;
                    end
                    7'b0000011, 7'b0100011: begin // Load and Store
                        memOperationCount <= (memOperationCount < 255) ? memOperationCount + 1 : 255;
                    end
                    7'b1100011, 7'b1101111, 7'b1100111: begin // Branch and Jump
                        branchOperationCount <= (branchOperationCount < 255) ? branchOperationCount + 1 : 255;
                    end
                    default: begin
                        // Unknown instruction type
                    end
                endcase
                
                // Instruction window management
                instructionWindow[windowIndex] <= opcode;
                windowIndex <= (windowIndex + 1) % WINDOWSIZE;
                windowInstructionCount <= windowInstructionCount + 1;
                
                // Simple pattern analysis
                if (windowIndex > 0) begin
                    if (opcode == instructionWindow[windowIndex - 1]) begin
                        sequentialCount <= (sequentialCount < 255) ? sequentialCount + 1 : 255;
                    end else begin
                        irregularCount <= (irregularCount < 255) ? irregularCount + 1 : 255;
                    end
                end
                
                shortTerm <= shortTerm + 1;
                longTerm <= longTerm + 1;
            end else begin
                idleCount <= (idleCount < 255) ? idleCount + 1 : 255;
            end

            // SIMPLIFIED CLASSIFICATION LOGIC (every 8 cycles)
            if (classificationTimer[2:0] == 3'h0) begin
                // Ensure we have enough data to classify
                if (activeInstructionCount >= 3) begin
                    // Determine workload type based on dominant instruction type
                    if (computeToll > 120 && computeToll > memToll && computeToll > controlToll) begin
                        workloadFormat <= WLCOMPUTE;
                        workloadConfidence <= 8;
                    end else if (memToll > 120 && memToll > computeToll && memToll > controlToll) begin
                        workloadFormat <= WLMEMORY;
                        workloadConfidence <= 8;
                    end else if (controlToll > 120 && controlToll > computeToll && controlToll > memToll) begin
                        workloadFormat <= WLCONTROL;
                        workloadConfidence <= 8;
                    end else if (computeToll > 50 && memToll > 50) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 7;
                    end else if (computeToll > 50 && controlToll > 50) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 7;
                    end else if (memToll > 50 && controlToll > 50) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 7;
                    end else if (activeInstructionCount < 5 || idleCount > 10) begin
                        workloadFormat <= WLIDLE;
                        workloadConfidence <= 6;
                    end else if (sequentialCount > (irregularCount * 2)) begin
                        workloadFormat <= WLSTREAMING;
                        workloadConfidence <= 6;
                    end else if (irregularCount > (sequentialCount * 2) && complexPattern > 150) begin
                        workloadFormat <= WLIRREGULAR;
                        workloadConfidence <= 6;
                    end else begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 5;
                    end
                end else if (activeInstructionCount == 0) begin
                    workloadFormat <= WLIDLE;
                    workloadConfidence <= 4;
                end else begin
                    workloadFormat <= WLUNKNOWN;
                    workloadConfidence <= 4;
                end
                
                classificationCount <= classificationCount + 1;
                
                // Stability tracking
                if (workloadFormat == previousWLF) begin
                    stableCounter <= (stableCounter < 255) ? stableCounter + 1 : 255;
                    // Increase confidence for stable classifications
                    if (workloadConfidence < 15) begin
                        workloadConfidence <= workloadConfidence + 1;
                    end
                end else begin
                    stableCounter <= 0;
                end
                previousWLF <= workloadFormat;
                
                // Reset counters every 16 cycles for continuous adaptation
                if (classificationTimer[3:0] == 4'h0) begin
                    computeOperationCount <= 8'h0;
                    memOperationCount <= 8'h0;
                    branchOperationCount <= 8'h0;
                    sequentialCount <= 8'h0;
                    irregularCount <= 8'h0;
                    activeInstructionCount <= 8'h0;
                    idleCount <= 8'h0;
                    shortTerm <= 16'h0;
                end
            end

            // Trend analysis (every 64 cycles)
            if (classificationTimer[5:0] == 6'h0 && longTerm > 0) begin
                if (shortTerm > (longTerm[15:8] + 5)) begin
                    activityTrend <= (activityTrend < 240) ? activityTrend + 15 : 255;
                end else if (shortTerm < (longTerm[15:8] - 5)) begin
                    activityTrend <= (activityTrend > 15) ? activityTrend - 15 : 0;
                end else begin
                    activityTrend <= 8'h80;
                end
            end
        end
    end

    // OUTPUT VALIDATION - SIMPLIFIED
    assign classificationValid = (workloadConfidence >= CONFIDENCETHRESHOLD) &&
                                 (classificationCount > 0) &&
                                 (workloadFormat != WLUNKNOWN);

endmodule