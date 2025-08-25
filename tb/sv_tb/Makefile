#=============================================================================
# PDM to PCM Decimator - SystemVerilog Testbench Makefile
#=============================================================================
# Description: Makefile for SystemVerilog and Cocotb testbenches
#              Supports multiple simulators and comprehensive test scenarios
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Project configuration
PROJECT_NAME = pdm_pcm_decimator
VERSION = 1.3.0
DESIGN_NAME = pdm_pcm_decimator_core

# Directory structure
RTL_DIR = ../../rtl
TB_DIR = .
COCOTB_TB_DIR = ../cocotb
BUILD_DIR = build
REPORTS_DIR = reports
WAVEFORMS_DIR = waveforms
COVERAGE_DIR = coverage

# Compiler and simulator settings
VLOG = vlog
VSIM = vsim
VLIB = vlib
VMAP = vmap

# Cocotb configuration
COCOTB_REDUCED_LOG_FMT = True
COCOTB_ANSI_OUTPUT = True
COCOTB_LOG_LEVEL = INFO
SIM ?= icarus

# RTL files
RTL_FILES = $(RTL_DIR)/fir_coefficients.sv \
            $(RTL_DIR)/fifo_sync.sv \
            $(RTL_DIR)/pdm_pcm_decimator_core.sv

# SystemVerilog testbench files
SV_TB_FILES = $(TB_DIR)/tb_pdm_pcm_decimator_core.sv \
              $(TB_DIR)/tb_pdm_pcm_decimator_extended.sv

# Cocotb testbench files
COCOTB_TB_FILES = $(COCOTB_TB_DIR)/test_pdm_pcm_decimator_core.py

# Work directory
WORK_DIR = work

# Default target
all: help

# Help target
help:
	@echo "============================================================================="
	@echo "PDM to PCM Decimator - SystemVerilog & Cocotb Testbench Makefile"
	@echo "============================================================================="
	@echo "Available targets:"
	@echo ""
	@echo "SystemVerilog Testbenches:"
	@echo "  sv_compile          - Compile SystemVerilog RTL and testbench"
	@echo "  sv_simulate         - Run SystemVerilog simulation"
	@echo "  sv_simulate_gui     - Run SystemVerilog simulation in GUI mode"
	@echo "  sv_simulate_extended - Run extended parameter range tests"
	@echo ""
	@echo "Cocotb Testbenches:"
	@echo "  cocotb_test         - Run all cocotb tests"
	@echo "  cocotb_test_basic   - Run basic functionality tests"
	@echo "  cocotb_test_patterns - Run pattern-based tests"
	@echo "  cocotb_test_performance - Run performance tests"
	@echo "  cocotb_test_errors  - Run error condition tests"
	@echo "  cocotb_test_coverage - Run tests with coverage"
	@echo "  cocotb_test_waveforms - Run tests with waveform generation"
	@echo "  cocotb_test_individual - Run individual test (TEST_NAME=<test_name>)"
	@echo ""
	@echo "Combined Targets:"
	@echo "  test_all            - Run all test types"
	@echo "  test_regression     - Run full regression test suite"
	@echo "  test_coverage       - Run all tests with coverage"
	@echo "  test_waveforms      - Run all tests with waveforms"
	@echo ""
	@echo "Utility Targets:"
	@echo "  clean               - Clean all build artifacts"
	@echo "  clean_sv            - Clean SystemVerilog artifacts"
	@echo "  clean_cocotb        - Clean cocotb artifacts"
	@echo "  report              - Generate test report"
	@echo "  coverage_report     - Generate coverage report"
	@echo "  waveform_view       - View waveforms"
	@echo ""
	@echo "Environment variables:"
	@echo "  SIM                 - Simulator for cocotb (icarus, verilator, modelsim)"
	@echo "  TEST_NAME           - Specific test to run"
	@echo "  COVERAGE_TYPE       - Coverage type (all, line, branch, expression)"
	@echo "  COCOTB_LOG_LEVEL    - Log level (DEBUG, INFO, WARNING, ERROR)"
	@echo ""
	@echo "Examples:"
	@echo "  make sv_simulate                    # Run SystemVerilog simulation"
	@echo "  make cocotb_test                    # Run all cocotb tests"
	@echo "  make test_all                       # Run all test types"
	@echo "  make cocotb_test_individual TEST_NAME=test_all_zeros_pattern"
	@echo "  make test_coverage COVERAGE_TYPE=all"
	@echo "============================================================================="

