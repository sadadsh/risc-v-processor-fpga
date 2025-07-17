# ================================================================
# Constraints File for RISC-V Processor System
# Xilinx Zynq-7020 FPGA (Z7-20 Board) Pin Assignments
# ================================================================
# Complete pin assignments and timing constraints for the enhanced
# RISC-V processor system with power management and branch prediction.
# Optimized for stable operation and performance.
# ================================================================

# ================================================================
# CLOCK CONSTRAINTS
# ================================================================

# Primary board clock - 100MHz system clock
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk]

# Generated clocks from clock manager
create_generated_clock -name processorClock -source [get_ports clk] -divide_by 2 [get_pins clockManager/processorClock]
create_generated_clock -name peripheralClock -source [get_ports clk] -divide_by 2 [get_pins clockManager/peripheralClock]
create_generated_clock -name debugClock -source [get_ports clk] -divide_by 4 [get_pins clockManager/debugClock]

# Clock domain crossing constraints
set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks processorClock]
set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks peripheralClock]
set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks debugClock]

# ================================================================
# BUTTON INPUTS
# ================================================================

# Center button (Reset) - Active high, external pulldown
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports btnC]

# Up button (Demo start)
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports btnU]

# Down button (Demo stop)
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports btnD]

# Left button (Frequency down)
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports btnL]

# Right button (Frequency up)
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports btnR]

# Button input timing constraints
set_input_delay -clock [get_clocks clk] -min 2.000 [get_ports {btnC btnU btnD btnL btnR}]
set_input_delay -clock [get_clocks clk] -max 8.000 [get_ports {btnC btnU btnD btnL btnR}]

# ================================================================
# SWITCH INPUTS
# ================================================================

# 16 switches for system control
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {sw[8]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {sw[9]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {sw[10]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {sw[11]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {sw[12]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {sw[13]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {sw[14]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {sw[15]}]

# Switch input timing constraints
set_input_delay -clock [get_clocks clk] -min 1.000 [get_ports {sw[*]}]
set_input_delay -clock [get_clocks clk] -max 6.000 [get_ports {sw[*]}]

# ================================================================
# LED OUTPUTS
# ================================================================

# 16 standard LEDs for status display
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {led[7]}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {led[9]}]
set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {led[10]}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {led[11]}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {led[12]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {led[13]}]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {led[14]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {led[15]}]

# RGB LEDs for advanced status indication
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports led16_r]
set_property -dict {PACKAGE_PIN T5  IOSTANDARD LVCMOS33} [get_ports led16_g]
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33} [get_ports led16_b]
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33} [get_ports led17_r]
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVCMOS33} [get_ports led17_g]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports led17_b]

# LED output timing constraints
set_output_delay -clock [get_clocks peripheralClock] -min 1.000 [get_ports {led[*]}]
set_output_delay -clock [get_clocks peripheralClock] -max 4.000 [get_ports {led[*]}]
set_output_delay -clock [get_clocks peripheralClock] -min 1.000 [get_ports {led16_* led17_*}]
set_output_delay -clock [get_clocks peripheralClock] -max 4.000 [get_ports {led16_* led17_*}]

# ================================================================
# 7-SEGMENT DISPLAY
# ================================================================

# 7-segment display segments (active low)
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]

# 7-segment display anodes (active low)
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {an[3]}]

# Decimal point (active low)
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports dp]

# 7-segment display timing constraints
set_output_delay -clock [get_clocks peripheralClock] -min 1.000 [get_ports {seg[*] an[*] dp}]
set_output_delay -clock [get_clocks peripheralClock] -max 3.000 [get_ports {seg[*] an[*] dp}]

# ================================================================
# UART INTERFACE
# ================================================================

# UART transmit (to PC)
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports uart_txd_in]

# UART receive (from PC)
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports uart_rxd_out]

# UART timing constraints
set_output_delay -clock [get_clocks debugClock] -min 1.000 [get_ports uart_txd_in]
set_output_delay -clock [get_clocks debugClock] -max 5.000 [get_ports uart_txd_in]
set_input_delay -clock [get_clocks debugClock] -min 2.000 [get_ports uart_rxd_out]
set_input_delay -clock [get_clocks debugClock] -max 8.000 [get_ports uart_rxd_out]

# ================================================================
# TIMING CONSTRAINTS
# ================================================================

# Processor core timing constraints
set_max_delay -from [get_clocks processorClock] -to [get_clocks peripheralClock] 15.000
set_max_delay -from [get_clocks peripheralClock] -to [get_clocks processorClock] 15.000

