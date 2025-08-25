#=============================================================================
# Vivado Project Creation Script for PDM to PCM Decimator
#=============================================================================
# Description: TCL script to create and configure Vivado project
#              for PDM to PCM decimator with multi-stage filter chain
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Get command line arguments
set project_name [lindex $argv 0]
set project_dir [lindex $argv 1]
set rtl_dir [lindex $argv 2]

# Create project
create_project $project_name $project_dir -force

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "Verilog" -objects $obj
set_property -name "enable_optional_runs_sta" -value "0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_interface_inference_priority" -value "" -objects $obj
set_property -name "ip_repo_paths" -value "" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "arty-a7-35" -objects $obj
set_property -name "platform.default_output_type" -value "undefined" -objects $obj
set_property -name "platform.design_intent.datacenter" -value "false" -objects $obj
set_property -name "platform.design_intent.embedded" -value "false" -objects $obj
set_property -name "platform.design_intent.external_host" -value "false" -objects $obj
set_property -name "platform.design_intent.server_managed" -value "false" -objects $obj
set_property -name "platform.rom.debug_type" -value "0" -objects $obj
set_property -name "platform.rom.prom_type" -value "0" -objects $obj
set_property -name "platform.slrconstraintmode" -value "0" -objects $obj
set_property -name "preferred_sim_model" -value "rtl" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "sim.use_ip_compiled_libs" -value "1" -objects $obj
set_property -name "simulator.activehdl_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.activehdl_install_dir" -value "" -objects $obj
set_property -name "simulator.ies_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.ies_install_dir" -value "" -objects $obj
set_property -name "simulator.modelsim_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.modelsim_install_dir" -value "" -objects $obj
set_property -name "simulator.questa_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.questa_install_dir" -value "" -objects $obj
set_property -name "simulator.riviera_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.riviera_install_dir" -value "" -objects $obj
set_property -name "simulator.vcs_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.vcs_install_dir" -value "" -objects $obj
set_property -name "simulator.xcelium_gcc_install_dir" -value "" -objects $obj
set_property -name "simulator.xcelium_install_dir" -value "" -objects $obj
set_property -name "simulator.xsim_gcc_install_dir" -value "" -objects $obj
set_property -name "target_simulator" -value "XSim" -objects $obj
set_property -name "webtalk.activehdl_export_sim" -value "1" -objects $obj
set_property -name "webtalk.ies_export_sim" -value "1" -objects $obj
set_property -name "webtalk.modelsim_export_sim" -value "1" -objects $obj
set_property -name "webtalk.questa_export_sim" -value "1" -objects $obj
set_property -name "webtalk.riviera_export_sim" -value "1" -objects $obj
set_property -name "webtalk.vcs_export_sim" -value "1" -objects $obj
set_property -name "webtalk.xcelium_export_sim" -value "1" -objects $obj
set_property -name "webtalk.xsim_export_sim" -value "1" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]

# Add RTL files
add_files -norecurse -fileset $obj [list \
  "$rtl_dir/fir_coefficients.sv" \
  "$rtl_dir/fifo_sync.sv" \
  "$rtl_dir/pdm_pcm_decimator_core.sv" \
]

# Set 'sources_1' fileset file properties for remote files
set file "$rtl_dir/fir_coefficients.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$rtl_dir/fifo_sync.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

set file "$rtl_dir/pdm_pcm_decimator_core.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "pdm_pcm_decimator_core" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "verilog_version" -value "verilog_2001" -objects $obj
set_property -name "vhdl_version" -value "vhdl_2k" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add constraint files
add_files -norecurse -fileset $obj [list \
  "constraints/pdm_pcm_decimator.xdc" \
]

# Set 'constrs_1' fileset file properties for remote files
set file "constraints/pdm_pcm_decimator.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property -name "file_type" -value "XDC" -objects $file_obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]

# Add testbench files
add_files -norecurse -fileset $obj [list \
  "tb/sv_tb/tb_pdm_pcm_decimator_core.sv" \
]

