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

    // IMPROVED PARAMETERS FOR STABILITY
    localparam WINDOWSIZE = 32;              // Larger window for more stability.
    localparam CONFIDENCETHRESHOLD = 3;     // Lower threshold for easier validation.
    localparam MINACTIVITYFORCLASSIFICATION = 2; // Reduced minimum activity requirement.

    // INSTRUCTION PATTERN TRACKING
    reg [6:0] instructionWindow [0:WINDOWSIZE-1];
    reg [5:0] windowIndex; // Increased size for larger window.
    reg [31:0] windowInstructionCount;

    // FEATURE EXTRACTION COUNTERS
    reg [7:0] computeOperationCount;
    reg [7:0] memOperationCount;
    reg [7:0] branchOperationCount;
    reg [7:0] sequentialCount;
    reg [7:0] irregularCount;
    reg [7:0] activeInstructionCount;
    reg [7:0] idleCount;

    // STABILITY TRACKING
    reg [7:0] stableClassificationCount;
    reg [2:0] lastClassification;
    reg [7:0] confidenceAccumulator;

    // TEMPORAL ANALYSIS
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
        workloadConfidence = 4'h4; // Start with threshold confidence
        computeToll = 8'h0;
        memToll = 8'h0;
        controlToll = 8'h0;
        complexPattern = 8'h0;
        classificationCount = 16'h0;
        adaptationRate = 8'h10;

        windowIndex = 6'h0;
        windowInstructionCount = 32'h0;
        computeOperationCount = 8'h0;
        memOperationCount = 8'h0;
        branchOperationCount = 8'h0;
        sequentialCount = 8'h0;
        irregularCount = 8'h0;
        activeInstructionCount = 8'h0;
        idleCount = 8'h0;
        classificationTimer = 6'h0;

        stableClassificationCount = 8'h0;
        lastClassification = WLUNKNOWN;
        confidenceAccumulator = 8'h0;

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
        // Calculate intensity metrics with improved stability.
        if (activeInstructionCount >= MINACTIVITYFORCLASSIFICATION) begin
            computeToll = (computeOperationCount * 255) / activeInstructionCount;
            memToll = (memOperationCount * 255) / activeInstructionCount;
            controlToll = (branchOperationCount * 255) / activeInstructionCount;
            
            // Clamp values
            if (computeToll > 255) computeToll = 255;
            if (memToll > 255) memToll = 255;
            if (controlToll > 255) controlToll = 255;
        end else begin
            // Use accumulated values for early classification.
            computeToll = computeOperationCount * 64; // Scale up for visibility.
            memToll = memOperationCount * 64;
            controlToll = branchOperationCount * 64;
            
            // Clamp scaled values.
            if (computeToll > 255) computeToll = 255;
            if (memToll > 255) memToll = 255;
            if (controlToll > 255) controlToll = 255;
        end

        // Improved complexity calculation.
        if (activeInstructionCount >= MINACTIVITYFORCLASSIFICATION) begin
            complexPattern = (irregularCount * 200) / activeInstructionCount;
            if (complexPattern > 255) complexPattern = 255;
        end else begin
            complexPattern = irregularCount * 50; // Scale for early detection.
            if (complexPattern > 255) complexPattern = 255;
        end

        // Enhanced adaptive learning rate.
        if (stableCounter > 12) begin
            adaptationRate = 8'h04; // Very stable.
        end else if (stableCounter > 8) begin
            adaptationRate = 8'h08; // Stable.
        end else if (stableCounter > 4) begin
            adaptationRate = 8'h10; // Learning.
        end else begin
            adaptationRate = 8'h20; // Fast learning.
        end
    end

    // MAIN CLASSIFICATION LOGIC
    always @(posedge clk) begin
        if (!reset) begin
            // Reset all state
            workloadFormat <= WLUNKNOWN;
            workloadConfidence <= 4'h4; // Start with valid confidence.
            classificationCount <= 16'h0;
            windowIndex <= 6'h0;
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
            stableClassificationCount <= 8'h0;
            lastClassification <= WLUNKNOWN;
            confidenceAccumulator <= 8'h0;

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
                        // Unknown instruction type - count as irregular.
                        irregularCount <= (irregularCount < 255) ? irregularCount + 1 : 255;
                    end
                endcase
                
                // Instruction window management
                instructionWindow[windowIndex] <= opcode;
                windowIndex <= (windowIndex + 1) % WINDOWSIZE;
                windowInstructionCount <= windowInstructionCount + 1;
                
                // Pattern analysis.
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

            // IMPROVED CLASSIFICATION LOGIC (every 4 cycles for faster response).
            if (classificationTimer[1:0] == 2'h0) begin
                // More lenient classification requirements.
                if (activeInstructionCount >= MINACTIVITYFORCLASSIFICATION) begin
                    // Determine workload type with improved thresholds.
                    if (computeToll > 100 && computeToll > memToll && computeToll > controlToll) begin
                        workloadFormat <= WLCOMPUTE;
                        workloadConfidence <= 8;
                    end else if (memToll > 100 && memToll > computeToll && memToll > controlToll) begin
                        workloadFormat <= WLMEMORY;
                        workloadConfidence <= 8;
                    end else if (controlToll > 100 && controlToll > computeToll && controlToll > memToll) begin
                        workloadFormat <= WLCONTROL;
                        workloadConfidence <= 8;
                    end else if (computeToll > 40 && memToll > 40) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 7;
                    end else if (computeToll > 40 && controlToll > 40) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 6;
                    end else if (memToll > 40 && controlToll > 40) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 6;
                    end else if (sequentialCount > (irregularCount * 2)) begin
                        workloadFormat <= WLSTREAMING;
                        workloadConfidence <= 6;
                    end else if (irregularCount > (sequentialCount * 2) && complexPattern > 100) begin
                        workloadFormat <= WLIRREGULAR;
                        workloadConfidence <= 5;
                    end else if (activeInstructionCount < 4 || idleCount > 8) begin
                        workloadFormat <= WLIDLE;
                        workloadConfidence <= 6;
                    end else begin
                        // Better default classification
                        if (computeToll >= memToll && computeToll >= controlToll) begin
                            workloadFormat <= WLCOMPUTE;
                            workloadConfidence <= 5;
                        end else if (memToll >= controlToll) begin
                            workloadFormat <= WLMEMORY;
                            workloadConfidence <= 5;
                        end else begin
                            workloadFormat <= WLCONTROL;
                            workloadConfidence <= 5;
                        end
                    end
                end else if (activeInstructionCount == 0 || idleCount > 5) begin
                    workloadFormat <= WLIDLE;
                    workloadConfidence <= 5; // Increased confidence for idle.
                end else begin
                    // Early stage classification with basic confidence.
                    if (computeOperationCount > 0) begin
                        workloadFormat <= WLCOMPUTE;
                        workloadConfidence <= 4;
                    end else if (branchOperationCount > 0) begin
                        workloadFormat <= WLCONTROL;
                        workloadConfidence <= 4;
                    end else if (memOperationCount > 0) begin
                        workloadFormat <= WLMEMORY;
                        workloadConfidence <= 4;
                    end else begin
                        workloadFormat <= WLIDLE;
                        workloadConfidence <= 4;
                    end
                end
                
                classificationCount <= classificationCount + 1;
                
                // Enhanced stability tracking.
                if (workloadFormat == previousWLF) begin
                    stableCounter <= (stableCounter < 255) ? stableCounter + 1 : 255;
                    // Gradually increase confidence for stable classifications.
                    if (workloadConfidence < 15 && stableCounter > 3) begin
                        workloadConfidence <= workloadConfidence + 1;
                    end
                end else begin
                    stableCounter <= 0;
                    // Don't immediately drop confidence on format change.
                    if (workloadConfidence > 4) begin
                        workloadConfidence <= workloadConfidence - 1;
                    end
                end
                previousWLF <= workloadFormat;
                
                // LESS AGGRESSIVE COUNTER RESET (every 32 cycles instead of 16).
                if (classificationTimer[4:0] == 5'h0 && classificationCount > 4) begin
                    // Gradual reset instead of complete reset.
                    computeOperationCount <= computeOperationCount >> 1;
                    memOperationCount <= memOperationCount >> 1;
                    branchOperationCount <= branchOperationCount >> 1;
                    sequentialCount <= sequentialCount >> 1;
                    irregularCount <= irregularCount >> 1;
                    activeInstructionCount <= activeInstructionCount >> 1;
                    idleCount <= idleCount >> 1;
                    shortTerm <= shortTerm >> 1;
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
                                 ((workloadFormat != WLUNKNOWN) || (activeInstructionCount == 0));
    // Allow UNKNOWN to be valid when no activity (idle state).

endmodule