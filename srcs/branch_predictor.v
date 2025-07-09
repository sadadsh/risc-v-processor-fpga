`timescale 1ns / 1ps

// ADAPTIVE BRANCH PREDICTOR
// Engineer: Sadad Haidari

module branch_predictor (
    input wire clk,
    input wire reset,
    // Branch Prediction Interface
    input wire isBranch,
    input wire [31:0] branchPC,
    input wire [2:0] branchT,
    // Training Interface
    input wire branchResolved,
    input wire actualTaken,
    input wire [31:0] resolvedPC,
    // Prediction Outputs
    output reg predictTaken,
    output reg [3:0] confidence,
    output wire predictionValid,
    // Performance Monitoring
    output reg [15:0] totalPredictions,
    output reg [15:0] correctPredictions,
    output wire [7:0] accuracyPresent
);

    // PREDICTOR PARAMETERS
    localparam PTSIZE = 256;
    localparam GRSIZE = 8;
    localparam CONFIDENCEBITS = 4;
    localparam SATURATINGBITS = 2;

    // GLOBAL REGISTER
    reg [GRSIZE-1:0] globalRegister;

    // PATTERN TABLE
    reg [SATURATINGBITS-1:0] patternTable [0:PTSIZE-1];

    // CONFIDENCE TRACKING
    reg [CONFIDENCEBITS-1:0] confidenceTable [0:PTSIZE-1];

    // BRANCH SPECIALIZATION
    reg [SATURATINGBITS-1:0] branchTC [0:7];

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
    reg [1:0] voteCount;

    // PERFORMANCE TRACKING
    reg [31:0] CC;
    reg [7:0] resolvedIndex;
    reg [2:0] resolvedBranchType;

    // LOCAL HISTORY
    reg [3:0] localHistory [0:63];

    // Store last prediction for comparison.
    reg lastPredictionTaken;
    reg lastPredictionValid;

    // INITIALIZE PREDICTOR STATE
    integer i;
    initial begin
        globalRegister = 0;
        totalPredictions = 0;
        correctPredictions = 0;
        predictTaken = 0;
        confidence = 0;
        CC = 0;
        lastPredictionTaken = 0;
        lastPredictionValid = 0;

        // Initialize with weak taken bias for loops
        for (i = 0; i < PTSIZE; i = i + 1) begin
            patternTable[i] = 2'b10;
            confidenceTable[i] = 4'b0100;
        end

        // Initialize branch type counters
        for (i = 0; i < 8; i = i + 1) begin
            branchTC[i] = 2'b10;
        end

        // Initialize local history
        for (i = 0; i < 64; i = i + 1) begin
            localHistory[i] = 4'b0000;
        end
    end

    // PATTERN INDEX GENERATION
    assign patternIndex = (branchPC[9:2] ^ globalRegister ^ {5'b0, branchT}) % PTSIZE;

    // LOCAL PATTERN TRACKING
    assign localIndex = branchPC[7:2] % 64;
    assign localPattern = localHistory[localIndex];

    // RETRIEVE CURRENT PREDICTION VALUES
    assign patternValue = patternTable[patternIndex];
    assign TC = branchTC[branchT];
    assign currentConfidence = confidenceTable[patternIndex];

    // PREDICTION GENERATION
    always @(*) begin
        // Primary prediction from Pattern History Table
        PTprediction = (patternValue >= 2'b10);

        // Branch type prediction
        Tprediction = (TC >= 2'b10);

        // Local pattern prediction
        localPrediction = (localPattern[3] + localPattern[2] + localPattern[1] + localPattern[0]) >= 2;

        // ENSEMBLE LOGIC
        if (currentConfidence >= 8) begin
            // High confidence: trust pattern table
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
            // Low confidence: majority vote
            voteCount = PTprediction + Tprediction + localPrediction;
            
            if (voteCount >= 2) begin
                predictTaken = 1;
                confidence = 4;
            end else if (voteCount == 1) begin
                // Tie-breaker: favor taken for low PC addresses (loops)
                predictTaken = (branchPC < 32'h10000) ? 1 : 0;
                confidence = 3;
            end else begin
                predictTaken = 0;
                confidence = 3;
            end
        end

        // Bound confidence
        if (confidence > 15) confidence = 15;
    end

    // PREDICTION SIGNAL
    assign predictionValid = isBranch && !reset;

    // LEARNING AND UPDATE LOGIC
    always @(posedge clk) begin
        if (!reset) begin
            globalRegister <= 0;
            totalPredictions <= 0;
            correctPredictions <= 0;
            CC <= 0;
            lastPredictionTaken <= 0;
            lastPredictionValid <= 0;
            
            for (i = 0; i < PTSIZE; i = i + 1) begin
                patternTable[i] <= 2'b10;
                confidenceTable[i] <= 4'b0100;
            end

            for (i = 0; i < 8; i = i + 1) begin
                branchTC[i] <= 2'b10;
            end

            for (i = 0; i < 64; i = i + 1) begin
                localHistory[i] <= 4'b0000;
            end
        end else begin
            CC <= CC + 1;

            // FIXED: Store prediction when branch is encountered
            if (isBranch) begin
                lastPredictionTaken <= predictTaken;
                lastPredictionValid <= 1'b1;
            end

            // FIXED: Training logic when branch is resolved
            if (branchResolved && lastPredictionValid) begin
                // Update global history
                globalRegister <= {globalRegister[GRSIZE-2:0], actualTaken};
                
                // Update local history
                localHistory[resolvedPC[7:2] % 64] <= {localHistory[resolvedPC[7:2] % 64][2:0], actualTaken};
                
                // Update performance counters
                totalPredictions <= totalPredictions + 1;
                if (lastPredictionTaken == actualTaken) begin
                    correctPredictions <= correctPredictions + 1;
                end

                // Calculate pattern index for training
                resolvedIndex = (resolvedPC[9:2] ^ globalRegister ^ {5'b0, branchT}) % PTSIZE;
                resolvedBranchType = branchT;

                // UPDATE PATTERN TABLE
                if (actualTaken) begin
                    if (patternTable[resolvedIndex] < 2'b11) begin
                        patternTable[resolvedIndex] <= patternTable[resolvedIndex] + 1;
                    end
                end else begin
                    if (patternTable[resolvedIndex] > 2'b00) begin
                        patternTable[resolvedIndex] <= patternTable[resolvedIndex] - 1;
                    end
                end

                // UPDATE CONFIDENCE
                if (lastPredictionTaken == actualTaken) begin
                    // Correct prediction: increase confidence
                    if (confidenceTable[resolvedIndex] < 15) begin
                        confidenceTable[resolvedIndex] <= confidenceTable[resolvedIndex] + 1;
                    end
                end else begin
                    // Incorrect prediction: decrease confidence
                    if (confidenceTable[resolvedIndex] > 1) begin
                        confidenceTable[resolvedIndex] <= confidenceTable[resolvedIndex] - 1;
                    end
                end
                
                // UPDATE BRANCH TYPE COUNTER
                if (actualTaken) begin
                    if (branchTC[resolvedBranchType] < 2'b11) begin
                        branchTC[resolvedBranchType] <= branchTC[resolvedBranchType] + 1;
                    end
                end else begin
                    if (branchTC[resolvedBranchType] > 2'b00) begin
                        branchTC[resolvedBranchType] <= branchTC[resolvedBranchType] - 1;
                    end
                end

                // Clear prediction valid flag
                lastPredictionValid <= 1'b0;
            end
        end
    end

    // ACCURACY CALCULATION
    assign accuracyPresent = (totalPredictions == 0) ? 8'd50 :
                            (correctPredictions * 100) / totalPredictions;

endmodule