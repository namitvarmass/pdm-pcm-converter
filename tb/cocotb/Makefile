#=============================================================================
# PDM to PCM Decimator - Cocotb Testbench Makefile
#=============================================================================
# Description: Makefile for cocotb testbenches with comprehensive test cases
#              Supports multiple simulators and test configurations
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
BUILD_DIR = build
REPORTS_DIR = reports
WAVEFORMS_DIR = waveforms
COVERAGE_DIR = coverage

# Cocotb configuration
COCOTB_REDUCED_LOG_FMT = True
COCOTB_ANSI_OUTPUT = True
COCOTB_LOG_LEVEL = INFO

# Simulator configurations
SIM ?= icarus
VERILOG_SOURCES = $(RTL_DIR)/fir_coefficients.sv \
                  $(RTL_DIR)/fifo_sync.sv \
                  $(RTL_DIR)/pdm_pcm_decimator_core.sv

# Test configurations
TEST_NAME ?= test_comprehensive_validation
TEST_MODULE = test_pdm_pcm_decimator_core
TOPLEVEL = pdm_pcm_decimator_core
TOPLEVEL_LANG = verilog

# Coverage configuration
COVERAGE_TYPE = all
COVERAGE_OPTIONS = --coverage $(COVERAGE_TYPE)

# Waveform configuration
WAVEFORM_OPTIONS = --wave=waves.vcd

# Performance configuration
PERFORMANCE_OPTIONS = --profile

# Default target
all: help

# Help target
help:
	@echo "============================================================================="
	@echo "PDM to PCM Decimator - Cocotb Testbench Makefile"
	@echo "============================================================================="
	@echo "Available targets:"
	@echo "  clean              - Clean build artifacts"
	@echo "  test               - Run all tests"
	@echo "  test_basic         - Run basic functionality tests"
	@echo "  test_patterns      - Run pattern-based tests"
	@echo "  test_performance   - Run performance tests"
	@echo "  test_coverage      - Run tests with coverage"
	@echo "  test_waveforms     - Run tests with waveform generation"
	@echo "  test_individual    - Run individual test (TEST_NAME=<test_name>)"
	@echo "  coverage_report    - Generate coverage report"
	@echo "  waveform_view      - View waveforms"
	@echo "  report             - Generate test report"
	@echo ""
	@echo "Environment variables:"
	@echo "  SIM                - Simulator (icarus, verilator, modelsim, xcelium)"
	@echo "  TEST_NAME          - Specific test to run"
	@echo "  COVERAGE_TYPE      - Coverage type (all, line, branch, expression)"
	@echo "  COCOTB_LOG_LEVEL   - Log level (DEBUG, INFO, WARNING, ERROR)"
	@echo ""
	@echo "Examples:"
	@echo "  make test                          # Run all tests"
	@echo "  make test_individual TEST_NAME=test_all_zeros_pattern"
	@echo "  make test_coverage COVERAGE_TYPE=all"
	@echo "  make test_waveforms"
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

# Clean target
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(REPORTS_DIR)
	rm -rf $(WAVEFORMS_DIR)
	rm -rf $(COVERAGE_DIR)
	rm -f *.vcd
	rm -f *.fst
	rm -f *.log
	rm -f results.xml
	rm -f coverage.xml
	rm -f *.pyc
	rm -rf __pycache__
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Basic test target
test_basic: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running basic functionality tests..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="test_reset_sequence|test_all_zeros_pattern|test_all_ones_pattern|test_alternating_pattern" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/basic_tests.xml

# Pattern tests target
test_patterns: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running pattern-based tests..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="test_random_patterns|test_parameter_sweep|test_filter_response" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/pattern_tests.xml

# Performance tests target
test_performance: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running performance tests..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="test_performance_throughput|test_concurrent_operations" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/performance_tests.xml

# Error condition tests target
test_errors: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running error condition tests..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="test_backpressure|test_overflow_condition|test_underflow_condition|test_error_conditions" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/error_tests.xml

