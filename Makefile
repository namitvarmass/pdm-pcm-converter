#=============================================================================
# PDM to PCM Decimator - Makefile for Open-Source ASIC/FPGA Flows
#=============================================================================
# Description: Makefile for PDM to PCM decimator with multi-stage filter chain
#              Supports Verilator, Icarus, OpenLane, and Vivado flows
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Project configuration
PROJECT_NAME = pdm_pcm_decimator
VERSION = 1.2.0
DESIGN_NAME = pdm_pcm_decimator_core

# Directory structure
RTL_DIR = rtl
TB_DIR = tb/sv_tb
BUILD_DIR = build
REPORTS_DIR = reports
WAVEFORMS_DIR = waveforms

# Tool configurations
VERILATOR = verilator
ICARUS = iverilog
VVP = vvp
GTKWAVE = gtkwave
YOSYS = yosys
OPENROAD = openroad
VIVADO = vivado

# RTL files
RTL_FILES = $(RTL_DIR)/fir_coefficients.sv \
            $(RTL_DIR)/fifo_sync.sv \
            $(RTL_DIR)/pdm_pcm_decimator_core.sv

# Testbench files
TB_FILES = $(TB_DIR)/tb_pdm_pcm_decimator_core.sv

# Default target
.PHONY: all
all: help

#=============================================================================
# Simulation Targets
#=============================================================================

# Verilator simulation
.PHONY: sim-verilator
sim-verilator: $(BUILD_DIR)/verilator/$(DESIGN_NAME)
	@echo "Running Verilator simulation..."
	cd $(BUILD_DIR)/verilator && ./$(DESIGN_NAME)

$(BUILD_DIR)/verilator/$(DESIGN_NAME): $(RTL_FILES) $(TB_FILES)
	@mkdir -p $(BUILD_DIR)/verilator
	$(VERILATOR) --cc --exe --build \
		--top-module tb_pdm_pcm_decimator_core \
		--Mdir $(BUILD_DIR)/verilator \
		$(RTL_FILES) $(TB_FILES) \
		-o $(DESIGN_NAME)

# Icarus simulation
.PHONY: sim-icarus
sim-icarus: $(BUILD_DIR)/icarus/$(DESIGN_NAME).vvp
	@echo "Running Icarus simulation..."
	cd $(BUILD_DIR)/icarus && $(VVP) $(DESIGN_NAME).vvp

$(BUILD_DIR)/icarus/$(DESIGN_NAME).vvp: $(RTL_FILES) $(TB_FILES)
	@mkdir -p $(BUILD_DIR)/icarus
	$(ICARUS) -o $(BUILD_DIR)/icarus/$(DESIGN_NAME).vvp \
		-DSIMULATION \
		$(RTL_FILES) $(TB_FILES)

# Waveform viewing
.PHONY: waves
waves: $(BUILD_DIR)/icarus/$(DESIGN_NAME).vvp
	@echo "Generating waveforms..."
	cd $(BUILD_DIR)/icarus && $(VVP) $(DESIGN_NAME).vvp -vcd $(DESIGN_NAME).vcd
	$(GTKWAVE) $(BUILD_DIR)/icarus/$(DESIGN_NAME).vcd

#=============================================================================
# Synthesis Targets
#=============================================================================

# Yosys synthesis
.PHONY: synth-yosys
synth-yosys: $(BUILD_DIR)/yosys/$(DESIGN_NAME).v
	@echo "Yosys synthesis completed"

$(BUILD_DIR)/yosys/$(DESIGN_NAME).v: $(RTL_FILES)
	@mkdir -p $(BUILD_DIR)/yosys
	$(YOSYS) -c scripts/synth_yosys.tcl \
		-p "read_verilog $(RTL_FILES)" \
		-p "synth -top $(DESIGN_NAME) -flatten" \
		-p "write_verilog $(BUILD_DIR)/yosys/$(DESIGN_NAME).v" \
		-p "stat" \
		-p "show -prefix $(BUILD_DIR)/yosys/$(DESIGN_NAME)"

#=============================================================================
# OpenLane ASIC Flow
#=============================================================================

# OpenLane configuration
OPENLANE_DIR = flow/openlane
OPENLANE_CONFIG = $(OPENLANE_DIR)/config.json

