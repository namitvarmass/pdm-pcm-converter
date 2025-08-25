#=============================================================================
# PDM to PCM Decimator Xilinx Design Constraints
#=============================================================================
# Description: Xilinx Design Constraints (XDC) for PDM to PCM decimator
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Clock constraints
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_clock_uncertainty 0.100 [get_clocks clk]

# Clock groups
set_clock_groups -asynchronous -group [get_clocks clk]

# Input delays
set_input_delay -clock clk -max 2.000 [get_ports pdm_in]
set_input_delay -clock clk -max 2.000 [get_ports pdm_valid]
set_input_delay -clock clk -max 2.000 [get_ports pcm_ready]
set_input_delay -clock clk -max 2.000 [get_ports enable]
set_input_delay -clock clk -max 2.000 [get_ports rst_n]

# Output delays
set_output_delay -clock clk -max 2.000 [get_ports pdm_ready]
set_output_delay -clock clk -max 2.000 [get_ports pcm_out*]
set_output_delay -clock clk -max 2.000 [get_ports pcm_valid]
set_output_delay -clock clk -max 2.000 [get_ports busy]
set_output_delay -clock clk -max 2.000 [get_ports overflow]
set_output_delay -clock clk -max 2.000 [get_ports underflow]

# False paths
set_false_path -from [get_ports rst_n]
set_false_path -to [get_ports overflow]
set_false_path -to [get_ports underflow]

# Multicycle paths
set_multicycle_path -setup 2 -from [get_clocks clk] -to [get_clocks clk]

# Pin assignments (example for Zynq-7000)
# Uncomment and modify as needed for your specific FPGA board

# Clock input
# set_property PACKAGE_PIN Y9 [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Reset input
# set_property PACKAGE_PIN R19 [get_ports rst_n]
# set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# PDM input
# set_property PACKAGE_PIN U16 [get_ports pdm_in]
# set_property IOSTANDARD LVCMOS33 [get_ports pdm_in]

# PDM valid
# set_property PACKAGE_PIN E19 [get_ports pdm_valid]
# set_property IOSTANDARD LVCMOS33 [get_ports pdm_valid]

# PDM ready
# set_property PACKAGE_PIN U19 [get_ports pdm_ready]
# set_property IOSTANDARD LVCMOS33 [get_ports pdm_ready]

# PCM output (8-32 bit bus, adjust pin count based on data width)
# set_property PACKAGE_PIN {V13 V14 U14 U15 U16 E19 U19 V19 W18 W19 T18 T19 R18 R19 P18 P19} [get_ports {pcm_out[*]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {pcm_out[*]}]

# PCM valid
# set_property PACKAGE_PIN W13 [get_ports pcm_valid]
# set_property IOSTANDARD LVCMOS33 [get_ports pcm_valid]

# PCM ready
# set_property PACKAGE_PIN W14 [get_ports pcm_ready]
# set_property IOSTANDARD LVCMOS33 [get_ports pcm_ready]

# Enable
# set_property PACKAGE_PIN W15 [get_ports enable]
# set_property IOSTANDARD LVCMOS33 [get_ports enable]

# Status outputs
# set_property PACKAGE_PIN W16 [get_ports busy]
# set_property IOSTANDARD LVCMOS33 [get_ports busy]

# set_property PACKAGE_PIN W17 [get_ports overflow]
# set_property IOSTANDARD LVCMOS33 [get_ports overflow]

# set_property PACKAGE_PIN W18 [get_ports underflow]
# set_property IOSTANDARD LVCMOS33 [get_ports underflow]

# Timing constraints
set_max_delay -from [get_clocks clk] -to [get_clocks clk] 8.000

# Area constraints
set_property CONTAIN_ROUTING true [get_cells pdm_pcm_decimator_inst]

# Power constraints
set_operating_conditions -grade extended

# Implementation constraints
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.TCL.PRE {} [get_runs impl_1]

# Don't touch nets
set_property DONT_TOUCH true [get_nets clk]
set_property DONT_TOUCH true [get_nets rst_n]