# State machine tests target
test_state_machine: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running state machine tests..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="test_state_machine_coverage" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/state_machine_tests.xml

# Coverage tests target
test_coverage: $(BUILD_DIR) $(REPORTS_DIR) $(COVERAGE_DIR)
	@echo "Running tests with coverage..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	COVERAGE=$(COVERAGE_TYPE) \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/coverage_tests.xml \
	--cov=$(TB_DIR) --cov-report=html:$(COVERAGE_DIR) --cov-report=xml:$(COVERAGE_DIR)/coverage.xml

# Waveform tests target
test_waveforms: $(BUILD_DIR) $(REPORTS_DIR) $(WAVEFORMS_DIR)
	@echo "Running tests with waveform generation..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	WAVES=1 \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/waveform_tests.xml
	@if [ -f waves.vcd ]; then mv waves.vcd $(WAVEFORMS_DIR)/; fi

# Individual test target
test_individual: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running individual test: $(TEST_NAME)"
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="$(TEST_NAME)" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py::$(TEST_NAME) -v \
	--tb=short --junitxml=$(REPORTS_DIR)/individual_test.xml

# All tests target
test: test_basic test_patterns test_performance test_errors test_state_machine
	@echo "All tests completed!"

# Comprehensive test target
test_comprehensive: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running comprehensive validation test..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	TEST_NAME="test_comprehensive_validation" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=short --junitxml=$(REPORTS_DIR)/comprehensive_test.xml

# Coverage report target
coverage_report: $(COVERAGE_DIR)
	@if [ -f $(COVERAGE_DIR)/coverage.xml ]; then \
		echo "Generating coverage report..."; \
		coverage report --show-missing; \
		coverage html -d $(COVERAGE_DIR)/html; \
		echo "Coverage report generated in $(COVERAGE_DIR)/html/"; \
	else \
		echo "No coverage data found. Run 'make test_coverage' first."; \
	fi

# Waveform view target
waveform_view: $(WAVEFORMS_DIR)
	@if [ -f $(WAVEFORMS_DIR)/waves.vcd ]; then \
		echo "Opening waveform viewer..."; \
		gtkwave $(WAVEFORMS_DIR)/waves.vcd; \
	else \
		echo "No waveform file found. Run 'make test_waveforms' first."; \
	fi

# Test report target
report: $(REPORTS_DIR)
	@echo "============================================================================="
	@echo "PDM to PCM Decimator - Test Report"
	@echo "============================================================================="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Design: $(DESIGN_NAME)"
	@echo "Simulator: $(SIM)"
	@echo "Date: $(shell date)"
	@echo ""
	@if [ -f $(REPORTS_DIR)/basic_tests.xml ]; then \
		echo "Basic Tests: ✓"; \
	else \
		echo "Basic Tests: ✗ (not run)"; \
	fi
	@if [ -f $(REPORTS_DIR)/pattern_tests.xml ]; then \
		echo "Pattern Tests: ✓"; \
	else \
		echo "Pattern Tests: ✗ (not run)"; \
	fi
	@if [ -f $(REPORTS_DIR)/performance_tests.xml ]; then \
		echo "Performance Tests: ✓"; \
	else \
		echo "Performance Tests: ✗ (not run)"; \
	fi
	@if [ -f $(REPORTS_DIR)/error_tests.xml ]; then \
		echo "Error Tests: ✓"; \
	else \
		echo "Error Tests: ✗ (not run)"; \
	fi
	@if [ -f $(REPORTS_DIR)/state_machine_tests.xml ]; then \
		echo "State Machine Tests: ✓"; \
	else \
		echo "State Machine Tests: ✗ (not run)"; \
	fi
	@if [ -f $(REPORTS_DIR)/comprehensive_test.xml ]; then \
		echo "Comprehensive Test: ✓"; \
	else \
		echo "Comprehensive Test: ✗ (not run)"; \
	fi
	@echo ""
	@echo "Reports available in: $(REPORTS_DIR)/"
	@echo "Waveforms available in: $(WAVEFORMS_DIR)/"
	@echo "Coverage available in: $(COVERAGE_DIR)/"
	@echo "============================================================================="

