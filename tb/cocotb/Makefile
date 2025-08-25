#=============================================================================
# PDM to PCM Decimator Core - Cocotb Test Makefile
#=============================================================================
# Description: Makefile for cocotb-based verification of PDM to PCM decimator
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

# Project configuration
PROJECT_NAME = pdm_pcm_decimator
DESIGN_NAME = pdm_pcm_decimator_core
VERSION = 1.3.0

# Directory structure
RTL_DIR = ../../rtl
TB_DIR = .
BUILD_DIR = ../../build/cocotb
REPORTS_DIR = ../../reports/cocotb
WAVEFORMS_DIR = ../../waveforms/cocotb

# RTL files
RTL_FILES = $(RTL_DIR)/fir_coefficients.sv \
            $(RTL_DIR)/fifo_sync.sv \
            $(RTL_DIR)/pdm_pcm_decimator_core.sv

# Testbench files
TB_FILES = $(TB_DIR)/test_pdm_pcm_decimator_core.py

# Cocotb configuration
TOPLEVEL = pdm_pcm_decimator_core
TOPLEVEL_LANG = verilog
MODULE = test_pdm_pcm_decimator_core

# Simulation tools
SIM ?= icarus
VERILOG_SOURCES = $(RTL_FILES)

# Cocotb configuration
export COCOTB_REDUCED_LOG_FMT=1
export COCOTB_ANSI_OUTPUT=1

# Coverage configuration
COVERAGE ?= 0
ifeq ($(COVERAGE),1)
    export COCOTB_COVERAGE=1
    COVERAGE_ARGS = --coverage
endif

# Waveform configuration
WAVES ?= 0
ifeq ($(WAVES),1)
    export COCOTB_ENABLE_PROFILING=1
    WAVES_ARGS = --waves
endif

# Verbose configuration
VERBOSE ?= 0
ifeq ($(VERBOSE),1)
    VERBOSE_ARGS = -v
endif

# Test selection
TEST_NAME ?= all

# Default target
all: sim

# Create directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(REPORTS_DIR):
	mkdir -p $(REPORTS_DIR)

$(WAVEFORMS_DIR):
	mkdir -p $(WAVEFORMS_DIR)

# Simulation targets
.PHONY: sim
sim: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running cocotb simulation with $(SIM)..."
	MODULE=$(MODULE) TOPLEVEL=$(TOPLEVEL) TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
	SIM=$(SIM) VERILOG_SOURCES="$(VERILOG_SOURCES)" \
	$(COVERAGE_ARGS) $(WAVES_ARGS) $(VERBOSE_ARGS) \
	cocotb-run --sim-args="$(SIM_ARGS)" --test-name=$(TEST_NAME)

# Individual test targets
.PHONY: test-reset
test-reset: TEST_NAME=test_reset_sequence
test-reset: sim

.PHONY: test-zeros
test-zeros: TEST_NAME=test_all_zeros_pattern
test-zeros: sim

.PHONY: test-ones
test-ones: TEST_NAME=test_all_ones_pattern
test-ones: sim

.PHONY: test-alternating
test-alternating: TEST_NAME=test_alternating_pattern
test-alternating: sim

.PHONY: test-random
test-random: TEST_NAME=test_random_pattern
test-random: sim

.PHONY: test-backpressure
test-backpressure: TEST_NAME=test_backpressure
test-backpressure: sim

.PHONY: test-overflow
test-overflow: TEST_NAME=test_overflow_condition
test-overflow: sim

.PHONY: test-underflow
test-underflow: TEST_NAME=test_underflow_condition
test-underflow: sim

.PHONY: test-sine
test-sine: TEST_NAME=test_sine_wave_response
test-sine: sim

.PHONY: test-throughput
test-throughput: TEST_NAME=test_performance_throughput
test-throughput: sim

.PHONY: test-state-machine
test-state-machine: TEST_NAME=test_state_machine_coverage
test-state-machine: sim

.PHONY: test-parameters
test-parameters: TEST_NAME=test_parameter_validation
test-parameters: sim

.PHONY: test-continuous
test-continuous: TEST_NAME=test_continuous_operation
test-continuous: sim

# Tool-specific simulation targets
.PHONY: sim-icarus
sim-icarus: SIM=icarus
sim-icarus: sim

.PHONY: sim-verilator
sim-verilator: SIM=verilator
sim-verilator: sim

.PHONY: sim-questa
sim-questa: SIM=questa
sim-questa: sim

.PHONY: sim-modelsim
sim-modelsim: SIM=modelsim
sim-modelsim: sim

