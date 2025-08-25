#=============================================================================
# Yosys Synthesis Script for PDM to PCM Decimator
#=============================================================================
# Description: Yosys synthesis script for PDM to PCM decimator core
#              Optimized for multi-stage filter chain implementation
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Set the top module
set top_module "pdm_pcm_decimator_core"

# Read RTL files
read_verilog -sv rtl/fir_coefficients.sv
read_verilog -sv rtl/fifo_sync.sv
read_verilog -sv rtl/pdm_pcm_decimator_core.sv

# Set the top module
hierarchy -top $top_module

# High-level synthesis
proc
opt_expr
opt_clean
check
opt -nodffe -nosdff
fsm
opt
wreduce
peepopt
opt_clean

# Technology mapping
techmap
opt -fast

# Final optimization
opt -full

# Write synthesized netlist
write_verilog -noattr -noexpr -nohex -nodec build/yosys/pdm_pcm_decimator_core.v

# Generate statistics
stat -width

# Show design hierarchy
show -prefix build/yosys/pdm_pcm_decimator_core

# Generate JSON for documentation
write_json build/yosys/pdm_pcm_decimator_core.json