.PHONY: openlane-init
openlane-init:
	@mkdir -p $(OPENLANE_DIR)
	@echo "Initializing OpenLane configuration..."
	@cp scripts/openlane_config.json $(OPENLANE_CONFIG)

.PHONY: openlane-synth
openlane-synth: openlane-init
	@echo "Running OpenLane synthesis..."
	cd $(OPENLANE_DIR) && make synth

.PHONY: openlane-floorplan
openlane-floorplan: openlane-synth
	@echo "Running OpenLane floorplanning..."
	cd $(OPENLANE_DIR) && make floorplan

.PHONY: openlane-place
openlane-place: openlane-floorplan
	@echo "Running OpenLane placement..."
	cd $(OPENLANE_DIR) && make place

.PHONY: openlane-route
openlane-route: openlane-place
	@echo "Running OpenLane routing..."
	cd $(OPENLANE_DIR) && make route

.PHONY: openlane-magic
openlane-magic: openlane-route
	@echo "Running OpenLane Magic DRC/LVS..."
	cd $(OPENLANE_DIR) && make magic_drc
	cd $(OPENLANE_DIR) && make magic_spice_export
	cd $(OPENLANE_DIR) && make netgen_lvs

# Complete OpenLane flow
.PHONY: openlane
openlane: openlane-route
	@echo "OpenLane flow completed successfully"

#=============================================================================
# Vivado FPGA Flow
#=============================================================================

# Vivado project
VIVADO_PROJECT = $(BUILD_DIR)/vivado/$(PROJECT_NAME).xpr

.PHONY: vivado-project
vivado-project: $(VIVADO_PROJECT)
	@echo "Vivado project created"

$(VIVADO_PROJECT):
	@mkdir -p $(BUILD_DIR)/vivado
	$(VIVADO) -mode batch -source scripts/create_vivado_project.tcl \
		-tclargs $(PROJECT_NAME) $(BUILD_DIR)/vivado $(RTL_DIR)

.PHONY: vivado-synth
vivado-synth: vivado-project
	@echo "Running Vivado synthesis..."
	$(VIVADO) -mode batch -source scripts/run_vivado_synth.tcl \
		-tclargs $(VIVADO_PROJECT)

.PHONY: vivado-impl
vivado-impl: vivado-synth
	@echo "Running Vivado implementation..."
	$(VIVADO) -mode batch -source scripts/run_vivado_impl.tcl \
		-tclargs $(VIVADO_PROJECT)

.PHONY: vivado-bitstream
vivado-bitstream: vivado-impl
	@echo "Generating Vivado bitstream..."
	$(VIVADO) -mode batch -source scripts/run_vivado_bitstream.tcl \
		-tclargs $(VIVADO_PROJECT)

# Complete Vivado flow
.PHONY: vivado
vivado: vivado-bitstream
	@echo "Vivado flow completed successfully"

#=============================================================================
# Verification Targets
#=============================================================================

# Code coverage
.PHONY: coverage
coverage: sim-verilator
	@echo "Generating coverage report..."
	@mkdir -p $(REPORTS_DIR)
	cd $(BUILD_DIR)/verilator && \
	$(VERILATOR) --coverage --cc --exe --build \
		--top-module tb_pdm_pcm_decimator_core \
		--Mdir coverage \
		$(RTL_FILES) $(TB_FILES) \
		-o $(DESIGN_NAME)_coverage

# Linting
.PHONY: lint
lint:
	@echo "Running Verilator linting..."
	$(VERILATOR) --lint-only \
		--top-module $(DESIGN_NAME) \
		$(RTL_FILES)

# Formal verification
.PHONY: formal
formal:
	@echo "Running formal verification..."
	$(YOSYS) -c scripts/formal_verify.tcl \
		-p "read_verilog $(RTL_FILES)" \
		-p "prep -top $(DESIGN_NAME)" \
		-p "write_smt2 $(BUILD_DIR)/formal/$(DESIGN_NAME).smt2"

#=============================================================================
# Documentation Targets
#=============================================================================

