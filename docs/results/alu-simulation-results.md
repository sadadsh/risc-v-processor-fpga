```
===============================
     FIRST RISC-V ALU TEST     
===============================
Test 1: Addition Operations
  [ALU] Op: 0, A:0x0000000f, B:0x00000019 -> Result:0x00000028, Power: 10
PASS:                                                                                                                                                                                                 
15 + 25 | 0x0000000f op 0x00000019 = 0x00000028 | Power:  10
  [ALU] Op: 0, A:0x0000000f, B:0x00000019 -> Result:0x00000028, Power: 10
  [ALU] Op: 0, A:0x00000000, B:0x00000000 -> Result:0x00000000, Power: 10
PASS:                                                                                                                                                                                                   
0 + 0 | 0x00000000 op 0x00000000 = 0x00000000 | Power:  10
  [ALU] Op: 0, A:0x00000000, B:0x00000000 -> Result:0x00000000, Power: 10
  [ALU] Op: 0, A:0xffffffff, B:0x00000001 -> Result:0x00000000, Power: 10
PASS:                                                                                                                                                                               
0xFFFFFFFF + 1 (overflow) | 0xffffffff op 0x00000001 = 0x00000000 | Power:  10
Test 2: Subtraction Operations
  [ALU] Op: 0, A:0xffffffff, B:0x00000001 -> Result:0x00000000, Power: 10
  [ALU] Op: 1, A:0x00000032, B:0x0000001e -> Result:0x00000014, Power: 12
PASS:                                                                                                                                                                                                 
50 - 30 | 0x00000032 op 0x0000001e = 0x00000014 | Power:  12
  [ALU] Op: 1, A:0x00000032, B:0x0000001e -> Result:0x00000014, Power: 12
  [ALU] Op: 1, A:0x0000000a, B:0x0000000a -> Result:0x00000000, Power: 12
PASS:                                                                                                                                                                                                 
10 - 10 | 0x0000000a op 0x0000000a = 0x00000000 | Power:  12
  [ALU] Op: 1, A:0x0000000a, B:0x0000000a -> Result:0x00000000, Power: 12
  [ALU] Op: 1, A:0x00000005, B:0x0000000a -> Result:0xfffffffb, Power: 12
PASS:                                                                                                                                                                                       
5 - 10 (negative) | 0x00000005 op 0x0000000a = 0xfffffffb | Power:  12
Test 3: Logical Operations
  [ALU] Op: 1, A:0x00000005, B:0x0000000a -> Result:0xfffffffb, Power: 12
  [ALU] Op: 2, A:0xf0f0f0f0, B:0x0f0f0f0f -> Result:0x00000000, Power:  8
PASS:                                                                                                                                                                                           
AND operation | 0xf0f0f0f0 op 0x0f0f0f0f = 0x00000000 | Power:   8
  [ALU] Op: 2, A:0xf0f0f0f0, B:0x0f0f0f0f -> Result:0x00000000, Power:  8
  [ALU] Op: 2, A:0xffffffff, B:0x12345678 -> Result:0x12345678, Power:  8
PASS:                                                                                                                                                                                         
AND with all 1s | 0xffffffff op 0x12345678 = 0x12345678 | Power:   8
  [ALU] Op: 2, A:0xffffffff, B:0x12345678 -> Result:0x12345678, Power:  8
  [ALU] Op: 3, A:0xf0f0f0f0, B:0x0f0f0f0f -> Result:0xffffffff, Power:  8
PASS:                                                                                                                                                                                            
OR operation | 0xf0f0f0f0 op 0x0f0f0f0f = 0xffffffff | Power:   8
  [ALU] Op: 3, A:0xf0f0f0f0, B:0x0f0f0f0f -> Result:0xffffffff, Power:  8
  [ALU] Op: 3, A:0x00000000, B:0x12345678 -> Result:0x12345678, Power:  8
PASS:                                                                                                                                                                                            
OR with zero | 0x00000000 op 0x12345678 = 0x12345678 | Power:   8
  [ALU] Op: 3, A:0x00000000, B:0x12345678 -> Result:0x12345678, Power:  8
  [ALU] Op: 4, A:0xaaaaaaaa, B:0x55555555 -> Result:0xffffffff, Power:  9
PASS:                                                                                                                                                                                           
XOR operation | 0xaaaaaaaa op 0x55555555 = 0xffffffff | Power:   9
  [ALU] Op: 4, A:0xaaaaaaaa, B:0x55555555 -> Result:0xffffffff, Power:  9
  [ALU] Op: 4, A:0x12345678, B:0x12345678 -> Result:0x00000000, Power:  9
PASS:                                                                                                                                                                                           
XOR with self | 0x12345678 op 0x12345678 = 0x00000000 | Power:   9
Test 4: Comparison Operation
  [ALU] Op: 4, A:0x12345678, B:0x12345678 -> Result:0x00000000, Power:  9
  [ALU] Op: 5, A:0x0000000a, B:0x00000014 -> Result:0x00000001, Power: 15
PASS:                                                                                                                                                                                        
10 < 20 (signed) | 0x0000000a op 0x00000014 = 0x00000001 | Power:  15
  [ALU] Op: 5, A:0x0000000a, B:0x00000014 -> Result:0x00000001, Power: 15
  [ALU] Op: 5, A:0x00000014, B:0x0000000a -> Result:0x00000000, Power: 15
PASS:                                                                                                                                                                                        
20 < 10 (signed) | 0x00000014 op 0x0000000a = 0x00000000 | Power:  15
  [ALU] Op: 5, A:0x00000014, B:0x0000000a -> Result:0x00000000, Power: 15
  [ALU] Op: 5, A:0xffffffff, B:0x00000001 -> Result:0x00000001, Power: 15
PASS:                                                                                                                                                                                         
-1 < 1 (signed) | 0xffffffff op 0x00000001 = 0x00000001 | Power:  15
  [ALU] Op: 5, A:0xffffffff, B:0x00000001 -> Result:0x00000001, Power: 15
  [ALU] Op: 6, A:0x0000000a, B:0x00000014 -> Result:0x00000001, Power: 15
PASS:                                                                                                                                                                                      
10 < 20 (unsigned) | 0x0000000a op 0x00000014 = 0x00000001 | Power:  15
  [ALU] Op: 6, A:0x0000000a, B:0x00000014 -> Result:0x00000001, Power: 15
  [ALU] Op: 6, A:0xffffffff, B:0x00000001 -> Result:0x00000000, Power: 15
PASS:                                                                                                                                                                               
0xFFFFFFFF < 1 (unsigned) | 0xffffffff op 0x00000001 = 0x00000000 | Power:  15
Test 5: Shift Operations
  [ALU] Op: 6, A:0xffffffff, B:0x00000001 -> Result:0x00000000, Power: 15
  [ALU] Op: 7, A:0x00000001, B:0x00000004 -> Result:0x00000010, Power: 20
PASS:                                                                                                                                                                                                  
1 << 4 | 0x00000001 op 0x00000004 = 0x00000010 | Power:  20
  [ALU] Op: 7, A:0x00000001, B:0x00000004 -> Result:0x00000010, Power: 20
  [ALU] Op: 7, A:0x12345678, B:0x00000008 -> Result:0x34567800, Power: 20
PASS:                                                                                                                                                                                       
Shift left 8 bits | 0x12345678 op 0x00000008 = 0x34567800 | Power:  20
  [ALU] Op: 7, A:0x12345678, B:0x00000008 -> Result:0x34567800, Power: 20
  [ALU] Op: 8, A:0x80000000, B:0x00000004 -> Result:0x08000000, Power: 20
PASS:                                                                                                                                                                                     
Logical right shift | 0x80000000 op 0x00000004 = 0x08000000 | Power:  20
  [ALU] Op: 8, A:0x80000000, B:0x00000004 -> Result:0x08000000, Power: 20
  [ALU] Op: 8, A:0xffffffff, B:0x00000008 -> Result:0x00ffffff, Power: 20
PASS:                                                                                                                                                                                     
Right shift with 1s | 0xffffffff op 0x00000008 = 0x00ffffff | Power:  20
  [ALU] Op: 8, A:0xffffffff, B:0x00000008 -> Result:0x00ffffff, Power: 20
  [ALU] Op: 9, A:0x80000000, B:0x00000004 -> Result:0xf8000000, Power: 22
PASS:                                                                                                                                                                                  
Arithmetic right shift | 0x80000000 op 0x00000004 = 0xf8000000 | Power:  22
  [ALU] Op: 9, A:0x80000000, B:0x00000004 -> Result:0xf8000000, Power: 22
  [ALU] Op: 9, A:0x7fffffff, B:0x00000004 -> Result:0x07ffffff, Power: 22
PASS:                                                                                                                                                                         
Arithmetic right shift positive | 0x7fffffff op 0x00000004 = 0x07ffffff | Power:  22
Test 6: Zero Flag Testing
  [ALU] Op: 9, A:0x7fffffff, B:0x00000004 -> Result:0x07ffffff, Power: 22
  [ALU] Op: 0, A:0x00000000, B:0x00000000 -> Result:0x00000000, Power: 10
PASS: Zero Flag Test:                                                                                                                                                                                           
Zero addition | Result: 0x00000000, Zero: 1
  [ALU] Op: 1, A:0x00000064, B:0x00000064 -> Result:0x00000000, Power: 12
PASS: Zero Flag Test:                                                                                                                                                                                       
Equal subtraction | Result: 0x00000000, Zero: 1
  [ALU] Op: 2, A:0xf0f0f0f0, B:0x0f0f0f0f -> Result:0x00000000, Power:  8
PASS: Zero Flag Test:                                                                                                                                                                                   
AND resulting in zero | Result: 0x00000000, Zero: 1
  [ALU] Op: 4, A:0x0005adad, B:0x0005adad -> Result:0x00000000, Power:  9
PASS: Zero Flag Test:                                                                                                                                                                               
XOR with self (literally) | Result: 0x00000000, Zero: 1
Test 7: Performance Monitoring
Performing multiple operation to test performance counters...
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
PASS:                                                                                                                                                                                    
Performance Test ADD | 0x00000001 op 0x00000001 = 0x00000002 | Power:  10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
PASS:                                                                                                                                                                                    
Performance Test ADD | 0x00000001 op 0x00000001 = 0x00000002 | Power:  10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
PASS:                                                                                                                                                                                    
Performance Test ADD | 0x00000001 op 0x00000001 = 0x00000002 | Power:  10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
PASS:                                                                                                                                                                                    
Performance Test ADD | 0x00000001 op 0x00000001 = 0x00000002 | Power:  10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
PASS:                                                                                                                                                                                    
Performance Test ADD | 0x00000001 op 0x00000001 = 0x00000002 | Power:  10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
  [ALU] Op: 1, A:0x0000000a, B:0x00000005 -> Result:0x00000005, Power: 12
PASS:                                                                                                                                                                                    
Performance Test SUB | 0x0000000a op 0x00000005 = 0x00000005 | Power:  12
  [ALU] Op: 1, A:0x0000000a, B:0x00000005 -> Result:0x00000005, Power: 12
  [ALU] Op: 1, A:0x0000000a, B:0x00000005 -> Result:0x00000005, Power: 12
PASS:                                                                                                                                                                                    
Performance Test SUB | 0x0000000a op 0x00000005 = 0x00000005 | Power:  12
  [ALU] Op: 1, A:0x0000000a, B:0x00000005 -> Result:0x00000005, Power: 12
  [ALU] Op: 1, A:0x0000000a, B:0x00000005 -> Result:0x00000005, Power: 12
PASS:                                                                                                                                                                                    
Performance Test SUB | 0x0000000a op 0x00000005 = 0x00000005 | Power:  12
  [ALU] Op: 1, A:0x0000000a, B:0x00000005 -> Result:0x00000005, Power: 12
PERFORMANCE STATISTICS:
    Total operations:         66
    Most used operation:          Z
    Operation active: 0
Test 8: Power Consumption
Testing power consumption for different operations...
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
PASS:                                                                                                                                                                                          
Power Test ADD | 0x00000001 op 0x00000001 = 0x00000002 | Power:  10
  [ALU] Op: 0, A:0x00000001, B:0x00000001 -> Result:0x00000002, Power: 10
  [ALU] Op: 1, A:0x00000001, B:0x00000001 -> Result:0x00000000, Power: 12
PASS:                                                                                                                                                                                          
Power Test SUB | 0x00000001 op 0x00000001 = 0x00000000 | Power:  12
  [ALU] Op: 1, A:0x00000001, B:0x00000001 -> Result:0x00000000, Power: 12
  [ALU] Op: 2, A:0x000000ff, B:0x000000ff -> Result:0x000000ff, Power:  8
PASS:                                                                                                                                                                                          
Power Test AND | 0x000000ff op 0x000000ff = 0x000000ff | Power:   8
  [ALU] Op: 2, A:0x000000ff, B:0x000000ff -> Result:0x000000ff, Power:  8
  [ALU] Op: 7, A:0x00000001, B:0x00000004 -> Result:0x00000010, Power: 20
PASS:                                                                                                                                                                                          
Power Test SLL | 0x00000001 op 0x00000004 = 0x00000010 | Power:  20
  [ALU] Op: 7, A:0x00000001, B:0x00000004 -> Result:0x00000010, Power: 20
  [ALU] Op: 9, A:0x80000000, B:0x00000001 -> Result:0xc0000000, Power: 22
PASS:                                                                                                                                                                                          
Power Test SRA | 0x80000000 op 0x00000001 = 0xc0000000 | Power:  22
===============================
      ALU TEST SUMMARIZED      
===============================
Total Tests:          40
Passed:          40
Failed:           0
Success Rate:         100%
ALL TESTS PASSED! ALU is prepared for processor integration!
===============================
     ALU TEST FILE COMPLETE    
===============================
  [ALU] Op: 9, A:0x80000000, B:0x00000001 -> Result:0xc0000000, Power: 22
INFO: [USF-XSim-96] XSim completed. Design snapshot 'alu_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
```
