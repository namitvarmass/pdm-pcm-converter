# PDM to PCM Decimator Design Specification

## Overview

The PDM to PCM Decimator is a digital signal processing module that converts Pulse Density Modulation (PDM) bitstreams to Pulse Code Modulation (PCM) samples using a decimation filter. This module is designed for high-performance audio applications where PDM microphones or other PDM sources need to be converted to standard PCM format.

## Key Features

- **Configurable Decimation Ratio**: Supports decimation ratios from 2:1 to 48:1
- **High-Quality Filtering**: Implements a multi-stage decimation filter
- **FIFO Buffering**: Built-in FIFO for output buffering and flow control
- **Backpressure Support**: Handles downstream backpressure gracefully
- **Overflow/Underflow Detection**: Provides status indicators for error conditions
- **Configurable Data Width**: Supports 8-bit to 32-bit PCM output

## Architecture

### Block Diagram

```
                    ┌─────────────────┐
PDM Input ──────────┤   PDM to PCM    ├───────── PCM Output
                    │   Decimator     │
                    └─────────────────┘
                           │
                    ┌─────────────────┐
                    │   Output FIFO   │
                    └─────────────────┘
```

### Core Components

1. **PDM Accumulator**: Accumulates PDM bits over the decimation period
2. **Sample Counter**: Tracks the number of PDM bits processed
3. **PCM Calculator**: Converts accumulated PDM bits to PCM samples
4. **Output FIFO**: Buffers PCM samples for downstream consumption
5. **State Machine**: Controls the overall operation flow

## Interface Specification

### Clock and Reset

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clock_i` | Input | 1 | System clock |
| `reset_n_i` | Input | 1 | Active-low asynchronous reset |

### PDM Input Interface

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `pdm_data_i` | Input | 1 | PDM bitstream data |
| `pdm_valid_i` | Input | 1 | PDM data valid indicator |
| `pdm_ready_o` | Output | 1 | Ready to accept PDM data |

### PCM Output Interface

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `pcm_data_o` | Output | DATA_WIDTH | PCM sample output |
| `pcm_valid_o` | Output | 1 | PCM data valid indicator |
| `pcm_ready_i` | Input | 1 | Downstream ready signal |

### Control Interface

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `enable_i` | Input | 1 | Module enable |
| `busy_o` | Output | 1 | Processing busy indicator |
| `overflow_o` | Output | 1 | FIFO overflow indicator |
| `underflow_o` | Output | 1 | FIFO underflow indicator |

## Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `PDM_PCM_CONVERTER_DATA_WIDTH` | 16 | 8-32 | PCM output data width in bits |
| `PDM_PCM_CONVERTER_DECIMATION_RATIO` | 16 | 2-48 | Decimation ratio (PDM clock / PCM clock) |
| `PDM_PCM_CONVERTER_FIFO_DEPTH` | 16 | 4-64 | Output FIFO depth |

## Operation

### PDM to PCM Conversion

The module converts PDM bitstreams to PCM samples using the following process:

1. **Accumulation**: PDM bits are accumulated over the decimation period
2. **Scaling**: The accumulated value is scaled to the PCM data width
3. **Centering**: The result is centered around zero (signed representation)

### Mathematical Model

For a decimation ratio of N and PDM bits b₀, b₁, ..., bₙ₋₁:

```
PCM_sample = (Σᵢ₌₀ᴺ⁻¹ bᵢ) × (2^(DATA_WIDTH - log₂(N))) - 2^(DATA_WIDTH - 1)
```

### State Machine

The module operates using a three-state state machine:

1. **IDLE**: Module is disabled or waiting for enable
2. **ACCUMULATE**: Accumulating PDM bits for current sample
3. **OUTPUT**: Outputting PCM sample to FIFO

## Timing Requirements

### Clock Frequency

- **PDM Clock**: Up to 100 MHz
- **PCM Clock**: PDM Clock / Decimation Ratio

### Latency

- **Pipeline Latency**: 2 clock cycles
- **FIFO Latency**: Variable (depends on FIFO depth and downstream consumption)

## Performance Characteristics

### Signal-to-Noise Ratio (SNR)

The theoretical SNR for the decimator is:

```
SNR = 6.02 × DATA_WIDTH + 1.76 + 10 × log₁₀(DECIMATION_RATIO) dB
```

### Dynamic Range

- **8-bit PCM**: ~48 dB
- **16-bit PCM**: ~96 dB
- **24-bit PCM**: ~144 dB
- **32-bit PCM**: ~192 dB

## Verification

### Test Scenarios

1. **All Zeros Pattern**: Verifies minimum PCM output
2. **All Ones Pattern**: Verifies maximum PCM output
3. **Alternating Pattern**: Verifies mid-range PCM output
4. **Random Pattern**: Verifies statistical behavior
5. **Backpressure Test**: Verifies flow control
6. **Overflow Test**: Verifies error handling

### Coverage Metrics

- **Line Coverage**: >95%
- **Branch Coverage**: >90%
- **Expression Coverage**: >85%

## Implementation Details

### Resource Utilization

Estimated resource usage for typical configuration (16-bit, 16:1 decimation):

| Resource | Count | Description |
|----------|-------|-------------|
| Flip-flops | ~150 | State machine, counters, FIFO |
| LUTs | ~120 | Combinational logic |
| BRAM | 1 | FIFO memory |

### Power Consumption

- **Static Power**: <1 mW
- **Dynamic Power**: ~2-5 mW (depends on PDM activity)

## Integration Guidelines

### Clock Domain

The module operates in a single clock domain. The PDM input and PCM output use the same clock.

### Reset Strategy

The module uses asynchronous reset with synchronous deassertion for reliable initialization.

### Interface Compatibility

The module is compatible with standard AXI-Stream and Avalon-ST interfaces through simple adapters.

## Future Enhancements

1. **Multi-channel Support**: Support for stereo or multi-channel PDM inputs
2. **Advanced Filtering**: Configurable filter coefficients for different applications
3. **DSP Integration**: Integration with DSP blocks for additional processing
4. **Power Management**: Clock gating and power-down modes

## References

1. "Understanding PDM Digital Audio" - Texas Instruments Application Report
2. "Sigma-Delta ADC Tutorial" - Analog Devices
3. "Digital Signal Processing" - Proakis and Manolakis
