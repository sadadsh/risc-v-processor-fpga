`timescale 1ns / 1ps

// WORKLOAD CLASSIFIER
// Engineer: Sadad Haidari
//
// This module implements AI-inspired workload monitoring that classifies processor patterns.
// It uses machine learning techniques like feature extraction, pattern recognition, and
// classification to categorize workloads for optimal power management.
//
// Innovation Features:
// -> Multi-Dimensional Feature Extraction: Instruction mix, data patterns, timing, etc.
// -> Adaptive Pattern Recognition: Learns from execution past.
// -> Real-Time Workload Classification: Detects patterns in real-time (compute-intensive, control-intensive, etc.).
// -> Confidence-Based Decision Making: Uncertainty quantification.
// -> Temporal Pattern Analysis: Short-term and long term behavior.

module workload_classifier (
    input wire clk,
    input wire reset,
    // Instruction Interface
    input wire instructionValid, // New instruction is available.
    input wire [6:0] opcode, // Current instruction operation code.
    input wire [2:0] fun3,
    input wire isBranch, // Is current instruction a branch?
    input wire branchTaken, // Was branch taken?
    input wire [31:0] resultALU, // Result of ALU operation.
    input wire activeALU, // Is ALU active?
    input wire [3:0] opALU, // Which ALU operation is being performed?
    input wire regWrite, // Register write occurring?
    input wire [4:0] regAddress, // Register address being written to.
    input wire [31:0] regData, // Data being written to register.
    // Performance Metrics Inputs
    input wire [31:0] totalInstructions,
    input wire [31:0] totalOperationsALU,
    input wire [31:0] totalRegAccesses,
    input wire [7:0] currentPower,
    // Workload Classification Outputs
    output reg [2:0] workloadFormat, // Classified workload format (0-7).
    output reg [3:0] workloadConfidence, // Confidence in classification (0-15).
    output reg [7:0] computeToll, // How compute-intensive is the workload? (0-255).
    output reg [7:0] memToll, // How memory-intensive is the workload? (0-255).
    output reg [7:0] controlToll, // How control-intensive is the workload? (0-255).
    output reg [7:0] complexPattern, // How complex are the patterns? (0-255).
    // Adaptive Learning Outputs
    output reg [15:0] classificationCount, // Total classifications performed.
    output reg [7:0] adaptationRate, // How fast the classifier is learning.
    output wire classificationValid // Is current classification reliable?
);

    // WORKLOAD FORMAT DEFINITIONS
    localparam WLUNKNOWN   = 3'b000; // Unknown/initializing workload.
    localparam WLCOMPUTE   = 3'b001; // Compute-intensive workload (ALU operations).
    localparam WLMEMORY    = 3'b010; // Memory-intensive workload (load/store operations).
    localparam WLCONTROL   = 3'b011; // Control-intensive workload (branches, jumps).
    localparam WLMIXED     = 3'b100; // Mixed workload (compute, memory, control).
    localparam WLIDLE      = 3'b101; // Idle or low-usage workload.
    localparam WLSTREAMING = 3'b110; // Sequential access patterns.
    localparam WLIRREGULAR = 3'b111; // Irregular or unpredictable patterns.

    // FEATURE EXTRACTION PARAMETERS
    localparam WINDOWSIZE = 32; // Reduced for faster response
    localparam PATTERNDEPTH = 16; // Depth number of patterns to track.
    localparam CONFIDENCETHRESHOLD = 3; // Lowered for faster response and better idle detection

    // INSTRUCTION PATTERN TRACKING
    reg [6:0] instructionWindow [0:WINDOWSIZE-1]; // Recent instruction operation codes.
    reg [5:0] windowIndex; // Current position in window.
    reg [31:0] windowInstructionCount; // Instructions in current window.

    // FEATURE EXTRACTION COUNTERS
    reg [7:0] computeOperationCount; // Count of ALU operations in current window.
    reg [7:0] memOperationCount; // Count of memory operations in current window.
    reg [7:0] branchOperationCount; // Count of branch operations in current window.
    reg [7:0] sequentialCount; // Count of sequential access patterns instructions in current window.
    reg [7:0] irregularCount; // Count of irregular or unpredictable instructions in current window.
    reg [7:0] patternToll; // Pattern complexity toll (for unpredictable behavior).

    // ACTIVITY TRACKING
    reg [7:0] activeInstructionCount; // Count of actually executed instructions.
    reg [7:0] idleCount; // Count of idle cycles.

    // PATTERN RECOGNITION REGISTERS
    reg [7:0] patternStorage [0:PATTERNDEPTH-1]; // Storage for tracked patterns.
    reg [3:0] patternIndex; // Current position in pattern storage.
    reg [7:0] currentPattern; // Current pattern being tracked.

    // TEMPORAL ANALYSIS
    reg [15:0] shortTerm; // Recent activity level.
    reg [31:0] longTerm; // Long-term activity accumulator.
    reg [7:0] activityTrend; // Activity trend for temporal analysis.

    // ADAPTIVE LEARNING PARAMETERS
    reg [7:0] learningRate; // How fast to adapt to new patterns.
    reg [7:0] stableCounter; // How stable is the current classification?
    reg [7:0] previousWLF; // Previous workload format for trend.

    // STATISTICAL ACCUMULATORS
    reg [31:0] totalComputeOperations; // Total ALU operations.
    reg [31:0] totalMemOperations; // Total memory operations.
    reg [31:0] totalBranchOperations; // Total branch operations.
    reg [31:0] totalPatternChanges; // Number of pattern transitions.

    // DATA PATTERN
    reg [31:0] dataPatternBuffer [0:7]; // Buffer for storing data patterns.
    reg [2:0] dataBufferIndex; // Current index in data pattern buffer.
    reg [7:0] dataLocalityScore; // Current data locality score.
    reg [7:0] dataStridePattern; // Access stride pattern signature.

    // POWER-PERFORMANCE CORRELATION RELATIONSHIPS
    reg [7:0] powerScore; // Current power consumption efficiency score.
    reg [15:0] performanceCounter; // Performance metric accumulator.

    // CLASSIFICATION TIMING
    reg [5:0] classificationTimer; // Timer for classification updates

    integer i;

    // IRREGULAR PATTERN DETECTION
    reg [3:0] recentChanges; // For precise irregular pattern detection
    reg [2:0] uniqueOpcodes; // For unique opcode counting
    reg [31:0] dataDiff; // For data locality difference
    reg [31:0] stride1, stride2, strideDiff; // For stride pattern detection

    // INITIALIZATION
    initial begin
        workloadFormat = WLUNKNOWN;
        workloadConfidence = 4'h0;
        computeToll = 8'h0;
        memToll = 8'h0;
        controlToll = 8'h0;
        complexPattern = 8'h0;
        classificationCount = 16'h0;
        adaptationRate = 8'h10; // Start with moderate adaptation rate.

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

        patternIndex = 4'h0;
        currentPattern = 8'h0;
        shortTerm = 16'h0;
        longTerm = 32'h0;
        activityTrend = 8'h80; // Start with neutral activity trend.

        learningRate = 8'h20;
        stableCounter = 8'h0;
        previousWLF = WLUNKNOWN;

        totalComputeOperations = 32'h0;
        totalMemOperations = 32'h0;
        totalBranchOperations = 32'h0;
        totalPatternChanges = 32'h0;

        dataBufferIndex = 3'h0;
        dataLocalityScore = 8'h0;
        dataStridePattern = 8'h0;
        powerScore = 8'h80; // Start with neutral power efficiency.
        performanceCounter = 16'h0;

        // Initialize arrays.
        for (i = 0; i < WINDOWSIZE; i = i + 1) begin
            instructionWindow[i] = 7'h0;
        end
        for (i = 0; i < PATTERNDEPTH; i = i + 1) begin
            patternStorage[i] = 8'h0;
        end
        for (i = 0; i < 8; i = i + 1) begin
            dataPatternBuffer[i] = 32'h0;
        end
    end

    // FEATURE EXTRACTION LOGIC
    // This runs continuously and extracts meaningful features from processor activity.
    always @(*) begin
        if (activeInstructionCount >= 3) begin
            computeToll = (computeOperationCount * 200) / activeInstructionCount;
            memToll = (memOperationCount * 200) / activeInstructionCount;
            controlToll = (branchOperationCount * 200) / activeInstructionCount;
            if (computeToll > 255) computeToll = 255;
            if (memToll > 255) memToll = 255;
            if (controlToll > 255) controlToll = 255;
        end else if (activeInstructionCount > 0) begin
            computeToll = computeOperationCount * 120;  // More aggressive scaling for low activity
            memToll = memOperationCount * 120;
            controlToll = branchOperationCount * 120;
            if (computeToll > 255) computeToll = 255;
            if (memToll > 255) memToll = 255;
            if (controlToll > 255) controlToll = 255;
        end else begin
            computeToll = 8'h0;
            memToll = 8'h0;
            controlToll = 8'h0;
        end
        // Enhanced complexity calculation for irregular detection - much less aggressive
        if (activeInstructionCount >= 2) begin
            complexPattern = ((irregularCount * 120) / activeInstructionCount) + (totalPatternChanges[5:0]);
            if (complexPattern > 255) complexPattern = 255;
        end else begin
            complexPattern = irregularCount * 30; // Much reduced for less aggressive irregular detection
            if (complexPattern > 255) complexPattern = 255;
        end
        // Adaptive learning rate
        if (stableCounter > 15) begin
            adaptationRate = 8'h08;
        end else if (stableCounter > 6) begin
            adaptationRate = 8'h10;
        end else begin
            adaptationRate = 8'h20;
        end
    end

    // MAIN CLASSIFICATION LOGIC
    // This runs continuously and classifies the current workload.
    always @(posedge clk) begin
        if (!reset) begin
            // Reset All State
            workloadFormat <= WLUNKNOWN;
            workloadConfidence <= 4'h0;
            classificationCount <= 16'h0;
            windowIndex <= 6'h0;
            windowInstructionCount <= 32'h0;
            computeOperationCount <= 8'h0;
            memOperationCount <= 8'h0;
            branchOperationCount <= 8'h0;
            sequentialCount <= 8'h0;
            irregularCount <= 8'h0;
            patternIndex <= 4'h0;
            shortTerm <= 16'h0;
            longTerm <= 32'h0;
            stableCounter <= 8'h0;
            previousWLF <= WLUNKNOWN;
            totalComputeOperations <= 32'h0;
            totalMemOperations <= 32'h0;
            totalBranchOperations <= 32'h0;
            totalPatternChanges <= 32'h0;
            dataBufferIndex <= 3'h0;
            dataLocalityScore <= 8'h0;
            dataStridePattern <= 8'h0;
            powerScore <= 8'h80;
            performanceCounter <= 16'h0;
            classificationTimer <= 6'h0;

            // Reset Arrays
            for (i = 0; i < WINDOWSIZE; i = i + 1) begin
                instructionWindow[i] <= 7'h0;
            end
            for (i = 0; i < PATTERNDEPTH; i = i + 1) begin
                patternStorage[i] <= 8'h0;
            end
            for (i = 0; i < 8; i = i + 1) begin
                dataPatternBuffer[i] <= 32'h0;
            end
        end else begin
            // Increment Classification Timer
            classificationTimer <= classificationTimer + 1;
            // Track Activities versus Idle
            if (instructionValid) begin
                activeInstructionCount <= (activeInstructionCount < 255) ? activeInstructionCount + 1 : 255;
                idleCount <= 8'h0;
            end else begin
                idleCount <= (idleCount < 255) ? idleCount + 1 : 255;
            end
            // Instruction Window Management
            if (instructionValid) begin
                instructionWindow[windowIndex] <= opcode;
                windowIndex <= (windowIndex + 1) % WINDOWSIZE;
                windowInstructionCount <= windowInstructionCount + 1;
                case (opcode)
                    7'b0110011: begin
                        computeOperationCount <= (computeOperationCount < 255) ? computeOperationCount + 1 : 255;
                        totalComputeOperations <= totalComputeOperations + 1;
                    end
                    7'b0010011: begin
                        computeOperationCount <= (computeOperationCount < 255) ? computeOperationCount + 1 : 255;
                        totalComputeOperations <= totalComputeOperations + 1;
                    end
                    7'b0000011: begin
                        memOperationCount <= (memOperationCount < 255) ? memOperationCount + 1 : 255;
                        totalMemOperations <= totalMemOperations + 1;
                    end
                    7'b0100011: begin
                        memOperationCount <= (memOperationCount < 255) ? memOperationCount + 1 : 255;
                        totalMemOperations <= totalMemOperations + 1;
                    end
                    7'b1100011: begin
                        branchOperationCount <= (branchOperationCount < 255) ? branchOperationCount + 1 : 255;
                        totalBranchOperations <= totalBranchOperations + 1;
                    end
                    7'b1101111: begin
                        branchOperationCount <= (branchOperationCount < 255) ? branchOperationCount + 1 : 255;
                        totalBranchOperations <= totalBranchOperations + 1;
                    end
                    7'b1100111: begin
                        branchOperationCount <= (branchOperationCount < 255) ? branchOperationCount + 1 : 255;
                        totalBranchOperations <= totalBranchOperations + 1;
                    end
                endcase
                if (windowIndex > 0) begin
                    if (opcode == instructionWindow[windowIndex - 1]) begin
                        sequentialCount <= (sequentialCount < 255) ? sequentialCount + 1 : 255;
                    end else begin
                        irregularCount <= (irregularCount < 255) ? irregularCount + 1 : 255;
                    end
                end
                shortTerm <= shortTerm + 1;
                longTerm <= longTerm + 1;
                performanceCounter <= performanceCounter + 1;
            end
            // Optimized Data Locality Scoring
            if (regWrite) begin
                dataPatternBuffer[dataBufferIndex] <= regData;
                dataBufferIndex <= (dataBufferIndex + 1) % 8;
                // Enhanced locality detection specifically for streaming versus irregular
                if (dataBufferIndex > 0) begin
                    dataDiff = (regData > dataPatternBuffer[dataBufferIndex - 1]) ? 
                               (regData - dataPatternBuffer[dataBufferIndex - 1]) :
                               (dataPatternBuffer[dataBufferIndex - 1] - regData);

                    // Very close data = high locality (streaming pattern).
                    if (dataDiff <= 32'h80) begin
                        dataLocalityScore <= (dataLocalityScore < 235) ? dataLocalityScore + 20 : 255;
                        sequentialCount <= (sequentialCount < 248) ? sequentialCount + 4 : 255;
                    end else if (dataDiff <= 32'h800) begin
                        dataLocalityScore <= (dataLocalityScore < 245) ? dataLocalityScore + 10 : 255;
                        sequentialCount <= (sequentialCount < 252) ? sequentialCount + 2 : 255;
                    end else if (dataDiff <= 32'h8000) begin
                        dataLocalityScore <= (dataLocalityScore < 250) ? dataLocalityScore + 5 : 255;
                        sequentialCount <= (sequentialCount < 254) ? sequentialCount + 1 : 255;
                    end else begin
                        // Large difference = low locality (irregular pattern).
                        dataLocalityScore <= (dataLocalityScore > 20) ? dataLocalityScore - 20 : 0;
                        irregularCount <= (irregularCount < 253) ? irregularCount + 1 : 255;
                    end
                    // Enhanced stride pattern detection for streaming.
                    if (dataBufferIndex >= 2) begin
                        stride1 = (regData > dataPatternBuffer[dataBufferIndex - 1]) ? 
                                 (regData - dataPatternBuffer[dataBufferIndex - 1]) :
                                 (dataPatternBuffer[dataBufferIndex - 1] - regData);
                        stride2 = (dataPatternBuffer[dataBufferIndex - 1] > dataPatternBuffer[dataBufferIndex - 2]) ?
                                 (dataPatternBuffer[dataBufferIndex - 1] - dataPatternBuffer[dataBufferIndex - 2]) :
                                 (dataPatternBuffer[dataBufferIndex - 2] - dataPatternBuffer[dataBufferIndex - 1]);
                        strideDiff = (stride1 > stride2) ? (stride1 - stride2) : (stride2 - stride1);
                        // Consistent stride = streaming.
                        if (strideDiff <= 32'h20 && stride1 <= 32'h200) begin
                            sequentialCount <= (sequentialCount < 240) ? sequentialCount + 8 : 255;
                            dataLocalityScore <= (dataLocalityScore < 215) ? dataLocalityScore + 40 : 255;
                        end else if (strideDiff <= 32'h200) begin
                            sequentialCount <= (sequentialCount < 250) ? sequentialCount + 3 : 255;
                            dataLocalityScore <= (dataLocalityScore < 245) ? dataLocalityScore + 10 : 255;
                        end
                    end
                end
            end
            // Conservative Irregular Pattern Detection
            // Precise irregular pattern detection, only for truly chaotic patterns.
            if (instructionValid && windowIndex > 4) begin
                recentChanges = 0;
                uniqueOpcodes = 0;
                // Count instruction changes in last 5 positions
                if (windowIndex >= 5) begin
                    if (instructionWindow[windowIndex - 1] != instructionWindow[windowIndex - 2]) 
                        recentChanges = recentChanges + 1;
                    if (instructionWindow[windowIndex - 2] != instructionWindow[windowIndex - 3]) 
                        recentChanges = recentChanges + 1;
                    if (instructionWindow[windowIndex - 3] != instructionWindow[windowIndex - 4]) 
                        recentChanges = recentChanges + 1;
                    if (instructionWindow[windowIndex - 4] != instructionWindow[windowIndex - 5]) 
                        recentChanges = recentChanges + 1;
                    // Count unique opcodes in recent history.
                    if (instructionWindow[windowIndex - 1] != instructionWindow[windowIndex - 2] &&
                        instructionWindow[windowIndex - 1] != instructionWindow[windowIndex - 3])
                        uniqueOpcodes = uniqueOpcodes + 1;
                    if (instructionWindow[windowIndex - 2] != instructionWindow[windowIndex - 3] &&
                        instructionWindow[windowIndex - 2] != instructionWindow[windowIndex - 4])
                        uniqueOpcodes = uniqueOpcodes + 1;
                    if (instructionWindow[windowIndex - 3] != instructionWindow[windowIndex - 4] &&
                        instructionWindow[windowIndex - 3] != instructionWindow[windowIndex - 5])
                        uniqueOpcodes = uniqueOpcodes + 1;
                end
                // Only consider irregular if there are MANY changes AND unique opcodes.
                if (recentChanges >= 3 && uniqueOpcodes >= 2) begin
                    irregularCount <= (irregularCount < 250) ? irregularCount + 3 : 255;
                    // Degrade locality for irregular patterns.
                    if (dataLocalityScore > 10) begin
                        dataLocalityScore <= dataLocalityScore - 10;
                    end
                end else if (recentChanges <= 1) begin
                    sequentialCount <= (sequentialCount < 252) ? sequentialCount + 2 : 255;
                end
            end
            // Classification Logic Section
            if (classificationTimer[2:0] == 3'h0) begin
                // Improved idle detection with much lower thresholds
                if (activeInstructionCount < 2 || classificationCount < 1) begin
                    workloadFormat <= WLUNKNOWN;
                    workloadConfidence <= 4;
                end else if (activeInstructionCount < 4 || idleCount > 15) begin
                    workloadFormat <= WLIDLE;
                    workloadConfidence <= 8;
                end else begin
                    // Debug output to understand classification decisions.
                    $display("[CLASSIFY] Active Instructions = %0d, Compute = %0d, Memory = %0d, Control = %0d, Sequential = %0d, Irregular = %0d, Locality = %0d, Complex = %0d, Previous = %0d", 
                            activeInstructionCount, computeToll, memToll, controlToll, sequentialCount, irregularCount, dataLocalityScore, complexPattern, workloadFormat);
                    // 1. IRREGULAR: Much less aggressive, prioritize mixed over irregular
                    if ((irregularCount > (sequentialCount + 5) && complexPattern > 150 && dataLocalityScore < 40) ||
                        (workloadFormat == WLIRREGULAR && irregularCount > (sequentialCount + 4))) begin
                        workloadFormat <= WLIRREGULAR;
                        workloadConfidence <= 8;
                        $display("[CLASSIFY] -> IRREGULAR (Hysteresis = %0d, Irregular = %0d, Sequential = %0d, Complex = %0d, Locality = %0d)", workloadFormat == WLIRREGULAR, irregularCount, sequentialCount, complexPattern, dataLocalityScore);
                    end
                    // 2. STREAMING: High locality, high sequential, memory activity.
                    else if (dataLocalityScore > 200 && sequentialCount > (irregularCount + 8) && (memToll > 100 || (memToll > 80 && computeToll > 60))) begin
                        workloadFormat <= WLSTREAMING;
                        workloadConfidence <= 7;
                        $display("[CLASSIFY] -> STREAMING (Locality = %0d, Sequential = %0d > Irregular = %0d+8, Memory = %0d)", dataLocalityScore, sequentialCount, irregularCount, memToll);
                    end
                    // 3. COMPUTE: Only if not irregular.
                    else if (computeToll > 150 && computeToll > memToll + 80 && computeToll > controlToll + 80) begin
                        workloadFormat <= WLCOMPUTE;
                        workloadConfidence <= 7;
                        $display("[CLASSIFY] -> COMPUTE (Compute = %0d dominates)", computeToll);
                    end
                    // 4. MEMORY: Only if not irregular/streaming.
                    else if (memToll > 150 && memToll > computeToll + 80 && memToll > controlToll + 80 && (dataLocalityScore < 200 || sequentialCount <= (irregularCount + 8))) begin
                        workloadFormat <= WLMEMORY;
                        workloadConfidence <= 7;
                        $display("[CLASSIFY] -> MEMORY (Memory = %0d dominates, not streaming)", memToll);
                    end
                    // 5. CONTROL
                    else if (controlToll > 150 && controlToll > computeToll + 80 && controlToll > memToll + 80) begin
                        workloadFormat <= WLCONTROL;
                        workloadConfidence <= 7;
                        $display("[CLASSIFY] -> CONTROL (Control = %0d dominates)", controlToll);
                    end
                    // 6. MIXED: Much more permissive thresholds, prioritize over irregular
                    else if ((computeToll > 30 && memToll > 30 && (computeToll - memToll < 80) && (memToll - computeToll < 80)) ||
                             (computeToll > 30 && controlToll > 25 && (computeToll - controlToll < 90)) ||
                             (memToll > 30 && controlToll > 25 && (memToll - controlToll < 90)) ||
                             (computeToll > 25 && memToll > 25 && controlToll > 25 && 
                              (computeToll - memToll < 100) && (memToll - controlToll < 100) && (computeToll - controlToll < 100)) ||
                             (computeToll > 50 && memToll > 50 && controlToll > 30)) begin
                        workloadFormat <= WLMIXED;
                        workloadConfidence <= 7;
                        $display("[CLASSIFY] -> MIXED (Compute = %0d, Memory = %0d, Control = %0d)", computeToll, memToll, controlToll);
                    end
                    // Fallback
                    else begin
                        if (workloadFormat != WLUNKNOWN && workloadConfidence >= 4) begin
                            workloadConfidence <= (workloadConfidence > 4) ? workloadConfidence - 1 : 4;
                            $display("[CLASSIFY] -> MAINTAIN %0d (Confidence = %0d)", workloadFormat, workloadConfidence);
                        end else begin
                            workloadFormat <= WLUNKNOWN;
                            workloadConfidence <= 4;
                            $display("[CLASSIFY] -> UNKNOWN (Insufficient pattern)");
                        end
                    end
                end
                
                classificationCount <= classificationCount + 1;
                
                // Improve confidence for stable classifications - reduced hysteresis
                if (workloadFormat == previousWLF && stableCounter > 1) begin
                    if (workloadConfidence < 14) workloadConfidence <= workloadConfidence + 1;
                    else workloadConfidence <= 15;
                end
                
                // Enhanced stability tracking
                if (workloadFormat == previousWLF) begin
                    stableCounter <= (stableCounter < 255) ? stableCounter + 1 : 255;
                end else begin
                    stableCounter <= 0;
                    totalPatternChanges <= totalPatternChanges + 1;
                end
                previousWLF <= workloadFormat;
                
                // Pattern storage and analysis.
                currentPattern <= {computeToll[7:6], memToll[7:6],
                                   controlToll[7:6], complexPattern[7:6]};
                patternStorage[patternIndex] <= currentPattern;
                patternIndex <= (patternIndex + 1) % PATTERNDEPTH;
                
                // Reset counters every 16 cycles for faster adaptation
                if (classificationTimer[3:0] == 4'h0) begin
                    computeOperationCount <= 8'h0;
                    memOperationCount <= 8'h0;
                    branchOperationCount <= 8'h0;
                    sequentialCount <= 8'h0;
                    irregularCount <= 8'h0;
                    activeInstructionCount <= 8'h0;
                    shortTerm <= 16'h0;
                end
            end
            // POWER EFFICIENCY TRACKING
            if (currentPower > 0 && performanceCounter > 0) begin
                powerScore <= (performanceCounter[7:0] * 100) / currentPower;
            end
            // TREND ANALYSIS FOR EACH 64 CYCLES
            if (classificationTimer[5:0] == 6'h0 && longTerm > 0) begin
                if (shortTerm > (longTerm[15:8] + 10)) begin
                    activityTrend <= (activityTrend < 240) ? activityTrend + 8 : 255;
                end else if (shortTerm < (longTerm[15:8] - 10)) begin
                    activityTrend <= (activityTrend > 8) ? activityTrend - 8 : 0;
                end else begin
                    activityTrend <= 8'h80;
                end
            end
        end
    end

    // OUTPUT VALIDATION
    // Classification is valid when we have sufficient confidence and data.
    assign classificationValid = (workloadConfidence >= CONFIDENCETHRESHOLD) &&
                                 (activeInstructionCount >= 2) &&
                                 (classificationCount > 0);

endmodule