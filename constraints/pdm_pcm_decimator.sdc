#=============================================================================
# PDM to PCM Decimator Timing Constraints
#=============================================================================
# Description: Synopsys Design Constraints (SDC) for PDM to PCM decimator
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Clock definitions
create_clock -name clk -period 10.000 [get_ports clk]
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

# Load constraints
set_load 10 [all_outputs]

# Drive strength
set_drive 1 [all_inputs]

# Area constraints
set_max_area 0

# Power constraints
set_max_dynamic_power 100mW
set_max_leakage_power 10mW

# Operating conditions
set_operating_conditions -library slow_1v0_85c

# Wire load model
set_wire_load_model -name "tsmc090_wl10" -library slow_1v0_85c

# Timing exceptions
set_clock_groups -asynchronous -group [get_clocks clk]

# Don't touch nets
set_dont_touch_network [get_clocks clk]
set_dont_touch_network [get_ports rst_n]