# Power management timing constraints
set_max_delay -from [get_pins {processorCore/powerOptimizerUnit/*}] -to [get_pins {clockManager/*}] 10.000

# Branch predictor timing constraints (critical path)
set_max_delay -from [get_pins {processorCore/branchPredictorUnit/patternTable_reg[*][*]}] -to [get_pins {processorCore/branchPredictorUnit/prediction_reg}] 8.000

# Memory interface timing
set_max_delay -datapath_only -from [get_pins {processorCore/*/Q}] -to [get_pins {processorCore/*/D}] 12.000

# ================================================================
# POWER AND THERMAL CONSTRAINTS
# ================================================================

# Power optimization settings
set_property POWER_OPT.PAR_HIGH_EFFORT true [current_design]
set_property POWER_OPT.LOW_POWER_PLACEMENT true [current_design]

# Thermal constraints for Z7-20
set_operating_conditions -ambient_temp 25.0 -board_temp 35.0 -junction_temp 85.0

# ================================================================
# PLACEMENT AND ROUTING CONSTRAINTS
# ================================================================

# Critical path placement constraints
set_property LOC SLICE_X50Y50 [get_cells {processorCore/branchPredictorUnit/prediction_reg}]
set_property LOC SLICE_X45Y45 [get_cells {clockManager/processorClock_reg}]

# Power management unit placement
set_property LOC SLICE_X60Y60 [get_cells {processorCore/powerOptimizerUnit/powerState_reg[*]}]

# High-speed signal routing
set_property ROUTE_PRIORITY HIGH [get_nets {processorClock}]
set_property ROUTE_PRIORITY HIGH [get_nets {systemResetSync}]

# ================================================================
# CONFIGURATION CONSTRAINTS
# ================================================================

# Configuration memory protection
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Security settings
set_property BITSTREAM.ENCRYPTION.ENCRYPT FALSE [current_design]
set_property BITSTREAM.GENERAL.CRC_CHECK TRUE [current_design]

# ================================================================
# DEBUGGING CONSTRAINTS
# ================================================================

# ILA (Integrated Logic Analyzer) constraints for debugging
# Uncomment these lines if you want to add ILA cores for debugging

# create_debug_core u_ila_0 ila
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
# set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
# set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
# set_property port_width 1 [get_debug_ports u_ila_0/clk]
# connect_debug_port u_ila_0/clk [get_nets [list processorClock]]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
# set_property port_width 32 [get_debug_ports u_ila_0/probe0]
# connect_debug_port u_ila_0/probe0 [get_nets [list {programCounter[*]}]]

# ================================================================
# FALSE PATH CONSTRAINTS
# ================================================================

# Asynchronous reset paths
set_false_path -from [get_ports btnC] -to [get_registers {*/reset_sync_reg[*]}]

# Switch inputs are quasi-static
set_false_path -from [get_ports {sw[*]}] -to [get_registers]

# Button inputs have their own synchronizers
set_false_path -from [get_ports {btnU btnD btnL btnR}] -to [get_registers]

# RGB LED PWM paths (not critical timing)
set_false_path -to [get_ports {led16_* led17_*}]

# ================================================================
# MULTI-CYCLE PATH CONSTRAINTS
# ================================================================

# Power management updates can take multiple cycles
set_multicycle_path -setup 2 -from [get_pins {processorCore/powerOptimizerUnit/powerState_reg[*]/C}] -to [get_pins {clockManager/activeFrequencyLevel_reg[*]/D}]
set_multicycle_path -hold 1 -from [get_pins {processorCore/powerOptimizerUnit/powerState_reg[*]/C}] -to [get_pins {clockManager/activeFrequencyLevel_reg[*]/D}]

# 7-segment display refresh can be relaxed
set_multicycle_path -setup 3 -from [get_pins {displayController/currentDigit_reg[*]/C}] -to [get_ports {seg[*]}]
set_multicycle_path -hold 2 -from [get_pins {displayController/currentDigit_reg[*]/C}] -to [get_ports {seg[*]}]

# ================================================================
# AREA AND UTILIZATION CONSTRAINTS
# ================================================================

# Ensure reasonable utilization for thermal management
set_property TARGET_UTILIZATION 75 [current_design]

# Clock region constraints to avoid congestion
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets clk_IBUF]

# ================================================================
# DRC (Design Rule Check) WAIVERS
# ================================================================

# Waive DRC for intentional clock domain crossings in power management
create_waiver -internal -type DRC -id {TIMING-20} -objects [get_pins {clockManager/frequencyChangeDelay_reg[*]/D}] -description "Intentional clock domain crossing for power management"

# ================================================================
# IMPLEMENTATION STRATEGY
# ================================================================

# Use performance-oriented implementation strategies
set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]

# Enable aggressive optimization for critical paths
set_property STEPS.OPT_DESIGN.ARGS.DIRECTIVE ExploreSequentialArea [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

# ================================================================
# END OF CONSTRAINTS FILE
# ================================================================