# Set 'sim_1' fileset file properties for remote files
set file "tb/sv_tb/tb_pdm_pcm_decimator_core.sv"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property -name "file_type" -value "SystemVerilog" -objects $file_obj

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "32bit" -value "0" -objects $obj
set_property -name "generic" -value "" -objects $obj
set_property -name "hbs.configure_design_for_hier_access" -value "1" -objects $obj
set_property -name "include_dirs" -value "" -objects $obj
set_property -name "incremental" -value "1" -objects $obj
set_property -name "name" -value "sim_1" -objects $obj
set_property -name "nl.cell" -value "" -objects $obj
set_property -name "nl.incl_unisim_models" -value "0" -objects $obj
set_property -name "nl.process_corner" -value "slow" -objects $obj
set_property -name "nl.rename_top" -value "" -objects $obj
set_property -name "nl.sdf_anno" -value "1" -objects $obj
set_property -name "nl.write_all_overrides" -value "0" -objects $obj
set_property -name "simmodel_value_check" -value "1" -objects $obj
set_property -name "simulator_launch_mode" -value "off" -objects $obj
set_property -name "source_set" -value "sources_1" -objects $obj
set_property -name "systemc_include_dirs" -value "" -objects $obj
set_property -name "systemverilog_include_dirs" -value "" -objects $obj
set_property -name "top" -value "tb_pdm_pcm_decimator_core" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj
set_property -name "transport_int_delay" -value "0" -objects $obj
set_property -name "transport_path_delay" -value "0" -objects $obj
set_property -name "unifast" -value "0" -objects $obj
set_property -name "verilog_define" -value "" -objects $obj
set_property -name "verilog_uppercase" -value "0" -objects $obj
set_property -name "xelab.dll" -value "0" -objects $obj
set_property -name "xsim.compile.tcl.pre" -value "" -objects $obj
set_property -name "xsim.compile.xsc.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvhdl.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvhdl.relax" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.more_options" -value "" -objects $obj
set_property -name "xsim.compile.xvlog.nosort" -value "1" -objects $obj
set_property -name "xsim.compile.xvlog.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.coverage.celldefine" -value "0" -objects $obj
set_property -name "xsim.elaborate.coverage.dir" -value "" -objects $obj
set_property -name "xsim.elaborate.coverage.library" -value "0" -objects $obj
set_property -name "xsim.elaborate.coverage.verilog" -value "0" -objects $obj
set_property -name "xsim.elaborate.debug_level" -value "typical" -objects $obj
set_property -name "xsim.elaborate.link.c" -value "" -objects $obj
set_property -name "xsim.elaborate.link.sysc" -value "" -objects $obj
set_property -name "xsim.elaborate.load_glbl" -value "1" -objects $obj
set_property -name "xsim.elaborate.mt_level" -value "auto" -objects $obj
set_property -name "xsim.elaborate.rangecheck" -value "0" -objects $obj
set_property -name "xsim.elaborate.relax" -value "1" -objects $obj
set_property -name "xsim.elaborate.sdf_delay" -value "sdfmax" -objects $obj
set_property -name "xsim.elaborate.snapshot" -value "" -objects $obj
set_property -name "xsim.elaborate.xelab.more_options" -value "" -objects $obj
set_property -name "xsim.elaborate.xsc.more_options" -value "" -objects $obj
set_property -name "xsim.simulate.add_positional" -value "0" -objects $obj
set_property -name "xsim.simulate.custom_tcl" -value "" -objects $obj
set_property -name "xsim.simulate.log_all_signals" -value "0" -objects $obj
set_property -name "xsim.simulate.no_quit" -value "0" -objects $obj
set_property -name "xsim.simulate.runtime" -value "1000ns" -objects $obj
set_property -name "xsim.simulate.saif_scope" -value "" -objects $obj
set_property -name "xsim.simulate.tcl.post" -value "" -objects $obj
set_property -name "xsim.simulate.wdb" -value "1" -objects $obj
set_property -name "xsim.simulate.xsim.more_options" -value "" -objects $obj

# Set current fileset
current_fileset -simset [get_filesets sim_1]

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -flow {Vivado Synthesis 2023}
} else {
  set_property flow "Vivado Synthesis 2023" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Synthesis Default Reports} $obj
set_property set_report_strategy_name 0 $obj

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -flow {Vivado Implementation 2023} -strategy "Vivado Implementation Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2023" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property set_report_strategy_name 1 $obj
set_property report_strategy {Vivado Implementation Default Reports} $obj
set_property set_report_strategy_name 0 $obj

# Set the current synth run
current_run -synthesis [get_runs synth_1]

# Set the current impl run
current_run -implementation [get_runs impl_1]

puts "Vivado project '$project_name' created successfully in '$project_dir'"
puts "Top module: pdm_pcm_decimator_core"
puts "RTL files added from: $rtl_dir"
puts "Constraints added from: constraints/"
puts "Testbench added from: tb/sv_tb/"
