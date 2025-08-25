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

# Enhanced Yosys synthesis
.PHONY: synth-yosys-enhanced
synth-yosys-enhanced: $(BUILD_DIR)/yosys
	@echo "Running enhanced Yosys synthesis..."
	cd $(BUILD_DIR)/yosys && $(YOSYS) -s ../../scripts/synth_yosys_enhanced.tcl
	@echo "Enhanced Yosys synthesis completed"

# Yosys interactive sessions
.PHONY: synth-yosys-interactive
synth-yosys-interactive: $(BUILD_DIR)/yosys
	@echo "Starting Yosys interactive session..."
	cd $(BUILD_DIR)/yosys && $(YOSYS) -s ../../scripts/synth_yosys.tcl

.PHONY: synth-yosys-enhanced-interactive
synth-yosys-enhanced-interactive: $(BUILD_DIR)/yosys
	@echo "Starting enhanced Yosys interactive session..."
	cd $(BUILD_DIR)/yosys && $(YOSYS) -s ../../scripts/synth_yosys_enhanced.tcl

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

#=============================================================================
# Cocotb Testbench Targets
#=============================================================================

# Cocotb testbench directory
COCOTB_DIR = tb/cocotb

# Cocotb simulation
.PHONY: cocotb-sim
cocotb-sim:
	@echo "Running cocotb simulation..."
	cd $(COCOTB_DIR) && $(MAKE) sim

# Cocotb regression testing
.PHONY: cocotb-regression
cocotb-regression:
	@echo "Running cocotb regression test suite..."
	cd $(COCOTB_DIR) && $(MAKE) regression

# Cocotb quick test
.PHONY: cocotb-quick
cocotb-quick:
	@echo "Running cocotb quick test suite..."
	cd $(COCOTB_DIR) && $(MAKE) quick-test

# Cocotb individual tests
.PHONY: cocotb-test-reset
cocotb-test-reset:
	cd $(COCOTB_DIR) && $(MAKE) test-reset

.PHONY: cocotb-test-zeros
cocotb-test-zeros:
	cd $(COCOTB_DIR) && $(MAKE) test-zeros

.PHONY: cocotb-test-ones
cocotb-test-ones:
	cd $(COCOTB_DIR) && $(MAKE) test-ones

.PHONY: cocotb-test-random
cocotb-test-random:
	cd $(COCOTB_DIR) && $(MAKE) test-random

.PHONY: cocotb-test-sine
cocotb-test-sine:
	cd $(COCOTB_DIR) && $(MAKE) test-sine

.PHONY: cocotb-test-throughput
cocotb-test-throughput:
	cd $(COCOTB_DIR) && $(MAKE) test-throughput

# Cocotb coverage
.PHONY: cocotb-coverage
cocotb-coverage:
	@echo "Running cocotb with coverage..."
	cd $(COCOTB_DIR) && $(MAKE) coverage

.PHONY: cocotb-coverage-html
cocotb-coverage-html:
	@echo "Generating cocotb HTML coverage report..."
	cd $(COCOTB_DIR) && $(MAKE) coverage-html

# Cocotb waveforms
.PHONY: cocotb-waves
cocotb-waves:
	@echo "Running cocotb with waveform generation..."
	cd $(COCOTB_DIR) && $(MAKE) waves

.PHONY: cocotb-waves-gtkwave
cocotb-waves-gtkwave:
	@echo "Opening cocotb waveforms in GTKWave..."
	cd $(COCOTB_DIR) && $(MAKE) waves-gtkwave

# Cocotb test report
.PHONY: cocotb-report
cocotb-report:
	@echo "Generating cocotb test report..."
	cd $(COCOTB_DIR) && $(MAKE) test-report

# Cocotb tool-specific targets
.PHONY: cocotb-sim-icarus
cocotb-sim-icarus:
	cd $(COCOTB_DIR) && $(MAKE) sim-icarus

.PHONY: cocotb-sim-verilator
cocotb-sim-verilator:
	cd $(COCOTB_DIR) && $(MAKE) sim-verilator

.PHONY: cocotb-sim-questa
cocotb-sim-questa:
	cd $(COCOTB_DIR) && $(MAKE) sim-questa

.PHONY: cocotb-sim-modelsim
cocotb-sim-modelsim:
	cd $(COCOTB_DIR) && $(MAKE) sim-modelsim

.PHONY: cocotb-sim-vcs
cocotb-sim-vcs:
	cd $(COCOTB_DIR) && $(MAKE) sim-vcs

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

# Setup cocotb environment
.PHONY: setup-cocotb
setup-cocotb:
	@echo "Setting up cocotb environment..."
	@if [ -f "scripts/setup_cocotb.sh" ]; then \
		bash scripts/setup_cocotb.sh --dev; \
	else \
		echo "Error: setup_cocotb.sh not found"; \
		exit 1; \
	fi

# Setup cocotb with virtual environment
.PHONY: setup-cocotb-venv
setup-cocotb-venv:
	@echo "Setting up cocotb environment with virtual environment..."
	@if [ -f "scripts/setup_cocotb.sh" ]; then \
		bash scripts/setup_cocotb.sh --venv --dev; \
	else \
		echo "Error: setup_cocotb.sh not found"; \
		exit 1; \
	fi

# Setup cocotb with test
.PHONY: setup-cocotb-test
setup-cocotb-test:
	@echo "Setting up cocotb environment and running test..."
	@if [ -f "scripts/setup_cocotb.sh" ]; then \
		bash scripts/setup_cocotb.sh --dev --test; \
	else \
		echo "Error: setup_cocotb.sh not found"; \
		exit 1; \
	fi

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
	@echo "Cocotb Testbench Targets:"
	@echo "  cocotb-sim       - Run cocotb simulation"
	@echo "  cocotb-regression- Run full cocotb regression suite"
	@echo "  cocotb-quick     - Run cocotb quick test suite"
	@echo "  cocotb-coverage  - Run cocotb with coverage"
	@echo "  cocotb-waves     - Run cocotb with waveforms"
	@echo "  cocotb-report    - Generate cocotb test report"
	@echo ""
	@echo "Cocotb Individual Tests:"
	@echo "  cocotb-test-reset     - Test reset sequence"
	@echo "  cocotb-test-zeros     - Test all zeros pattern"
	@echo "  cocotb-test-ones      - Test all ones pattern"
	@echo "  cocotb-test-random    - Test random pattern"
	@echo "  cocotb-test-sine      - Test sine wave response"
	@echo "  cocotb-test-throughput- Test performance throughput"
	@echo ""
	@echo "Cocotb Tool-Specific:"
	@echo "  cocotb-sim-icarus     - Run cocotb with Icarus"
	@echo "  cocotb-sim-verilator  - Run cocotb with Verilator"
	@echo "  cocotb-sim-questa     - Run cocotb with Questa"
	@echo "  cocotb-sim-modelsim   - Run cocotb with ModelSim"
	@echo "  cocotb-sim-vcs        - Run cocotb with VCS"
	@echo ""
	@echo "Synthesis Targets:"
	@echo "  synth-yosys              - Basic Yosys synthesis"
	@echo "  synth-yosys-enhanced     - Enhanced Yosys synthesis"
	@echo "  synth-yosys-interactive  - Interactive Yosys session"
	@echo "  synth-yosys-enhanced-interactive - Interactive enhanced Yosys"
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
	@echo "Setup Targets:"
	@echo "  setup-cocotb     - Setup cocotb environment"
	@echo "  setup-cocotb-venv- Setup cocotb with virtual environment"
	@echo "  setup-cocotb-test- Setup cocotb and run test"
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