.PHONY: sim-vcs
sim-vcs: SIM=vcs
sim-vcs: sim

# Coverage targets
.PHONY: coverage
coverage: COVERAGE=1
coverage: sim
	@echo "Coverage report generated in $(BUILD_DIR)"

.PHONY: coverage-html
coverage-html: coverage
	@echo "Generating HTML coverage report..."
	coverage html -d $(REPORTS_DIR)/coverage_html

.PHONY: coverage-xml
coverage-xml: coverage
	@echo "Generating XML coverage report..."
	coverage xml -o $(REPORTS_DIR)/coverage.xml

# Waveform targets
.PHONY: waves
waves: WAVES=1
waves: sim
	@echo "Waveform files generated in $(BUILD_DIR)"

.PHONY: waves-gtkwave
waves-gtkwave: waves
	@echo "Opening GTKWave..."
	gtkwave $(BUILD_DIR)/dump.vcd

# Performance testing
.PHONY: perf-test
perf-test: TEST_NAME=test_performance_throughput
perf-test: VERBOSE=1
perf-test: sim

# Regression testing
.PHONY: regression
regression: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running full regression test suite..."
	@echo "Test 1: Reset sequence"
	$(MAKE) test-reset
	@echo "Test 2: All zeros pattern"
	$(MAKE) test-zeros
	@echo "Test 3: All ones pattern"
	$(MAKE) test-ones
	@echo "Test 4: Alternating pattern"
	$(MAKE) test-alternating
	@echo "Test 5: Random pattern"
	$(MAKE) test-random
	@echo "Test 6: Backpressure handling"
	$(MAKE) test-backpressure
	@echo "Test 7: Overflow condition"
	$(MAKE) test-overflow
	@echo "Test 8: Underflow condition"
	$(MAKE) test-underflow
	@echo "Test 9: Sine wave response"
	$(MAKE) test-sine
	@echo "Test 10: Performance throughput"
	$(MAKE) test-throughput
	@echo "Test 11: State machine coverage"
	$(MAKE) test-state-machine
	@echo "Test 12: Parameter validation"
	$(MAKE) test-parameters
	@echo "Test 13: Continuous operation"
	$(MAKE) test-continuous
	@echo "Regression test suite completed successfully!"

# Quick test suite
.PHONY: quick-test
quick-test: $(BUILD_DIR) $(REPORTS_DIR)
	@echo "Running quick test suite..."
	$(MAKE) test-reset
	$(MAKE) test-zeros
	$(MAKE) test-ones
	$(MAKE) test-random
	$(MAKE) test-backpressure
	@echo "Quick test suite completed!"

# Stress testing
.PHONY: stress-test
stress-test: TEST_NAME=test_continuous_operation
stress-test: VERBOSE=1
stress-test: sim

# Documentation targets
.PHONY: test-report
test-report: $(REPORTS_DIR)
	@echo "Generating test report..."
	@echo "=== PDM to PCM Decimator Core Test Report ===" > $(REPORTS_DIR)/test_report.txt
	@echo "Date: $$(date)" >> $(REPORTS_DIR)/test_report.txt
	@echo "Version: $(VERSION)" >> $(REPORTS_DIR)/test_report.txt
	@echo "Design: $(DESIGN_NAME)" >> $(REPORTS_DIR)/test_report.txt
	@echo "" >> $(REPORTS_DIR)/test_report.txt
	@echo "Test Cases:" >> $(REPORTS_DIR)/test_report.txt
	@echo "1. Reset sequence and initial state" >> $(REPORTS_DIR)/test_report.txt
	@echo "2. All zeros pattern" >> $(REPORTS_DIR)/test_report.txt
	@echo "3. All ones pattern" >> $(REPORTS_DIR)/test_report.txt
	@echo "4. Alternating pattern" >> $(REPORTS_DIR)/test_report.txt
	@echo "5. Random pattern" >> $(REPORTS_DIR)/test_report.txt
	@echo "6. Backpressure handling" >> $(REPORTS_DIR)/test_report.txt
	@echo "7. Overflow condition" >> $(REPORTS_DIR)/test_report.txt
	@echo "8. Underflow condition" >> $(REPORTS_DIR)/test_report.txt
	@echo "9. Sine wave frequency response" >> $(REPORTS_DIR)/test_report.txt
	@echo "10. Performance throughput" >> $(REPORTS_DIR)/test_report.txt
	@echo "11. State machine coverage" >> $(REPORTS_DIR)/test_report.txt
	@echo "12. Parameter validation" >> $(REPORTS_DIR)/test_report.txt
	@echo "13. Continuous operation" >> $(REPORTS_DIR)/test_report.txt
	@echo "" >> $(REPORTS_DIR)/test_report.txt
	@echo "Parameters:" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Data Width: 16 bits" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Decimation Ratio: 16" >> $(REPORTS_DIR)/test_report.txt
	@echo "  CIC Stages: 4" >> $(REPORTS_DIR)/test_report.txt
	@echo "  CIC Decimation: 8" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Half-band Decimation: 2" >> $(REPORTS_DIR)/test_report.txt
	@echo "  FIR Taps: 64" >> $(REPORTS_DIR)/test_report.txt
	@echo "  FIFO Depth: 16" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Clock Period: 10 ns (100 MHz)" >> $(REPORTS_DIR)/test_report.txt
	@echo "" >> $(REPORTS_DIR)/test_report.txt
	@echo "Performance Specifications:" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Passband Ripple: 0.1 dB" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Stopband Attenuation: 98 dB" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Max Clock Frequency: 100 MHz" >> $(REPORTS_DIR)/test_report.txt
	@echo "  Dynamic Range: 96 dB" >> $(REPORTS_DIR)/test_report.txt
	@echo "Test report generated: $(REPORTS_DIR)/test_report.txt"

