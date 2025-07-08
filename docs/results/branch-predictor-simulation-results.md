```
# run 1000ns
================================================
     ENHANCED BRANCH PREDICTOR TESTBENCH       
================================================
Initializing predictor...
Predictor ready.
Initial accuracy: 50%

Test 1: Basic Prediction
[DEBUG] patternTable[0] decremented to 00000000000000000000000000000000
[DEBUG] confidenceTable[0] incremented to          3
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000000
Test 1:                                                        Cold start BEQ | expect not-taken prediction.
  Program Counter: 0x00001000
  Branch Format: 0 (    BEQ)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 100% (1/1)

[DEBUG] patternTable[0] incremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[0] decremented to          2
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000010
Test 2:                                                                    Cold start BNE | learning begins.
  Program Counter: 0x00001004
  Branch Format: 1 (    BNE)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual:     TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 50% (1/2)

[DEBUG] patternTable[7] incremented to 00000000000000000000000000000010
[DEBUG] branchTC[4] incremented to 00000000000000000000000000000010
Test 3:                                                                    Cold start BLT | learning begins.
  Program Counter: 0x00001008
  Branch Format: 4 (    BLT)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual:     TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 33% (1/3)

Test 2: Realistic Loop Patterns
===                                                                            Small loop (5 iterations) ===
Loop iteration 1/5
[DEBUG] patternTable[2] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[2] incremented to          3
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000011
Test 4:                                                                                      Loop iteration.
  Program Counter: 0x00002000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 50% (2/4)

Loop iteration 2/5
[DEBUG] patternTable[6] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[6] incremented to          3
Test 5:                                                                                      Loop iteration.
  Program Counter: 0x00002000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 60% (3/5)

Loop iteration 3/5
[DEBUG] patternTable[14] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[14] incremented to          3
Test 6:                                                                                      Loop iteration.
  Program Counter: 0x00002000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 66% (4/6)

Loop iteration 4/5
[DEBUG] patternTable[30] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[30] incremented to          3
Test 7:                                                                                      Loop iteration.
  Program Counter: 0x00002000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 71% (5/7)

Loop iteration 5/5
[DEBUG] patternTable[62] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[62] incremented to          3
Test 8:                                                                                      Loop iteration.
  Program Counter: 0x00002000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 75% (6/8)

[DEBUG] patternTable[126] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[1] decremented to 00000000000000000000000000000010
Test 9:                                                                               Loop exit | not-taken.
  Program Counter: 0x00002000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 66% (6/9)

===                                                                          Medium loop (10 iterations) ===
Loop iteration 1/10
[DEBUG] patternTable[254] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[254] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000001
Test 10:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 70% (7/10)

Loop iteration 2/10
[DEBUG] patternTable[253] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[253] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000010
Test 11:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 72% (8/11)

Loop iteration 3/10
[DEBUG] patternTable[251] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[251] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000011
Test 12:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 75% (9/12)

Loop iteration 4/10
[DEBUG] patternTable[247] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[247] incremented to          3
Test 13:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 76% (10/13)

Loop iteration 5/10
[DEBUG] patternTable[239] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[239] incremented to          3
Test 14:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (11/14)

Loop iteration 6/10
[DEBUG] patternTable[223] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[223] incremented to          3
Test 15:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (12/15)

Loop iteration 7/10
[DEBUG] patternTable[191] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[191] incremented to          3
Test 16:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (13/16)

Loop iteration 8/10
[DEBUG] patternTable[127] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[127] incremented to          3
Test 17:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 82% (14/17)

Loop iteration 9/10
[DEBUG] patternTable[255] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[255] incremented to          3
Test 18:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 83% (15/18)

Loop iteration 10/10
[DEBUG] patternTable[255] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[255] incremented to          5
Test 19:                                                                                      Loop iteration.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 84% (16/19)

[DEBUG] patternTable[255] decremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[255] decremented to          4
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000010
Test 20:                                                                               Loop exit | not-taken.
  Program Counter: 0x00003000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 8)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 80% (16/20)

===                                                                           Large loop (15 iterations) ===
Loop iteration 1/15
[DEBUG] patternTable[250] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[250] incremented to          3
[DEBUG] branchTC[4] incremented to 00000000000000000000000000000011
Test 21:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (17/21)

Loop iteration 2/15
[DEBUG] patternTable[249] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[249] incremented to          3
Test 22:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (18/22)

Loop iteration 3/15
[DEBUG] patternTable[255] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[255] incremented to          6
Test 23:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 7)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 82% (19/23)

Loop iteration 4/15
INFO: [USF-XSim-96] XSim completed. Design snapshot 'branch_predictor_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
launch_simulation: Time (s): cpu = 00:00:02 ; elapsed = 00:00:05 . Memory (MB): peak = 1569.586 ; gain = 0.000
run all
[DEBUG] patternTable[243] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[243] incremented to          3
Test 24:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 83% (20/24)

Loop iteration 5/15
[DEBUG] patternTable[235] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[235] incremented to          3
Test 25:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 84% (21/25)

Loop iteration 6/15
[DEBUG] patternTable[219] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[219] incremented to          3
Test 26:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 84% (22/26)

Loop iteration 7/15
[DEBUG] patternTable[187] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[187] incremented to          3
Test 27:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 85% (23/27)

Loop iteration 8/15
[DEBUG] patternTable[123] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[123] incremented to          3
Test 28:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 85% (24/28)

Loop iteration 9/15
[DEBUG] patternTable[251] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[251] incremented to          5
Test 29:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 86% (25/29)

Loop iteration 10/15
[DEBUG] confidenceTable[251] incremented to          7
Test 30:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 8)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 86% (26/30)

Loop iteration 11/15
[DEBUG] confidenceTable[251] incremented to          9
Test 31:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 10)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 87% (27/31)

Loop iteration 12/15
[DEBUG] confidenceTable[251] incremented to         11
Test 32:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 9)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 87% (28/32)

Loop iteration 13/15
[DEBUG] confidenceTable[251] incremented to         13
Test 33:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 11)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 87% (29/33)

Loop iteration 14/15
[DEBUG] confidenceTable[251] incremented to         15
Test 34:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 13)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 88% (30/34)

Loop iteration 15/15
Test 35:                                                                                      Loop iteration.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 15)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 88% (31/35)

[DEBUG] patternTable[251] decremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[251] decremented to         14
[DEBUG] branchTC[4] decremented to 00000000000000000000000000000010
Test 36:                                                                               Loop exit | not-taken.
  Program Counter: 0x00004000
  Branch Format: 4 (    BLT)
  Predicted:     TAKEN (confidence: 15)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 86% (31/36)

Test 3: Branch Type Specialization
[DEBUG] patternTable[254] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[254] incremented to          5
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000011
Test 37:                                                                                BEQ training | taken.
  Program Counter: 0x00005000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 86% (32/37)

[DEBUG] patternTable[252] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[252] incremented to          3
Test 38:                                                                                BEQ training | taken.
  Program Counter: 0x00005004
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 86% (33/38)

[DEBUG] patternTable[249] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[249] incremented to          5
Test 39:                                                                                BEQ training | taken.
  Program Counter: 0x00005008
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 87% (34/39)

[DEBUG] patternTable[244] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[244] incremented to          3
Test 40:                                                                                BEQ training | taken.
  Program Counter: 0x0000500c
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 87% (35/40)

[DEBUG] patternTable[235] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[235] incremented to          5
Test 41:                                                                                BEQ training | taken.
  Program Counter: 0x00005010
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 87% (36/41)

[DEBUG] patternTable[218] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[218] incremented to          3
Test 42:                                                                                BEQ training | taken.
  Program Counter: 0x00005014
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 88% (37/42)

[DEBUG] patternTable[190] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[1] decremented to 00000000000000000000000000000001
Test 43:                                                                            BNE training | not taken.
  Program Counter: 0x00006000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 86% (37/43)

[DEBUG] branchTC[1] decremented to 00000000000000000000000000000000
Test 44:                                                                            BNE training | not taken.
  Program Counter: 0x00006004
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 84% (37/44)

[DEBUG] patternTable[255] decremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[255] decremented to          5
Test 45:                                                                            BNE training | not taken.
  Program Counter: 0x00006008
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 8)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 82% (37/45)

[DEBUG] patternTable[250] decremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[250] decremented to          2
Test 46:                                                                            BNE training | not taken.
  Program Counter: 0x0000600c
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 80% (37/46)

[DEBUG] patternTable[245] decremented to 00000000000000000000000000000000
[DEBUG] confidenceTable[245] incremented to          3
Test 47:                                                                            BNE training | not taken.
  Program Counter: 0x00006010
  Branch Format: 1 (    BNE)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (38/47)

[DEBUG] patternTable[228] decremented to 00000000000000000000000000000000
[DEBUG] confidenceTable[228] incremented to          3
Test 48:                                                                            BNE training | not taken.
  Program Counter: 0x00006014
  Branch Format: 1 (    BNE)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (39/48)

[DEBUG] patternTable[128] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[128] incremented to          3
Test 49:                                                                     BEQ test | should predict taken.
  Program Counter: 0x00005100
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (40/49)

[DEBUG] patternTable[192] decremented to 00000000000000000000000000000000
Test 50:                                                                 BNE test | should predict not taken.
  Program Counter: 0x00006100
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 80% (40/50)

Test 4: Alternating Pattern Recognition
Alternating pattern 1
[DEBUG] patternTable[2] decremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[2] decremented to          2
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000010
Test 51:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 78% (40/51)

Alternating pattern 2
[DEBUG] patternTable[4] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[4] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000011
Test 52:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (41/52)

Alternating pattern 3
[DEBUG] patternTable[9] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000010
Test 53:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 77% (41/53)

Alternating pattern 4
[DEBUG] patternTable[18] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[18] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000011
Test 54:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 77% (42/54)

Alternating pattern 5
[DEBUG] patternTable[37] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000010
Test 55:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 76% (42/55)

Alternating pattern 6
[DEBUG] patternTable[74] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[74] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000011
Test 56:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 76% (43/56)

Alternating pattern 7
[DEBUG] patternTable[149] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000010
Test 57:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 75% (43/57)

Alternating pattern 8
[DEBUG] patternTable[42] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[42] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000011
Test 58:                                                                                 Alternating pattern.
  Program Counter: 0x00007000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 75% (44/58)

=== TEST 5: Confidence Building ===
Confidence building iteration 1
[DEBUG] patternTable[84] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[84] incremented to          3
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000001
Test 59:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 76% (45/59)

Confidence building iteration 2
[DEBUG] patternTable[170] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[170] incremented to          3
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000010
Test 60:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 76% (46/60)

Confidence building iteration 3
[DEBUG] patternTable[86] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[86] incremented to          3
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000011
Test 61:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 77% (47/61)

Confidence building iteration 4
[DEBUG] patternTable[174] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[174] incremented to          3
Test 62:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 77% (48/62)

Confidence building iteration 5
[DEBUG] patternTable[94] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[94] incremented to          3
Test 63:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 77% (49/63)

Confidence building iteration 6
[DEBUG] patternTable[190] incremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[190] incremented to          3
Test 64:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (50/64)

Confidence building iteration 7
[DEBUG] patternTable[126] incremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[126] incremented to          3
Test 65:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (51/65)

Confidence building iteration 8
[DEBUG] confidenceTable[254] incremented to          7
Test 66:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 8)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (52/66)

Confidence building iteration 9
[DEBUG] confidenceTable[254] incremented to          9
Test 67:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 10)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 79% (53/67)

Confidence building iteration 10
[DEBUG] confidenceTable[254] incremented to         11
Test 68:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 9)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 79% (54/68)

Confidence building iteration 11
[DEBUG] confidenceTable[254] incremented to         13
Test 69:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 11)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 79% (55/69)

Confidence building iteration 12
[DEBUG] confidenceTable[254] incremented to         15
Test 70:                                                                       Confidence building iteration.
  Program Counter: 0x00008000
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 13)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (56/70)

=== TEST 6: Mixed Realistic Scenarios ===
[DEBUG] patternTable[255] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[255] incremented to          7
Test 71:                                                                                Outer loop iteration.
  Program Counter: 0x00009000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 8)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (57/71)

[DEBUG] patternTable[250] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[250] incremented to          4
Test 72:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (58/72)

[DEBUG] patternTable[250] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[250] incremented to          6
Test 73:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 7)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (59/73)

[DEBUG] confidenceTable[250] incremented to          8
Test 74:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 9)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (60/74)

[DEBUG] confidenceTable[250] incremented to         10
Test 75:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 8)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (61/75)

[DEBUG] patternTable[250] decremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[250] decremented to          9
[DEBUG] branchTC[1] decremented to 00000000000000000000000000000010
Test 76:                                                                                     Inner loop exit.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 10)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 80% (61/76)

Test 77:                                                                                Outer loop iteration.
  Program Counter: 0x00009000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 15)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (62/77)

[DEBUG] patternTable[248] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[248] incremented to          3
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000011
Test 78:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (63/78)

Test 79:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 15)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (64/79)

[DEBUG] patternTable[242] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[242] incremented to          3
Test 80:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (65/80)

[DEBUG] patternTable[234] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[234] incremented to          3
Test 81:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (66/81)

[DEBUG] patternTable[218] decremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[218] decremented to          2
[DEBUG] branchTC[1] decremented to 00000000000000000000000000000010
Test 82:                                                                                     Inner loop exit.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 80% (66/82)

[DEBUG] patternTable[190] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[190] incremented to          5
Test 83:                                                                                Outer loop iteration.
  Program Counter: 0x00009000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (67/83)

[DEBUG] patternTable[120] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[120] incremented to          3
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000011
Test 84:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 80% (68/84)

Test 85:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 15)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (69/85)

[DEBUG] patternTable[242] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[242] incremented to          5
Test 86:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (70/86)

[DEBUG] patternTable[234] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[234] incremented to          5
Test 87:                                                                                Inner loop iteration.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 81% (71/87)

[DEBUG] patternTable[218] decremented to 00000000000000000000000000000000
[DEBUG] confidenceTable[218] decremented to          1
[DEBUG] branchTC[1] decremented to 00000000000000000000000000000010
Test 88:                                                                                     Inner loop exit.
  Program Counter: 0x00009010
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 80% (71/88)

[DEBUG] patternTable[190] decremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[190] decremented to          4
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000010
Test 89:                                                                                     Outer loop exit.
  Program Counter: 0x00009000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 8)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 79% (71/89)

Test 7: Controlled Random Test
Controlled random test 1
[DEBUG] patternTable[124] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[0] decremented to 00000000000000000000000000000001
Test 90:                                                                              Controlled random test.
  Program Counter: 0x0000a000
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 78% (71/90)

Controlled random test 2
[DEBUG] patternTable[248] decremented to 00000000000000000000000000000001
[DEBUG] confidenceTable[248] decremented to          2
[DEBUG] branchTC[1] decremented to 00000000000000000000000000000001
Test 91:                                                                              Controlled random test.
  Program Counter: 0x0000a004
  Branch Format: 1 (    BNE)
  Predicted:     TAKEN (confidence: 3)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 78% (71/91)

Controlled random test 3
[DEBUG] patternTable[240] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[240] incremented to          3
[DEBUG] branchTC[2] incremented to 00000000000000000000000000000010
Test 92:                                                                              Controlled random test.
  Program Counter: 0x0000a008
  Branch Format: 2 (SERVED)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (72/92)

Controlled random test 4
[DEBUG] patternTable[225] decremented to 00000000000000000000000000000000
[DEBUG] confidenceTable[225] incremented to          3
[DEBUG] branchTC[3] decremented to 00000000000000000000000000000000
Test 93:                                                                              Controlled random test.
  Program Counter: 0x0000a00c
  Branch Format: 3 (SERVED)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (73/93)

Controlled random test 5
[DEBUG] patternTable[198] incremented to 00000000000000000000000000000010
[DEBUG] confidenceTable[198] incremented to          3
[DEBUG] branchTC[0] incremented to 00000000000000000000000000000010
Test 94:                                                                              Controlled random test.
  Program Counter: 0x0000a010
  Branch Format: 0 (    BEQ)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 78% (74/94)

Controlled random test 6
[DEBUG] patternTable[129] incremented to 00000000000000000000000000000010
[DEBUG] branchTC[1] incremented to 00000000000000000000000000000010
Test 95:                                                                              Controlled random test.
  Program Counter: 0x0000a014
  Branch Format: 1 (    BNE)
  Predicted: NOT-TAKEN (confidence: 2)
  Actual:     TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 77% (74/95)

Controlled random test 7
[DEBUG] patternTable[15] decremented to 00000000000000000000000000000000
[DEBUG] branchTC[2] decremented to 00000000000000000000000000000001
Test 96:                                                                              Controlled random test.
  Program Counter: 0x0000a018
  Branch Format: 2 (SERVED)
  Predicted:     TAKEN (confidence: 2)
  Actual: NOT-TAKEN
  FAIL: Prediction does not match actual outcome.
   Accuracy: 77% (74/96)

Controlled random test 8
[DEBUG] patternTable[18] incremented to 00000000000000000000000000000011
[DEBUG] confidenceTable[18] incremented to          5
[DEBUG] branchTC[3] incremented to 00000000000000000000000000000001
Test 97:                                                                              Controlled random test.
  Program Counter: 0x0000a01c
  Branch Format: 3 (SERVED)
  Predicted:     TAKEN (confidence: 2)
  Actual:     TAKEN
  PASS: Prediction matches actual outcome.
   Accuracy: 77% (75/97)

Pattern Analysis:
Stored 97 branch outcomes for analysis.
  DETECTED: Taken burst (74 taken, 23 not taken).

================================================
              TEST RESULTS SUMMARY              
================================================
Main Test Results:
  Total Tests: 97
  Correct Predictions: 75
  Failed Predictions: 22
  Total Predictions: 97
  Test Success Rate: 77%

Predictor Statistics:
  Total Predictions Made: 97
  Correct Predictions: 75
  Accuracy: 77%

Pattern Analysis:
  Stored 97 branch outcomes for analysis.
  Pattern Found: Yes
  Pattern Type:      Taken Burst
  Pattern Length: 97
================================================
EXCELLENT: Predictor accuracy >= 70"
TEST SUITE: PASSED (>= 70% individual tests correct).
================================================
$finish called at time : 3955 ns : File "D:/AMD/Projects/risc-v-processor-fpga/srcs/sim/branch_predictor_tb.v" Line 345
```