# Lint target
lint:
	@echo "Running linting checks..."
	@if command -v verilator >/dev/null 2>&1; then \
		verilator --lint-only $(VERILOG_SOURCES) --top-module $(TOPLEVEL); \
	else \
		echo "Verilator not found. Skipping linting."; \
	fi

# Format target
format:
	@echo "Formatting Python files..."
	@if command -v black >/dev/null 2>&1; then \
		black $(TB_DIR)/*.py; \
	else \
		echo "Black not found. Install with: pip install black"; \
	fi

# Install dependencies target
install_deps:
	@echo "Installing Python dependencies..."
	pip install cocotb pytest pytest-cov coverage
	@echo "Installing simulator dependencies..."
	@if [ "$(SIM)" = "icarus" ]; then \
		echo "Icarus Verilog should be installed via package manager"; \
	elif [ "$(SIM)" = "verilator" ]; then \
		echo "Verilator should be installed via package manager"; \
	fi

# CI/CD target
ci: clean test_coverage test_waveforms report
	@echo "CI/CD pipeline completed!"

# Development target
dev: clean test_basic test_waveforms
	@echo "Development test completed!"

# Performance benchmark target
benchmark: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running performance benchmarks..."
	SIM=$(SIM) MODULE=$(TEST_MODULE) TOPLEVEL=$(TOPLEVEL) \
	TOPLEVEL_LANG=$(TOPLEVEL_LANG) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	COCOTB_REDUCED_LOG_FMT=$(COCOTB_REDUCED_LOG_FMT) \
	COCOTB_ANSI_OUTPUT=$(COCOTB_ANSI_OUTPUT) \
	COCOTB_LOG_LEVEL=WARNING \
	TEST_NAME="test_performance_throughput" \
	python -m pytest $(TB_DIR)/test_pdm_pcm_decimator_core.py -v \
	--tb=no --junitxml=$(REPORTS_DIR)/benchmark.xml

# Regression test target
regression: clean test test_coverage test_waveforms report
	@echo "Regression test suite completed!"

# Documentation target
docs:
	@echo "Generating test documentation..."
	@echo "# PDM to PCM Decimator - Cocotb Testbench Documentation" > $(TB_DIR)/README.md
	@echo "" >> $(TB_DIR)/README.md
	@echo "## Overview" >> $(TB_DIR)/README.md
	@echo "This directory contains comprehensive cocotb testbenches for the PDM to PCM decimator core." >> $(TB_DIR)/README.md
	@echo "" >> $(TB_DIR)/README.md
	@echo "## Test Categories" >> $(TB_DIR)/README.md
	@echo "- Basic functionality tests" >> $(TB_DIR)/README.md
	@echo "- Pattern-based tests" >> $(TB_DIR)/README.md
	@echo "- Performance tests" >> $(TB_DIR)/README.md
	@echo "- Error condition tests" >> $(TB_DIR)/README.md
	@echo "- State machine tests" >> $(TB_DIR)/README.md
	@echo "- Comprehensive validation" >> $(TB_DIR)/README.md
	@echo "" >> $(TB_DIR)/README.md
	@echo "## Usage" >> $(TB_DIR)/README.md
	@echo "See the Makefile help for available targets." >> $(TB_DIR)/README.md
	@echo "Documentation generated in $(TB_DIR)/README.md"

# Phony targets
.PHONY: all help clean test test_basic test_patterns test_performance test_errors \
        test_state_machine test_coverage test_waveforms test_individual \
        test_comprehensive coverage_report waveform_view report lint format \
        install_deps ci dev benchmark regression docs 