# Clean targets
.PHONY: clean
clean:
	@echo "Cleaning cocotb build files..."
	rm -rf $(BUILD_DIR)
	rm -rf __pycache__
	rm -rf *.pyc
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov
	rm -rf coverage.xml

.PHONY: clean-all
clean-all: clean
	@echo "Cleaning all test artifacts..."
	rm -rf $(REPORTS_DIR)
	rm -rf $(WAVEFORMS_DIR)

# Help target
.PHONY: help
help:
	@echo "PDM to PCM Decimator Core - Cocotb Test Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  sim                    - Run simulation with default settings"
	@echo "  regression             - Run full regression test suite"
	@echo "  quick-test             - Run quick test suite"
	@echo "  stress-test            - Run stress testing"
	@echo ""
	@echo "Individual test targets:"
	@echo "  test-reset             - Test reset sequence"
	@echo "  test-zeros             - Test all zeros pattern"
	@echo "  test-ones              - Test all ones pattern"
	@echo "  test-alternating       - Test alternating pattern"
	@echo "  test-random            - Test random pattern"
	@echo "  test-backpressure      - Test backpressure handling"
	@echo "  test-overflow          - Test overflow condition"
	@echo "  test-underflow         - Test underflow condition"
	@echo "  test-sine              - Test sine wave response"
	@echo "  test-throughput        - Test performance throughput"
	@echo "  test-state-machine     - Test state machine coverage"
	@echo "  test-parameters        - Test parameter validation"
	@echo "  test-continuous        - Test continuous operation"
	@echo ""
	@echo "Tool-specific targets:"
	@echo "  sim-icarus             - Run with Icarus Verilog"
	@echo "  sim-verilator          - Run with Verilator"
	@echo "  sim-questa             - Run with Questa"
	@echo "  sim-modelsim           - Run with ModelSim"
	@echo "  sim-vcs                - Run with VCS"
	@echo ""
	@echo "Coverage targets:"
	@echo "  coverage               - Run with coverage enabled"
	@echo "  coverage-html          - Generate HTML coverage report"
	@echo "  coverage-xml           - Generate XML coverage report"
	@echo ""
	@echo "Waveform targets:"
	@echo "  waves                  - Run with waveform generation"
	@echo "  waves-gtkwave          - Open GTKWave"
	@echo ""
	@echo "Documentation targets:"
	@echo "  test-report            - Generate test report"
	@echo ""
	@echo "Clean targets:"
	@echo "  clean                  - Clean build files"
	@echo "  clean-all              - Clean all test artifacts"
	@echo ""
	@echo "Variables:"
	@echo "  SIM                    - Simulation tool (default: icarus)"
	@echo "  COVERAGE               - Enable coverage (0/1, default: 0)"
	@echo "  WAVES                  - Enable waveforms (0/1, default: 0)"
	@echo "  VERBOSE                - Enable verbose output (0/1, default: 0)"
	@echo "  TEST_NAME              - Specific test to run (default: all)"
	@echo ""
	@echo "Examples:"
	@echo "  make sim COVERAGE=1 WAVES=1"
	@echo "  make test-sine SIM=verilator"
	@echo "  make regression VERBOSE=1"

# Include cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim 