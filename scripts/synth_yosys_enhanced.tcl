#=============================================================================
# PDM to PCM Decimator Core - Enhanced Yosys Synthesis Script
#=============================================================================
# Description: Comprehensive Yosys synthesis script for PDM to PCM decimator
#              Supports multiple technology libraries and optimization levels
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Script configuration
set script_version "1.3.0"
set design_name "pdm_pcm_decimator_core"
set top_module "pdm_pcm_decimator_core"

# Technology library configuration
set tech_lib "sky130A"  # Default: sky130A, alternatives: asap7, nangate45, etc.
set cell_lib "sky130_fd_sc_hd"  # Default: sky130_fd_sc_hd

# Synthesis configuration
set opt_level 2  # Optimization level: 0=basic, 1=medium, 2=aggressive
set abc_opt 1    # ABC optimization: 0=disabled, 1=enabled
set flatten 0    # Flatten hierarchy: 0=preserve, 1=flatten
set retime 1     # Retiming: 0=disabled, 1=enabled

# Timing constraints
set clock_period 10.0  # Clock period in ns (100 MHz)
set clock_port "clock_i"

# Output configuration
set output_dir "build/yosys"
set netlist_file "${output_dir}/${design_name}.v"
set json_file "${output_dir}/${design_name}.json"
set stats_file "${output_dir}/${design_name}_stats.txt"
set timing_file "${output_dir}/${design_name}_timing.txt"

# Create output directory
file mkdir $output_dir

# Logging setup
log -stdout "Starting Yosys synthesis for ${design_name} v${script_version}"
log -stdout "Technology: ${tech_lib}, Cell library: ${cell_lib}"
log -stdout "Optimization level: ${opt_level}, ABC: ${abc_opt}, Retiming: ${retime}"

#=============================================================================
# Read RTL Files
#=============================================================================
log -stdout "Reading RTL files..."

# Read SystemVerilog files
read_verilog -sv rtl/fir_coefficients.sv
read_verilog -sv rtl/fifo_sync.sv
read_verilog -sv rtl/pdm_pcm_decimator_core.sv

# Set top module
hierarchy -top $top_module

# Check design
log -stdout "Checking design hierarchy..."
check -noinit
check -assert

#=============================================================================
# High-Level Synthesis
#=============================================================================
log -stdout "Performing high-level synthesis..."

# Process design
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

#=============================================================================
# Technology Mapping
#=============================================================================
log -stdout "Performing technology mapping..."

