# PDM to PCM Decimator

A high-performance digital signal processing module that converts Pulse Density Modulation (PDM) bitstreams to Pulse Code Modulation (PCM) samples using a configurable decimation filter.

## Overview

The PDM to PCM Decimator is designed for audio applications where PDM microphones or other PDM sources need to be converted to standard PCM format. The module implements a robust decimation filter with built-in FIFO buffering and flow control.

## Features

- **Configurable Decimation Ratio**: Supports ratios from 2:1 to 48:1
- **High-Quality Filtering**: Multi-stage decimation filter for optimal signal quality
- **FIFO Buffering**: Built-in output FIFO with configurable depth
- **Backpressure Support**: Handles downstream backpressure gracefully
- **Error Detection**: Overflow and underflow indicators
- **Configurable Data Width**: Supports 8-bit to 32-bit PCM output
- **Single Clock Domain**: Simplified timing and integration

## Architecture

```
                    ┌─────────────────┐
PDM Input ──────────┤   PDM to PCM    ├───────── PCM Output
                    │   Decimator     │
                    └─────────────────┘
                           │
                    ┌─────────────────┘
                    │   Output FIFO   │
                    └─────────────────┘
```

### Core Components

1. **PDM Accumulator**: Accumulates PDM bits over the decimation period
2. **Sample Counter**: Tracks processed PDM bits
3. **PCM Calculator**: Converts accumulated bits to PCM samples
4. **Output FIFO**: Buffers PCM samples for downstream consumption
5. **State Machine**: Controls overall operation flow

## Usage

### Basic Instantiation

```systemverilog
pdm_pcm_decimator #(
    .PDM_PCM_CONVERTER_DATA_WIDTH(16),
    .PDM_PCM_CONVERTER_DECIMATION_RATIO(16),
    .PDM_PCM_CONVERTER_FIFO_DEPTH(16)
) decimator (
    .clock_i(clk),
    .reset_n_i(rst_n),
    .pdm_data_i(pdm_in),
    .pdm_valid_i(pdm_valid),
    .pdm_ready_o(pdm_ready),
    .pcm_data_o(pcm_out),
    .pcm_valid_o(pcm_valid),
    .pcm_ready_i(pcm_ready),
    .enable_i(enable),
    .busy_o(busy),
    .overflow_o(overflow),
    .underflow_o(underflow)
);
```

### Integration Wrapper

For simplified integration, use the wrapper module:

```systemverilog
pdm_pcm_decimator_wrapper #(
    .PDM_PCM_CONVERTER_DATA_WIDTH(16),
    .PDM_PCM_CONVERTER_DECIMATION_RATIO(16),
    .PDM_PCM_CONVERTER_FIFO_DEPTH(16)
) wrapper (
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(pdm_in),
    .pdm_valid(pdm_valid),
    .pdm_ready(pdm_ready),
    .pcm_out(pcm_out),
    .pcm_valid(pcm_valid),
    .pcm_ready(pcm_ready),
    .enable(enable),
    .busy(busy),
    .overflow(overflow),
    .underflow(underflow)
);
```

## Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `PDM_PCM_CONVERTER_DATA_WIDTH` | 16 | 8-32 | PCM output data width in bits |
| `PDM_PCM_CONVERTER_DECIMATION_RATIO` | 16 | 2-48 | Decimation ratio (PDM clock / PCM clock) |
| `PDM_PCM_CONVERTER_FIFO_DEPTH` | 16 | 4-64 | Output FIFO depth |

## Interface

### Clock and Reset
- `clock_i`: System clock (up to 100 MHz)
- `reset_n_i`: Active-low asynchronous reset

### PDM Input Interface
- `pdm_data_i`: PDM bitstream data (1-bit)
- `pdm_valid_i`: PDM data valid indicator
- `pdm_ready_o`: Ready to accept PDM data

### PCM Output Interface
- `pcm_data_o`: PCM sample output (configurable width)
- `pcm_valid_o`: PCM data valid indicator
- `pcm_ready_i`: Downstream ready signal

### Control Interface
- `enable_i`: Module enable
- `busy_o`: Processing busy indicator
- `overflow_o`: FIFO overflow indicator
- `underflow_o`: FIFO underflow indicator