# Create directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(REPORTS_DIR):
	mkdir -p $(REPORTS_DIR)

$(WAVEFORMS_DIR):
	mkdir -p $(WAVEFORMS_DIR)

$(COVERAGE_DIR):
	mkdir -p $(COVERAGE_DIR)

#=============================================================================
# SystemVerilog Testbench Targets
#=============================================================================

# Create work library
$(WORK_DIR):
	$(VLIB) $(WORK_DIR)

# Compile SystemVerilog RTL and testbench
sv_compile: $(WORK_DIR) $(BUILD_DIR)
	@echo "Compiling SystemVerilog RTL and testbench..."
	$(VLOG) -work $(WORK_DIR) $(RTL_FILES)
	$(VLOG) -work $(WORK_DIR) $(SV_TB_FILES)
	@echo "SystemVerilog compilation completed!"

# Run SystemVerilog simulation
sv_simulate: sv_compile
	@echo "Running SystemVerilog simulation..."
	$(VSIM) -c -do "run -all; quit" -work $(WORK_DIR) tb_pdm_pcm_decimator_core
	@echo "SystemVerilog simulation completed!"

# Run SystemVerilog simulation in GUI mode
sv_simulate_gui: sv_compile
	@echo "Running SystemVerilog simulation in GUI mode..."
	$(VSIM) -gui -work $(WORK_DIR) tb_pdm_pcm_decimator_core

# Run extended SystemVerilog testbench
sv_simulate_extended: sv_compile
	@echo "Running extended SystemVerilog testbench..."
	$(VSIM) -c -do "run -all; quit" -work $(WORK_DIR) tb_pdm_pcm_decimator_extended
	@echo "Extended SystemVerilog simulation completed!"

#=============================================================================
# Cocotb Testbench Targets
#=============================================================================

# Run all cocotb tests
cocotb_test: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running all cocotb tests..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test
	@echo "All cocotb tests completed!"

# Run basic cocotb tests
cocotb_test_basic: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running basic cocotb tests..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test_basic
	@echo "Basic cocotb tests completed!"

# Run pattern-based cocotb tests
cocotb_test_patterns: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running pattern-based cocotb tests..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test_patterns
	@echo "Pattern-based cocotb tests completed!"

# Run performance cocotb tests
cocotb_test_performance: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running performance cocotb tests..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test_performance
	@echo "Performance cocotb tests completed!"

# Run error condition cocotb tests
cocotb_test_errors: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running error condition cocotb tests..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test_errors
	@echo "Error condition cocotb tests completed!"

# Run cocotb tests with coverage
cocotb_test_coverage: $(BUILD_DIR) $(REPORTS_DIR) $(COVERAGE_DIR)
	@echo "Running cocotb tests with coverage..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test_coverage
	@echo "Cocotb coverage tests completed!"

# Run cocotb tests with waveforms
cocotb_test_waveforms: $(BUILD_DIR) $(REPORTS_DIR) $(WAVEFORMS_DIR)
	@echo "Running cocotb tests with waveforms..."
	cd $(COCOTB_TB_DIR) && $(MAKE) test_waveforms
	@echo "Cocotb waveform tests completed!"

# Run individual cocotb test
cocotb_test_individual: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running individual cocotb test: $(TEST_NAME)"
	cd $(COCOTB_TB_DIR) && $(MAKE) test_individual TEST_NAME=$(TEST_NAME)
	@echo "Individual cocotb test completed!"

#=============================================================================
# Combined Test Targets
#=============================================================================

# Run all test types
test_all: sv_simulate cocotb_test
	@echo "All test types completed!"

# Run full regression test suite
test_regression: sv_simulate sv_simulate_extended cocotb_test cocotb_test_coverage
	@echo "Full regression test suite completed!"

# Run all tests with coverage
test_coverage: sv_simulate cocotb_test_coverage
	@echo "All tests with coverage completed!"

# Run all tests with waveforms
test_waveforms: sv_simulate_gui cocotb_test_waveforms
	@echo "All tests with waveforms completed!"

#=============================================================================
# Utility Targets
#=============================================================================

# Clean all build artifacts
clean: clean_sv clean_cocotb
	@echo "All build artifacts cleaned!"

