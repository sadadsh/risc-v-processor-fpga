`timescale 1ns / 1ps

// ADAPTIVE BRANCH PREDICTOR
// Engineer: Sadad Haidari
//
// This module implements an advanced branch predictor that is inspired from neural network concepts.
// To do this, it uses multiple prediction mechanisms working together, similar to ensemble learning.
//
// Innovation Features:
// -> Two-Level Adaptive Predictor (like perceptron learning).
// -> Global Register (context memorization).
// -> Pattern Table (weight storage like neural networks).
// -> Confidence-Based Prediction (quantification of prediction confidence).
// -> Adaptive Learning Rate (like modern optimization algorithms).

module branch_predictor (
    input wire clk,
    input wire reset,
    // Branch Prediction Interface
    input wire isBranch, // Is a branch instruction?
    input wire [31:0] branchPC, // Program counter of the branch instruction.
    input wire [2:0] branchT, // Type of branch instruction.
    // Training Interface
    // This is taken from execution stage feedback.
    input wire branchResolved, // Has the branch outcome been determined?
    input wire actualTaken, // Was the branch actually taken?
    input wire [31:0] resolvedPC, // PC of resolved branch for training.
    // Prediction Outputs
    output reg predictTaken, // Should we predict branch taken?
    output reg [3:0] confidence, // Confidence in the prediction (0-15 and higher = more confident).
    output wire predictionValid, // Is the prediction valid?
    // Performance Monitoring
    output reg [15:0] totalPredictions, // Total number of predictions.
    output reg [15:0] correctPredictions, // Total number of correct predictions.
    output wire [7:0] accuracyPresent // Percentage of correct predictions.
);

    // PREDICTOR PARAMETERS
    localparam PTSIZE = 256; // Pattern table size (2^8 entries)
    localparam GRSIZE = 8; // Global register width (8 bits).
    localparam CONFIDENCEBITS = 4; // Confidence counter bits.
    localparam SATURATINGBITS = 2; // Saturating counter bits.

    // GLOBAL REGISTER
    // This is used to store recent branch outcomes, similar to a recurrent neural network hidden state.
    // It captures the correlation between recent branch outcomes and the current prediction.
    reg [GRSIZE-1:0] globalRegister;

    // PATTERN TABLE
    // This is like the weights in a neural network. It stores learned patterns.
    // Contains a 2-bit saturating counter that learns branch behavior.
    reg [SATURATINGBITS-1:0] patternTable [0:PTSIZE-1];

    // CONFIDENCE TRACKING
    // Like uncertainty quantification in neural networks we track how confident we are in our prediction.
    // Higher confidence means we have seen this pattern before and it is more reliable.
    reg [CONFIDENCEBITS-1:0] confidenceTable [0:PTSIZE-1];

    // BRANCH SPECIALIZATION
    // Different branch formats have different patterns.
    // We use separate counters for each format.
    reg [SATURATINGBITS-1:0] branchTC [0:7]; // A counter for the 8 different formats.

    // ADAPTIVE LEARNING RATE
    // Like modern optimizers, we adjust the learning speed based on confidence.
    // High confidence = slower learning, low confidence = faster learning.
    wire [1:0] learningRate;

    // PREDICTION LOGIC SIGNALS
    wire [7:0] patternIndex;
    wire [1:0] patternValue;
    wire [1:0] TC;
    wire [3:0] currentConfidence;
    wire [5:0] localIndex;
    wire [3:0] localPattern;
    reg PTprediction;
    reg Tprediction;
    reg localPrediction;
    reg [2:0] resolvedT;
    reg [5:0] localIdx;
    reg [7:0] resolvedIndex;
    reg [1:0] voteCount;

    // PERFORMANCE TRACKING
    reg [31:0] CC; // Cycle counter for performance monitoring.

    // LOCAL HISTORY for specific PC addresses (like a local predictor).
    reg [3:0] localHistory [0:63]; // 64 entries for local patterns.

    // INITIALIZE PREDICTOR STATE
    // Start with weak "not taken" bias.
    integer i;
    initial begin
        globalRegister = 0;
        totalPredictions = 0;
        correctPredictions = 0;
        predictTaken = 0;
        confidence = 0;
        CC = 0;

        // Initialize with slightly taken bias for loops.
        for (i = 0; i < PTSIZE; i = i + 1) begin
            patternTable[i] = 2'b01;      // Weak not-taken.
            confidenceTable[i] = 4'b0001; // Start with minimal confidence.
        end

        // Initialize branch type counters.
        for (i = 0; i < 8; i = i + 1) begin
            branchTC[i] = 2'b01; // Weak not-taken.
        end

        // Initialize local history
        for (i = 0; i < 64; i = i + 1) begin
            localHistory[i] = 4'b0000;
        end
    end

    // ENHANCED PATTERN INDEX GENERATION
    // Combine PC, global history, and branch type for better correlation.
    assign patternIndex = (branchPC[9:2] ^ globalRegister ^ {5'b0, branchT}) % PTSIZE;

    // LOCAL PATTERN TRACKING
    assign localIndex = branchPC[7:2] % 64; // 6-bit index for local history.
    assign localPattern = localHistory[localIndex];

    // RETRIEVE CURRENT PREDICTION VALUES
    assign patternValue = patternTable[patternIndex];
    assign TC = branchTC[branchT];
    assign currentConfidence = confidenceTable[patternIndex];

    // ADAPTIVE LEARNING RATE CALCULATION
    // Use confidence to adjust learning rate.
    // Higher confidence = slower learning, lower confidence = faster learning.
    // Prevent overfitting to noise with higher confidence but adapt to new patterns fast with lower confidence.
    assign learningRate = (currentConfidence > 8) ? 2'b00 : // Super confident: no update.
                          (currentConfidence > 4) ? 2'b01 : // High confident: slow update.
                          (currentConfidence > 2) ? 2'b10 : // Average confident: medium update.
                                                    2'b11;  // Low confident: fast update.

    // PREDICTION LOGIC
    // Use pattern value and TC to predict branch taken.
    // If pattern is 01 (weak "not taken" bias) and TC is 01 (weak "not taken" bias), predict not taken.
    // If pattern is 10 (weak "taken" bias) and TC is 10 (weak "taken" bias), predict taken.
    // If pattern is 11 (strong "taken" bias) and TC is 11 (strong "taken" bias), predict taken.
    // If pattern is 00 (strong "not taken" bias) and TC is 00 (strong "not taken" bias), predict not taken.
    // If pattern is 11 (strong "taken" bias) and TC is 01 (weak "not taken" bias), predict taken.
    
    // PREDICTION GENERATION
    // Combine multiple prediction sources like an ensemble learning approach.
    // This gives us more robust predictions.
    always @(*) begin
        // Primary prediction from Pattern History Table.
        PTprediction = (patternValue >= 2'b10);

        // Branch type prediction.
        Tprediction = (TC >= 2'b10);

        // Local pattern prediction (count 1s in local history).
        localPrediction = (localPattern[3] + localPattern[2] + localPattern[1] + localPattern[0]) >= 2;

        // IMPROVED ENSEMBLE LOGIC
        if (currentConfidence >= 8) begin
            // High confidence: trust pattern table strongly.
            predictTaken = PTprediction;
            confidence = currentConfidence;
        end else if (currentConfidence >= 4) begin
            // Medium confidence: weighted voting
            case ({PTprediction, Tprediction, localPrediction})
                3'b111: begin predictTaken = 1; confidence = currentConfidence + 3; end
                3'b110, 3'b101, 3'b011: begin predictTaken = 1; confidence = currentConfidence + 2; end
                3'b100, 3'b010, 3'b001: begin predictTaken = 0; confidence = currentConfidence + 1; end
                3'b000: begin predictTaken = 0; confidence = currentConfidence + 3; end
                default: begin predictTaken = PTprediction; confidence = currentConfidence; end
            endcase
        end else begin
            // Low confidence: majority vote with bias toward taken for loops
            voteCount = PTprediction + Tprediction + localPrediction;
            
            if (voteCount >= 2) begin
                predictTaken = 1;
                confidence = 3;
            end else if (voteCount == 1) begin
                // Tie-breaker: favor taken for low PC addresses (likely loops)
                predictTaken = (branchPC < 32'h10000) ? 1 : 0;
                confidence = 2;
            end else begin
                predictTaken = 0;
                confidence = 2;
            end
        end

        // Bound confidence.
        if (confidence > 15) confidence = 15;
    end

    // PREDICTION SIGNAL
    // Prepared to make predictions when we have a valid branch instruction.
    assign predictionValid = isBranch && !reset;

    // LEARNING AND UPDATE LOGIC
    // This is where the "AI" happens, this will make sure it learns from its mistakes.
    always @(posedge clk) begin
        if (reset) begin
            globalRegister <= 0;
            totalPredictions <= 0;
            correctPredictions <= 0;
            CC <= 0;
            
            for (i = 0; i < PTSIZE; i = i + 1) begin
                patternTable[i] <= 2'b01;
                confidenceTable[i] <= 4'b0001;
            end

            for (i = 0; i < 8; i = i + 1) begin
                branchTC[i] <= 2'b01;
            end

            for (i = 0; i < 64; i = i + 1) begin
                localHistory[i] <= 4'b0000;
            end
        end else begin
            CC <= CC + 1;

            // Update global history on every branch resolution.
            if (branchResolved) begin
                globalRegister <= {globalRegister[GRSIZE-2:0], actualTaken};
                // Update local history
                localIdx = resolvedPC[7:2] % 64;
                localHistory[localIdx] <= {localHistory[localIdx][2:0], actualTaken};
                resolvedIndex = (resolvedPC[9:2] ^ globalRegister ^ {5'b0, branchT}) % PTSIZE;
            end

            // ENHANCED LEARNING FROM BRANCH RESOLUTION
            if (branchResolved) begin
                resolvedT = branchT;

                // Update performance counters.
                totalPredictions <= totalPredictions + 1;
                if ((predictTaken && actualTaken) || (!predictTaken && !actualTaken)) begin
                    correctPredictions <= correctPredictions + 1;
                end

                // UPDATE PATTERN TABLE
                if (actualTaken) begin
                    // Branch was taken: strengthen pattern.
                    if (patternTable[resolvedIndex] < 2'b11) begin
                        patternTable[resolvedIndex] <= patternTable[resolvedIndex] + 1;
                        $display("[DEBUG] patternTable[%0d] incremented to %b", resolvedIndex, patternTable[resolvedIndex] + 1);
                    end
                end else begin
                    // Branch was not taken: weaken pattern.
                    if (patternTable[resolvedIndex] > 2'b00) begin
                        patternTable[resolvedIndex] <= patternTable[resolvedIndex] - 1;
                        $display("[DEBUG] patternTable[%0d] decremented to %b", resolvedIndex, patternTable[resolvedIndex] - 1);
                    end
                end

                // UPDATE CONFIDENCE
                if ((predictTaken && actualTaken) || (!predictTaken && !actualTaken)) begin
                    // Correct prediction: increase confidence.
                    if (confidenceTable[resolvedIndex] < 15) begin
                        confidenceTable[resolvedIndex] <= confidenceTable[resolvedIndex] + 2; // Faster confidence building
                        $display("[DEBUG] confidenceTable[%0d] incremented to %d", resolvedIndex, confidenceTable[resolvedIndex] + 2);
                    end
                end else begin
                    // Incorrect prediction: decrease confidence.
                    if (confidenceTable[resolvedIndex] > 1) begin
                        confidenceTable[resolvedIndex] <= confidenceTable[resolvedIndex] - 1;
                        $display("[DEBUG] confidenceTable[%0d] decremented to %d", resolvedIndex, confidenceTable[resolvedIndex] - 1);
                    end
                end
                
                // UPDATE BRANCH FORMAT COUNTER
                if (actualTaken) begin
                    // Branch was taken: strengthen format counter.
                    if (branchTC[resolvedT] < 2'b11) begin
                        branchTC[resolvedT] <= branchTC[resolvedT] + 1;
                        $display("[DEBUG] branchTC[%0d] incremented to %b", resolvedT, branchTC[resolvedT] + 1);
                    end
                end else begin
                    // Branch was not taken: weaken format counter.
                    if (branchTC[resolvedT] > 2'b00) begin
                        branchTC[resolvedT] <= branchTC[resolvedT] - 1;
                        $display("[DEBUG] branchTC[%0d] decremented to %b", resolvedT, branchTC[resolvedT] - 1);
                    end
                end
            end
        end
    end

    // ACCURACY CALCULATION
    // Real-time performance monitoring.
    assign accuracyPresent = (totalPredictions == 0) ? 8'd50 : // Default to 50% if no predictions.
                            (correctPredictions * 100) / totalPredictions;

endmodule