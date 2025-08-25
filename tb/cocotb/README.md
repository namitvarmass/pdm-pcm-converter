# PDM to PCM Decimator - Cocotb Testbench Documentation

## Overview

This directory contains comprehensive cocotb testbenches for the PDM to PCM decimator core. The testbenches are designed to verify the functionality, performance, and reliability of the multi-stage filter chain implementation.

## Features

- **Comprehensive Test Coverage**: 15+ test scenarios covering all aspects of the design
- **Multiple Simulator Support**: Icarus Verilog, Verilator, ModelSim, QuestaSim, Xcelium
- **Performance Testing**: Throughput and latency measurements
- **Error Condition Testing**: Overflow, underflow, and backpressure scenarios
- **Coverage Analysis**: Line, branch, expression, FSM, and toggle coverage
- **Waveform Generation**: VCD waveform files for debugging
- **Automated Reporting**: XML and HTML test reports

## Test Categories

### 1. Basic Functionality Tests
- Reset sequence and initial state verification
- All zeros PDM pattern processing
- All ones PDM pattern processing
- Alternating PDM pattern processing

### 2. Pattern-Based Tests
- Random PDM pattern validation
- Parameter sweep across different duty cycles
- Filter response verification

### 3. Performance Tests
- Throughput measurement and validation
- Concurrent read/write operations
- Stress testing with continuous operation

### 4. Error Condition Tests
- Backpressure handling
- FIFO overflow detection
- FIFO underflow detection
- Module disable during operation

### 5. State Machine Tests
- State transition coverage
- Control signal validation

### 6. Comprehensive Validation
- End-to-end functionality verification
- Multiple test scenario execution
- Success rate calculation

## Design Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| DATA_WIDTH | 16 bits | PCM output data width |
| DECIMATION_RATIO | 16 | Total decimation ratio |
| CIC_STAGES | 4 | Number of CIC filter stages |
| CIC_DECIMATION | 8 | CIC decimation ratio |
| HALFBAND_DECIMATION | 2 | Half-band decimation ratio |
| FIR_TAPS | 64 | Number of FIR filter taps |
| FIFO_DEPTH | 16 | FIFO depth for output buffering |
| CLOCK_PERIOD | 10 ns | Clock period (100 MHz) |

## Performance Specifications

| Specification | Value | Description |
|---------------|-------|-------------|
| Passband Ripple | 0.1 dB | Maximum passband ripple |
| Stopband Attenuation | 98 dB | Minimum stopband attenuation |
| Max Clock Frequency | 100 MHz | Maximum operating frequency |
| Dynamic Range | 96 dB | Signal-to-noise ratio |

## Installation

### Prerequisites

1. **Python Dependencies**:
   ```bash
   pip install cocotb pytest pytest-cov coverage
   ```

2. **Simulator Installation**:
   - **Icarus Verilog**: `sudo apt-get install iverilog` (Ubuntu/Debian)
   - **Verilator**: `sudo apt-get install verilator` (Ubuntu/Debian)
   - **ModelSim/QuestaSim**: Install from vendor website
   - **Xcelium**: Install from vendor website

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/namitvarmass/pdm-pcm-converter.git
   cd pdm-pcm-converter
   ```

2. **Install dependencies**:
   ```bash
   cd tb/cocotb
   make install_deps
   ```

## Usage

### Basic Test Execution

1. **Run all tests**:
   ```bash
   make test
   ```

2. **Run specific test categories**:
   ```bash
   make test_basic          # Basic functionality tests
   make test_patterns       # Pattern-based tests
   make test_performance    # Performance tests
   make test_errors         # Error condition tests
   ```

3. **Run individual test**:
   ```bash
   make test_individual TEST_NAME=test_all_zeros_pattern
   ```

### Advanced Test Execution

1. **Run tests with coverage**:
   ```bash
   make test_coverage COVERAGE_TYPE=all
   ```

2. **Run tests with waveforms**:
   ```bash
   make test_waveforms
   ```

3. **Run comprehensive validation**:
   ```bash
   make test_comprehensive
   ```

### Simulator Selection

Set the `SIM` environment variable to choose the simulator:

```bash
# Icarus Verilog (default)
make test

# Verilator
SIM=verilator make test

# ModelSim/QuestaSim
SIM=modelsim make test

# Xcelium
SIM=xcelium make test
```

### Coverage Analysis

1. **Run tests with coverage**:
   ```bash
   make test_coverage
   ```

2. **Generate coverage report**:
   ```bash
   make coverage_report
   ```

3. **View coverage in browser**:
   ```bash
   firefox coverage/html/index.html
   ```

### Waveform Analysis

1. **Generate waveforms**:
   ```bash
   make test_waveforms
   ```

2. **View waveforms**:
   ```bash
   make waveform_view
   ```

## Test Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SIM` | `icarus` | Simulator to use |
| `TEST_NAME` | `test_comprehensive_validation` | Specific test to run |
| `COVERAGE_TYPE` | `all` | Coverage type (all, line, branch, expression) |
| `COCOTB_LOG_LEVEL` | `INFO` | Log level (DEBUG, INFO, WARNING, ERROR) |

### Configuration File

The test configuration is defined in `cocotb_config.py`:

```python
class TestConfig:
    DATA_WIDTH = 16
    DECIMATION_RATIO = 16
    CIC_STAGES = 4
    # ... other parameters
```

## Test Results

### Output Files

- **Test Reports**: `reports/*.xml` - JUnit XML test reports
- **Coverage Reports**: `coverage/` - HTML and XML coverage reports
- **Waveforms**: `waveforms/waves.vcd` - VCD waveform files
- **Logs**: Console output with detailed test information

### Success Criteria

- **Functional Tests**: All assertions must pass
- **Performance Tests**: Throughput > 1 MSPS
- **Coverage Goals**: 
  - Line coverage: > 95%
  - Branch coverage: > 90%
  - Expression coverage: > 85%
  - FSM coverage: 100%
  - Toggle coverage: > 80%

## Troubleshooting

### Common Issues

1. **Simulator not found**:
   ```bash
   # Check if simulator is installed
   which iverilog
   which verilator
   ```

2. **Python dependencies missing**:
   ```bash
   pip install -r requirements.txt
   ```

3. **RTL files not found**:
   ```bash
   # Check RTL file paths
   ls -la ../../rtl/
   ```

4. **Permission errors**:
   ```bash
   # Fix directory permissions
   chmod -R 755 .
   ```

### Debug Mode

Enable debug logging:

```bash
COCOTB_LOG_LEVEL=DEBUG make test_individual TEST_NAME=test_all_zeros_pattern
```

### Verbose Output

Enable verbose test output:

```bash
make test_individual TEST_NAME=test_all_zeros_pattern -v
```

## Integration

### CI/CD Pipeline

The testbenches are designed for continuous integration:

```bash
# Run CI pipeline
make ci
```

### Development Workflow

1. **Quick development test**:
   ```bash
   make dev
   ```

2. **Full regression test**:
   ```bash
   make test_regression
   ```

3. **Performance benchmark**:
   ```bash
   make benchmark
   ```

## Contributing

### Adding New Tests

1. **Create test function**:
   ```python
   @cocotb.test()
   async def test_new_functionality(dut):
       """Test new functionality"""
       # Test implementation
   ```

2. **Add to test categories**:
   Update the Makefile targets to include new tests.

3. **Update documentation**:
   Add test description to this README.

### Test Guidelines

- Follow the existing test structure and naming conventions
- Include comprehensive assertions and error checking
- Add appropriate logging and documentation
- Ensure tests are deterministic and repeatable
- Include both positive and negative test cases

## References

- [Cocotb Documentation](https://docs.cocotb.org/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Vyges IP Development Guidelines](https://vyges.com/docs)
- [SystemVerilog LRM](https://ieeexplore.ieee.org/document/8299595)

## License

This project is licensed under the Apache-2.0 License. See the LICENSE file for details.

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review the test logs and error messages
3. Consult the cocotb documentation
4. Open an issue on the GitHub repository

## Version History

- **v1.3.0**: Added comprehensive cocotb testbenches with multi-stage filter support
- **v1.2.0**: Added multi-stage filter chain (CIC + Half-band + FIR)
- **v1.1.0**: Extended parameter ranges (8-32 bits, 2:1 to 48:1 decimation)
- **v1.0.0**: Initial PDM to PCM decimator implementation