# Generate documentation
.PHONY: docs
docs:
	@echo "Generating documentation..."
	@mkdir -p $(REPORTS_DIR)
	$(YOSYS) -c scripts/generate_docs.tcl \
		-p "read_verilog $(RTL_FILES)" \
		-p "prep -top $(DESIGN_NAME)" \
		-p "write_json $(REPORTS_DIR)/$(DESIGN_NAME).json"

# Generate reports
.PHONY: reports
reports: docs
	@echo "Generating reports..."
	python3 scripts/generate_reports.py \
		--design $(DESIGN_NAME) \
		--version $(VERSION) \
		--reports-dir $(REPORTS_DIR)

#=============================================================================
# Utility Targets
#=============================================================================

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -rf $(REPORTS_DIR)
	rm -rf $(WAVEFORMS_DIR)
	rm -rf $(OPENLANE_DIR)/runs
	rm -rf $(OPENLANE_DIR)/results
	rm -rf $(OPENLANE_DIR)/reports

# Clean everything
.PHONY: distclean
distclean: clean
	@echo "Cleaning everything..."
	rm -rf .verilator
	rm -rf *.vcd
	rm -rf *.vvp
	rm -rf *.log

# Install dependencies
.PHONY: install-deps
install-deps:
	@echo "Installing dependencies..."
	@echo "Please install the following tools:"
	@echo "  - Verilator: https://verilator.org/guide/latest/install.html"
	@echo "  - Icarus Verilog: http://bleyer.org/icarus/"
	@echo "  - Yosys: https://github.com/YosysHQ/yosys"
	@echo "  - OpenLane: https://github.com/The-OpenROAD-Project/OpenLane"
	@echo "  - Vivado: https://www.xilinx.com/products/design-tools/vivado.html"

# Check tool availability
.PHONY: check-tools
check-tools:
	@echo "Checking tool availability..."
	@echo "Verilator: $(shell which $(VERILATOR) 2>/dev/null || echo 'NOT FOUND')"
	@echo "Icarus: $(shell which $(ICARUS) 2>/dev/null || echo 'NOT FOUND')"
	@echo "Yosys: $(shell which $(YOSYS) 2>/dev/null || echo 'NOT FOUND')"
	@echo "OpenRoad: $(shell which $(OPENROAD) 2>/dev/null || echo 'NOT FOUND')"
	@echo "Vivado: $(shell which $(VIVADO) 2>/dev/null || echo 'NOT FOUND')"

#=============================================================================
# Help
#=============================================================================

.PHONY: help
help:
	@echo "PDM to PCM Decimator - Makefile Help"
	@echo "===================================="
	@echo ""
	@echo "Simulation Targets:"
	@echo "  sim-verilator    - Run Verilator simulation"
	@echo "  sim-icarus       - Run Icarus simulation"
	@echo "  waves            - Generate and view waveforms"
	@echo ""
	@echo "Synthesis Targets:"
	@echo "  synth-yosys      - Run Yosys synthesis"
	@echo ""
	@echo "OpenLane ASIC Flow:"
	@echo "  openlane         - Complete OpenLane flow"
	@echo "  openlane-synth   - OpenLane synthesis only"
	@echo "  openlane-route   - OpenLane synthesis + place + route"
	@echo ""
	@echo "Vivado FPGA Flow:"
	@echo "  vivado           - Complete Vivado flow"
	@echo "  vivado-synth     - Vivado synthesis only"
	@echo "  vivado-bitstream - Vivado synthesis + impl + bitstream"
	@echo ""
	@echo "Verification Targets:"
	@echo "  coverage         - Generate code coverage"
	@echo "  lint             - Run Verilator linting"
	@echo "  formal           - Run formal verification"
	@echo ""
	@echo "Documentation Targets:"
	@echo "  docs             - Generate documentation"
	@echo "  reports          - Generate reports"
	@echo ""
	@echo "Utility Targets:"
	@echo "  clean            - Clean build artifacts"
	@echo "  distclean        - Clean everything"
	@echo "  install-deps     - Show dependency installation instructions"
	@echo "  check-tools      - Check tool availability"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make sim-verilator    # Run simulation"
	@echo "  make openlane         # Run ASIC flow"
	@echo "  make vivado           # Run FPGA flow"
	@echo "  make reports          # Generate documentation"

#=============================================================================
# Default target
#=============================================================================

.DEFAULT_GOAL := help 