# Technology mapping based on library
if {$tech_lib == "sky130A"} {
    # SkyWater 130nm technology
    techmap -map +/sky130A/cells_adders/sky130_fd_sc_hd__ha_*.v
    techmap -map +/sky130A/cells_adders/sky130_fd_sc_hd__fa_*.v
    techmap -map +/sky130A/cells_logic/sky130_fd_sc_hd__*.v
    dfflibmap -liberty +/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
} elseif {$tech_lib == "asap7"} {
    # ASAP7 technology
    techmap -map +/asap7/mycells/simple/*.v
    dfflibmap -liberty +/asap7/lib/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib
} elseif {$tech_lib == "nangate45"} {
    # Nangate 45nm technology
    techmap -map +/nangate45/cells_adders/*.v
    techmap -map +/nangate45/cells_latch/*.v
    dfflibmap -liberty +/nangate45/lib/NangateOpenCellLibrary_typical.lib
} else {
    # Generic technology mapping
    techmap
    dfflibmap
}

# ABC optimization
if {$abc_opt} {
    log -stdout "Running ABC optimization..."
    abc -D $clock_period -constr constraints/${design_name}.sdc
}

#=============================================================================
# Optimization
#=============================================================================
log -stdout "Performing optimizations..."

# Optimization based on level
if {$opt_level >= 1} {
    opt -fast
    opt_clean
}

if {$opt_level >= 2} {
    opt -full
    opt_clean
    wreduce
    peepopt
    opt_clean
}

# Retiming
if {$retime} {
    log -stdout "Performing retiming..."
    opt -fast
    retime -D $clock_period
}

#=============================================================================
# Final Optimization
#=============================================================================
log -stdout "Final optimization pass..."
opt -full
opt_clean

#=============================================================================
# Write Output Files
#=============================================================================
log -stdout "Writing output files..."

# Write netlist
write_verilog -noattr -noexpr -nohex -nodec $netlist_file
log -stdout "Netlist written to: $netlist_file"

# Write JSON for documentation
write_json $json_file
log -stdout "JSON written to: $json_file"

#=============================================================================
# Generate Statistics
#=============================================================================
log -stdout "Generating statistics..."

# Design statistics
set stats [stat -width]
set stats_text "=== PDM to PCM Decimator Core Synthesis Statistics ===\n"
append stats_text "Design: $design_name\n"
append stats_text "Technology: $tech_lib\n"
append stats_text "Cell Library: $cell_lib\n"
append stats_text "Clock Period: ${clock_period}ns\n"
append stats_text "Optimization Level: $opt_level\n"
append stats_text "ABC Optimization: $abc_opt\n"
append stats_text "Retiming: $retime\n"
append stats_text "\n$stats\n"

# Write statistics to file
set fh [open $stats_file w]
puts $fh $stats_text
close $fh
log -stdout "Statistics written to: $stats_file"

# Display statistics
puts $stats_text

#=============================================================================
# Timing Analysis
#=============================================================================
log -stdout "Performing timing analysis..."

# Read liberty file for timing analysis
if {$tech_lib == "sky130A"} {
    read_liberty +/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
} elseif {$tech_lib == "asap7"} {
    read_liberty +/asap7/lib/asap7sc7p5t_AO_RVT_FF_nldm_211120.lib
} elseif {$tech_lib == "nangate45"} {
    read_liberty +/nangate45/lib/NangateOpenCellLibrary_typical.lib
}

# Set clock constraint
set_clock -period $clock_period $clock_port

# Timing analysis
set timing_report [tee -o $timing_file "sta -report-period $clock_period"]
log -stdout "Timing analysis written to: $timing_file"

#=============================================================================
# Power Analysis
#=============================================================================
log -stdout "Performing power analysis..."

# Power analysis (if liberty file available)
if {[info exists tech_lib]} {
    set power_report [tee -o "${output_dir}/${design_name}_power.txt" "power -lib +/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"]
    log -stdout "Power analysis written to: ${output_dir}/${design_name}_power.txt"
}

#=============================================================================
# Area Analysis
#=============================================================================
log -stdout "Performing area analysis..."

# Area analysis
set area_report [tee -o "${output_dir}/${design_name}_area.txt" "stat -area"]
log -stdout "Area analysis written to: ${output_dir}/${design_name}_area.txt"

#=============================================================================
# Design Rule Check
#=============================================================================
log -stdout "Performing design rule check..."

# DRC check
set drc_report [tee -o "${output_dir}/${design_name}_drc.txt" "check -assert"]
log -stdout "DRC report written to: ${output_dir}/${design_name}_drc.txt"

#=============================================================================
# Generate Documentation
#=============================================================================
log -stdout "Generating documentation..."

# Create synthesis report
set report_file "${output_dir}/${design_name}_synthesis_report.txt"
set fh [open $report_file w]
puts $fh "=== PDM to PCM Decimator Core Synthesis Report ==="
puts $fh "Date: [clock format [clock seconds]]"
puts $fh "Version: $script_version"
puts $fh "Design: $design_name"
puts $fh "Top Module: $top_module"
puts $fh "Technology: $tech_lib"
puts $fh "Cell Library: $cell_lib"
puts $fh "Clock Period: ${clock_period}ns"
puts $fh "Optimization Level: $opt_level"
puts $fh "ABC Optimization: $abc_opt"
puts $fh "Retiming: $retime"
puts $fh ""
puts $fh "Files Generated:"
puts $fh "  Netlist: $netlist_file"
puts $fh "  JSON: $json_file"
puts $fh "  Statistics: $stats_file"
puts $fh "  Timing: $timing_file"
puts $fh "  Power: ${output_dir}/${design_name}_power.txt"
puts $fh "  Area: ${output_dir}/${design_name}_area.txt"
puts $fh "  DRC: ${output_dir}/${design_name}_drc.txt"
puts $fh ""
puts $fh "Design Statistics:"
puts $fh $stats
close $fh

log -stdout "Synthesis report written to: $report_file"

#=============================================================================
# Generate Visualizations
#=============================================================================
log -stdout "Generating visualizations..."

# Show design hierarchy
show -prefix "${output_dir}/${design_name}_hierarchy"

# Show design graph
show -prefix "${output_dir}/${design_name}_graph"

# Show design with colors
show -prefix "${output_dir}/${design_name}_colored" -colors

log -stdout "Visualizations generated in: $output_dir"

#=============================================================================
# Completion
#=============================================================================
log -stdout "Synthesis completed successfully!"
log -stdout "Output directory: $output_dir"
log -stdout "Main netlist: $netlist_file"

#=============================================================================
# Utility Functions
#=============================================================================

# Function to change technology library
proc change_tech_lib {new_tech new_cell_lib} {
    global tech_lib cell_lib
    set tech_lib $new_tech
    set cell_lib $new_cell_lib
    log -stdout "Technology library changed to: $tech_lib ($cell_lib)"
}

# Function to set optimization level
proc set_opt_level {level} {
    global opt_level
    set opt_level $level
    log -stdout "Optimization level set to: $opt_level"
}

# Function to enable/disable ABC
proc set_abc_opt {enable} {
    global abc_opt
    set abc_opt $enable
    log -stdout "ABC optimization: [expr {$enable ? "enabled" : "disabled"}]"
}

# Function to enable/disable retiming
proc set_retiming {enable} {
    global retime
    set retime $enable
    log -stdout "Retiming: [expr {$enable ? "enabled" : "disabled"}]"
}

# Function to set clock period
proc set_clock_period {period} {
    global clock_period
    set clock_period $period
    log -stdout "Clock period set to: ${period}ns"
}

#=============================================================================
# Example Usage Commands
#=============================================================================
# These commands can be used interactively or in batch mode:
#
# # Change to different technology
# change_tech_lib asap7 asap7sc7p5t_AO_RVT
#
# # Set aggressive optimization
# set_opt_level 2
# set_abc_opt 1
# set_retiming 1
#
# # Set different clock period
# set_clock_period 5.0
#
# # Re-run synthesis with new settings
# source scripts/synth_yosys_enhanced.tcl