# Clean SystemVerilog artifacts
clean_sv:
	@echo "Cleaning SystemVerilog artifacts..."
	rm -rf $(WORK_DIR)
	rm -f *.vcd
	rm -f transcript
	rm -f vsim.wlf
	rm -f *.log
	@echo "SystemVerilog artifacts cleaned!"

# Clean cocotb artifacts
clean_cocotb:
	@echo "Cleaning cocotb artifacts..."
	cd $(COCOTB_TB_DIR) && $(MAKE) clean
	@echo "Cocotb artifacts cleaned!"

# Generate test report
report: $(REPORTS_DIR)
	@echo "Generating test report..."
	@echo "=============================================================================" > $(REPORTS_DIR)/test_report.txt
	@echo "PDM to PCM Decimator - Test Report" >> $(REPORTS_DIR)/test_report.txt
	@echo "=============================================================================" >> $(REPORTS_DIR)/test_report.txt
	@echo "Project: $(PROJECT_NAME)" >> $(REPORTS_DIR)/test_report.txt
	@echo "Version: $(VERSION)" >> $(REPORTS_DIR)/test_report.txt
	@echo "Design: $(DESIGN_NAME)" >> $(REPORTS_DIR)/test_report.txt
	@echo "Date: $(shell date)" >> $(REPORTS_DIR)/test_report.txt
	@echo "" >> $(REPORTS_DIR)/test_report.txt
	@echo "Test Results:" >> $(REPORTS_DIR)/test_report.txt
	@if [ -f $(WORK_DIR)/transcript ]; then \
		echo "  SystemVerilog Tests: ✓" >> $(REPORTS_DIR)/test_report.txt; \
	else \
		echo "  SystemVerilog Tests: ✗ (not run)" >> $(REPORTS_DIR)/test_report.txt; \
	fi
	@if [ -f $(COCOTB_TB_DIR)/reports/basic_tests.xml ]; then \
		echo "  Cocotb Tests: ✓" >> $(REPORTS_DIR)/test_report.txt; \
	else \
		echo "  Cocotb Tests: ✗ (not run)" >> $(REPORTS_DIR)/test_report.txt; \
	fi
	@echo "" >> $(REPORTS_DIR)/test_report.txt
	@echo "Reports available in: $(REPORTS_DIR)/" >> $(REPORTS_DIR)/test_report.txt
	@echo "=============================================================================" >> $(REPORTS_DIR)/test_report.txt
	@echo "Test report generated: $(REPORTS_DIR)/test_report.txt"

# Generate coverage report
coverage_report: $(COVERAGE_DIR)
	@echo "Generating coverage report..."
	cd $(COCOTB_TB_DIR) && $(MAKE) coverage_report
	@echo "Coverage report generated!"

# View waveforms
waveform_view: $(WAVEFORMS_DIR)
	@echo "Opening waveform viewer..."
	cd $(COCOTB_TB_DIR) && $(MAKE) waveform_view

# Lint RTL
lint:
	@echo "Running RTL linting..."
	@if command -v verilator >/dev/null 2>&1; then \
		verilator --lint-only $(RTL_FILES) --top-module $(DESIGN_NAME); \
	else \
		echo "Verilator not found. Skipping linting."; \
	fi

# Install dependencies
install_deps:
	@echo "Installing dependencies..."
	@echo "Installing Python dependencies for cocotb..."
	pip install cocotb pytest pytest-cov coverage
	@echo "Installing simulator dependencies..."
	@if [ "$(SIM)" = "icarus" ]; then \
		echo "Icarus Verilog should be installed via package manager"; \
	elif [ "$(SIM)" = "verilator" ]; then \
		echo "Verilator should be installed via package manager"; \
	fi
	@echo "Dependencies installation completed!"

# CI/CD pipeline
ci: clean test_regression report
	@echo "CI/CD pipeline completed!"

# Development quick test
dev: sv_simulate cocotb_test_basic
	@echo "Development quick test completed!"

# Performance benchmark
benchmark: cocotb_test_performance
	@echo "Performance benchmark completed!"

#=============================================================================
# Phony Targets
#=============================================================================

.PHONY: all help clean clean_sv clean_cocotb \
        sv_compile sv_simulate sv_simulate_gui sv_simulate_extended \
        cocotb_test cocotb_test_basic cocotb_test_patterns cocotb_test_performance \
        cocotb_test_errors cocotb_test_coverage cocotb_test_waveforms cocotb_test_individual \
        test_all test_regression test_coverage test_waveforms \
        report coverage_report waveform_view lint install_deps ci dev benchmark 