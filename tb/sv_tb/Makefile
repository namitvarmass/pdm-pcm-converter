#=============================================================================
# SystemVerilog Testbench Makefile
#=============================================================================
# Description: Makefile for SystemVerilog testbench compilation and simulation
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Compiler and simulator settings
VLOG = vlog
VSIM = vsim
VLIB = vlib
VMAP = vmap

# Directories
RTL_DIR = ../../rtl
TB_DIR = .
WORK_DIR = work

# Source files
RTL_FILES = $(RTL_DIR)/pdm_pcm_decimator.sv
TB_FILES = $(TB_DIR)/tb_pdm_pcm_decimator.sv
TB_EXTENDED_FILES = $(TB_DIR)/tb_pdm_pcm_decimator_extended.sv

# Default target
all: compile simulate

# Create work library
$(WORK_DIR):
	$(VLIB) $(WORK_DIR)

# Compile RTL and testbench
compile: $(WORK_DIR)
	$(VLOG) -work $(WORK_DIR) $(RTL_FILES)
	$(VLOG) -work $(WORK_DIR) $(TB_FILES)

# Simulate testbench
simulate: compile
	$(VSIM) -c -do "run -all; quit" -work $(WORK_DIR) tb_pdm_pcm_decimator

# Simulate extended testbench
simulate_extended: compile
	$(VLOG) -work $(WORK_DIR) $(TB_EXTENDED_FILES)
	$(VSIM) -c -do "run -all; quit" -work $(WORK_DIR) tb_pdm_pcm_decimator_extended

# Interactive simulation
simulate_gui: compile
	$(VSIM) -gui -work $(WORK_DIR) tb_pdm_pcm_decimator

# Clean up
clean:
	rm -rf $(WORK_DIR)
	rm -f *.vcd
	rm -f transcript
	rm -f vsim.wlf

# Help
help:
	@echo "Available targets:"
	@echo "  all              - Compile and simulate (default)"
	@echo "  compile          - Compile RTL and testbench"
	@echo "  simulate         - Run simulation in command line mode"
	@echo "  simulate_extended - Run extended parameter range tests"
	@echo "  simulate_gui     - Run simulation in GUI mode"
	@echo "  clean            - Remove generated files"
	@echo "  help             - Show this help message"

.PHONY: all compile simulate simulate_extended simulate_gui clean help 