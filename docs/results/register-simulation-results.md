```
Time resolution is 1 ps
source register_file_tb.tcl
# set curr_wave [current_wave_config]
# if { [string length $curr_wave] == 0 } {
#   if { [llength [get_objects]] > 0} {
#     add_wave /
#     set_property needs_save false [current_wave_config]
#   } else {
#      send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
#   }
# }
# run 1000ns
===============================
FIRST RISC-V REGISTER FILE TEST
===============================
Test 1: Writing 0x5ADAD to Register 1
   [WRITE] x 1 <= 0x0005adad
Test 2: Reading from Register 1
   [READ] x 1 = 0x00000000, x 0 = 0x00000000
PASS: Read correct value 0x0005adad
Test 3: Proving x0 is 0
PASS: x0 reads as 0
Test 4: Attempt to Write to x0
PASS: x0 remains 0 after write attempt
Test 5: Testing Performance Monitoring
   [WRITE] x 5 <= 0x0005adad
   [WRITE] x 5 <= 0x0005adad
   [READ] x 5 = 0x00000000, x 1 = 0x00000000
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
PERFORMANCE STATISTICS:
    Total accesses:         11
    Total writes:          3
    Most used register:  1
    Power active this cycle: 1
Test 6: Power Activity Monitoring
   [READ] x 5 = 0x0005adad, x 1 = 0x0005adad
    Power active (no real access): 0
   [READ] x 5 = 0x00000000, x 0 = 0x00000000
    Power active (real access): 1
===============================
  REGISTER TEST FILE COMPLETE  
===============================
$finish called at time : 235 ns : File "D:/AMD/Projects/RISC-V/RISC-V.srcs/sim_1/new/register_file_tb.v" Line 155
INFO: [USF-XSim-96] XSim completed. Design snapshot 'register_file_tb_behav' loaded.
INFO: [USF-XSim-97] XSim simulation ran for 1000ns
launch_simulation: Time (s): cpu = 00:00:03 ; elapsed = 00:00:06 . Memory (MB): peak = 1571.062 ; gain = 23.199
```