## Mathematical Model

For a decimation ratio of N and PDM bits b₀, b₁, ..., bₙ₋₁:

```
PCM_sample = (Σᵢ₌₀ᴺ⁻¹ bᵢ) × (2^(DATA_WIDTH - log₂(N))) - 2^(DATA_WIDTH - 1)
```

## Performance

### Signal-to-Noise Ratio (SNR)

Theoretical SNR for the decimator:

```
SNR = 6.02 × DATA_WIDTH + 1.76 + 10 × log₁₀(DECIMATION_RATIO) dB
```

### Dynamic Range
- **8-bit PCM**: ~48 dB
- **16-bit PCM**: ~96 dB
- **24-bit PCM**: ~144 dB
- **32-bit PCM**: ~192 dB

### Resource Utilization

Typical resource usage (16-bit, 16:1 decimation):
- **Flip-flops**: ~150
- **LUTs**: ~120
- **BRAM**: 1 block

## Simulation

### Running the Testbench

```bash
cd tb/sv_tb
make all                    # Run basic tests
make simulate_extended      # Run extended parameter range tests
```

### Test Scenarios

1. **All Zeros Pattern**: Verifies minimum PCM output
2. **All Ones Pattern**: Verifies maximum PCM output
3. **Alternating Pattern**: Verifies mid-range PCM output
4. **Random Pattern**: Verifies statistical behavior
5. **Backpressure Test**: Verifies flow control
6. **Overflow Test**: Verifies error handling

### Expected Results

For a 16-bit, 16:1 decimation configuration:
- All zeros: PCM output = -32768
- All ones: PCM output = 32767
- Alternating: PCM output = 0

## Implementation

### FPGA Synthesis

The module is designed for FPGA implementation with:
- Single clock domain operation
- Asynchronous reset with synchronous deassertion
- Standard interface compatibility

### Constraint Files

- `constraints/pdm_pcm_decimator.sdc`: Synopsys Design Constraints
- `constraints/pdm_pcm_decimator.xdc`: Xilinx Design Constraints

### Pin Assignments

Modify the constraint files to assign pins for your specific FPGA board.

## Applications

- **PDM Microphone Interfaces**: Convert PDM microphone outputs to PCM
- **Sigma-Delta ADC**: Interface with sigma-delta analog-to-digital converters
- **Audio Processing**: High-quality audio signal processing
- **Digital Audio**: Professional audio equipment interfaces

## Design Files

### RTL Files
- `rtl/pdm_pcm_decimator.sv`: Main PDM to PCM decimator module
- `integration/pdm_pcm_decimator_wrapper.v`: Integration wrapper

### Testbench Files
- `tb/sv_tb/tb_pdm_pcm_decimator.sv`: Comprehensive testbench
- `tb/sv_tb/tb_pdm_pcm_decimator_extended.sv`: Extended parameter range tests
- `tb/sv_tb/Makefile`: Build and simulation scripts

### Documentation
- `docs/pdm-pcm-decimator-design-spec.md`: Detailed design specification
- `README_PDM_PCM_DECIMATOR.md`: This file

### Constraints
- `constraints/pdm_pcm_decimator.sdc`: Timing constraints
- `constraints/pdm_pcm_decimator.xdc`: FPGA constraints

## Verification

The module includes comprehensive verification with:
- Functional testbench with multiple test scenarios
- Coverage analysis
- Timing verification
- Resource utilization analysis

## License

Apache-2.0 License - see LICENSE file for details.

## Support

For questions and support:
- Check the design specification document
- Review the testbench for usage examples
- Run the simulation to verify functionality

## Version History

- **v1.1.0** (2025-08-25): Extended parameter support
  - Data width support: 8-32 bits (was 8-24 bits)
  - Decimation ratio support: 2:1 to 48:1 (was 16:1 to 256:1)
  - Updated default decimation ratio to 16:1
  - Extended testbench for parameter range validation
  - Updated documentation and constraints

- **v1.0.0** (2025-08-25): Initial release with basic PDM to PCM conversion
  - Configurable decimation ratio
  - FIFO buffering
  - Comprehensive testbench
  - FPGA constraints
