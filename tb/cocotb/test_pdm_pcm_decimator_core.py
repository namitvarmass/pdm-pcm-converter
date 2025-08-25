#!/usr/bin/env python3
#=============================================================================
# PDM to PCM Decimator Core - Cocotb Testbench
#=============================================================================
# Description: Comprehensive cocotb testbench for PDM to PCM decimator core
#              Tests multi-stage filter chain functionality and performance
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ReadOnly
from cocotb.clock import Clock
from cocotb.handle import ModifiableObject
import random
import numpy as np
from typing import List, Tuple, Optional

# Test configuration
class TestConfig:
    """Test configuration parameters following Vyges conventions"""
    DATA_WIDTH = 16
    DECIMATION_RATIO = 16
    CIC_STAGES = 4
    CIC_DECIMATION = 8
    HALFBAND_DECIMATION = 2
    FIR_TAPS = 64
    FIFO_DEPTH = 16
    CLOCK_PERIOD_NS = 10  # 100MHz clock

class PDMGenerator:
    """PDM signal generator for test stimulus"""
    
    @staticmethod
    def generate_constant_pdm(value: float, length: int) -> List[int]:
        """Generate constant PDM signal"""
        pdm_data = []
        for _ in range(length):
            # Simple PDM encoding: probability of 1 = value
            bit = 1 if random.random() < value else 0
            pdm_data.append(bit)
        return pdm_data
    
    @staticmethod
    def generate_sine_pdm(frequency: float, amplitude: float, length: int, sample_rate: float) -> List[int]:
        """Generate sine wave PDM signal"""
        pdm_data = []
        for i in range(length):
            t = i / sample_rate
            sine_value = amplitude * np.sin(2 * np.pi * frequency * t)
            # Convert to PDM: sine_value becomes probability of 1
            probability = 0.5 + 0.5 * sine_value
            probability = max(0.0, min(1.0, probability))  # Clamp to [0, 1]
            bit = 1 if random.random() < probability else 0
            pdm_data.append(bit)
        return pdm_data
    
    @staticmethod
    def generate_random_pdm(length: int) -> List[int]:
        """Generate random PDM signal"""
        return [random.randint(0, 1) for _ in range(length)]

class PCMChecker:
    """PCM output checker and analyzer"""
    
    def __init__(self, data_width: int, decimation_ratio: int):
        self.data_width = data_width
        self.decimation_ratio = decimation_ratio
        self.max_value = (1 << (data_width - 1)) - 1
        self.min_value = -(1 << (data_width - 1))
    
    def check_constant_input(self, pdm_data: List[int], expected_duty_cycle: float) -> bool:
        """Check PCM output for constant PDM input"""
        ones_count = sum(pdm_data)
        actual_duty_cycle = ones_count / len(pdm_data)
        
        # Expected PCM value based on duty cycle
        expected_pcm = int((actual_duty_cycle - 0.5) * 2 * self.max_value)
        
        # Allow some tolerance for quantization
        tolerance = self.max_value / 100  # 1% tolerance
        return abs(expected_pcm) <= tolerance
    
    def check_sine_response(self, pcm_data: List[int], frequency: float, sample_rate: float) -> Tuple[bool, float]:
        """Check frequency response for sine wave input"""
        if len(pcm_data) < 10:
            return False, 0.0
        
        # Simple frequency analysis using FFT
        fft_data = np.fft.fft(pcm_data)
        freqs = np.fft.fftfreq(len(pcm_data), 1/sample_rate)
        
        # Find peak frequency
        peak_idx = np.argmax(np.abs(fft_data[1:len(fft_data)//2])) + 1
        peak_freq = abs(freqs[peak_idx])
        
        # Check if peak frequency matches input frequency
        freq_tolerance = frequency * 0.1  # 10% tolerance
        return abs(peak_freq - frequency) <= freq_tolerance, peak_freq

@cocotb.test()
async def test_reset_sequence(dut):
    """Test reset sequence and initial state"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset sequence
    dut.reset_n_i.value = 0
    dut.enable_i.value = 0
    dut.pdm_data_i.value = 0
    dut.pdm_valid_i.value = 0
    dut.pcm_ready_i.value = 1
    
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    await Timer(50, units="ns")
    
    # Check initial state
    assert dut.busy_o.value == 0, "Busy signal should be low after reset"
    assert dut.overflow_o.value == 0, "Overflow signal should be low after reset"
    assert dut.underflow_o.value == 0, "Underflow signal should be low after reset"
    assert dut.pdm_ready_o.value == 0, "PDM ready should be low when disabled"

@cocotb.test()
async def test_all_zeros_pattern(dut):
    """Test PDM input with all zeros pattern"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Generate all zeros PDM pattern
    pdm_data = [0] * TestConfig.DECIMATION_RATIO
    
    # Send PDM data
    for i, bit in enumerate(pdm_data):
        await RisingEdge(dut.clock_i)
        dut.pdm_data_i.value = bit
        dut.pdm_valid_i.value = 1
        
        # Wait for ready
        while dut.pdm_ready_o.value == 0:
            await RisingEdge(dut.clock_i)
    
    # Wait for PCM output
    await RisingEdge(dut.clock_i)
    dut.pdm_valid_i.value = 0
    
    # Wait for PCM valid
    timeout = 0
    while dut.pcm_valid_o.value == 0 and timeout < 1000:
        await RisingEdge(dut.clock_i)
        timeout += 1
    
    assert timeout < 1000, "Timeout waiting for PCM output"
    
    # Check PCM output (should be negative maximum for all zeros)
    expected_pcm = -(1 << (TestConfig.DATA_WIDTH - 1))
    assert dut.pcm_data_o.value == expected_pcm, f"PCM output mismatch: got {dut.pcm_data_o.value}, expected {expected_pcm}"

@cocotb.test()
async def test_all_ones_pattern(dut):
    """Test PDM input with all ones pattern"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Generate all ones PDM pattern
    pdm_data = [1] * TestConfig.DECIMATION_RATIO
    
    # Send PDM data
    for i, bit in enumerate(pdm_data):
        await RisingEdge(dut.clock_i)
        dut.pdm_data_i.value = bit
        dut.pdm_valid_i.value = 1
        
        # Wait for ready
        while dut.pdm_ready_o.value == 0:
            await RisingEdge(dut.clock_i)
    
    # Wait for PCM output
    await RisingEdge(dut.clock_i)
    dut.pdm_valid_i.value = 0
    
    # Wait for PCM valid
    timeout = 0
    while dut.pcm_valid_o.value == 0 and timeout < 1000:
        await RisingEdge(dut.clock_i)
        timeout += 1
    
    assert timeout < 1000, "Timeout waiting for PCM output"
    
    # Check PCM output (should be positive maximum for all ones)
    expected_pcm = (1 << (TestConfig.DATA_WIDTH - 1)) - 1
    assert dut.pcm_data_o.value == expected_pcm, f"PCM output mismatch: got {dut.pcm_data_o.value}, expected {expected_pcm}"

@cocotb.test()
async def test_alternating_pattern(dut):
    """Test PDM input with alternating pattern"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Generate alternating PDM pattern
    pdm_data = [i % 2 for i in range(TestConfig.DECIMATION_RATIO)]
    
    # Send PDM data
    for i, bit in enumerate(pdm_data):
        await RisingEdge(dut.clock_i)
        dut.pdm_data_i.value = bit
        dut.pdm_valid_i.value = 1
        
        # Wait for ready
        while dut.pdm_ready_o.value == 0:
            await RisingEdge(dut.clock_i)
    
    # Wait for PCM output
    await RisingEdge(dut.clock_i)
    dut.pdm_valid_i.value = 0
    
    # Wait for PCM valid
    timeout = 0
    while dut.pcm_valid_o.value == 0 and timeout < 1000:
        await RisingEdge(dut.clock_i)
        timeout += 1
    
    assert timeout < 1000, "Timeout waiting for PCM output"
    
    # Check PCM output (should be close to zero for 50% duty cycle)
    pcm_value = dut.pcm_data_o.value
    tolerance = 1 << (TestConfig.DATA_WIDTH - 3)  # Allow some tolerance
    assert abs(pcm_value) <= tolerance, f"PCM output should be close to zero for alternating pattern: got {pcm_value}"

@cocotb.test()
async def test_random_pattern(dut):
    """Test PDM input with random pattern"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Generate random PDM pattern
    random.seed(42)  # Fixed seed for reproducible results
    pdm_data = PDMGenerator.generate_random_pdm(TestConfig.DECIMATION_RATIO)
    
    # Send PDM data
    for i, bit in enumerate(pdm_data):
        await RisingEdge(dut.clock_i)
        dut.pdm_data_i.value = bit
        dut.pdm_valid_i.value = 1
        
        # Wait for ready
        while dut.pdm_ready_o.value == 0:
            await RisingEdge(dut.clock_i)
    
    # Wait for PCM output
    await RisingEdge(dut.clock_i)
    dut.pdm_valid_i.value = 0
    
    # Wait for PCM valid
    timeout = 0
    while dut.pcm_valid_o.value == 0 and timeout < 1000:
        await RisingEdge(dut.clock_i)
        timeout += 1
    
    assert timeout < 1000, "Timeout waiting for PCM output"
    
    # Check that PCM output is within valid range
    pcm_value = dut.pcm_data_o.value
    max_value = (1 << (TestConfig.DATA_WIDTH - 1)) - 1
    min_value = -(1 << (TestConfig.DATA_WIDTH - 1))
    assert min_value <= pcm_value <= max_value, f"PCM output out of range: {pcm_value}"

@cocotb.test()
async def test_backpressure(dut):
    """Test backpressure handling"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Disable downstream ready to create backpressure
    dut.pcm_ready_i.value = 0
    
    # Send multiple PDM samples
    for sample in range(3):
        pdm_data = [random.randint(0, 1) for _ in range(TestConfig.DECIMATION_RATIO)]
        
        for i, bit in enumerate(pdm_data):
            await RisingEdge(dut.clock_i)
            dut.pdm_data_i.value = bit
            dut.pdm_valid_i.value = 1
            
            # Wait for ready
            while dut.pdm_ready_o.value == 0:
                await RisingEdge(dut.clock_i)
        
        await RisingEdge(dut.clock_i)
        dut.pdm_valid_i.value = 0
    
    # Check that no overflow occurred
    assert dut.overflow_o.value == 0, "Overflow should not occur during backpressure"
    
    # Re-enable downstream ready
    dut.pcm_ready_i.value = 1
    
    # Wait for PCM output
    timeout = 0
    while dut.pcm_valid_o.value == 0 and timeout < 1000:
        await RisingEdge(dut.clock_i)
        timeout += 1
    
    assert timeout < 1000, "Timeout waiting for PCM output after backpressure"

@cocotb.test()
async def test_overflow_condition(dut):
    """Test FIFO overflow condition"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Disable downstream ready to fill FIFO
    dut.pcm_ready_i.value = 0
    
    # Send more samples than FIFO can hold
    for sample in range(TestConfig.FIFO_DEPTH + 2):
        pdm_data = [1] * TestConfig.DECIMATION_RATIO  # All ones for maximum values
        
        for i, bit in enumerate(pdm_data):
            await RisingEdge(dut.clock_i)
            dut.pdm_data_i.value = bit
            dut.pdm_valid_i.value = 1
            
            # Wait for ready
            while dut.pdm_ready_o.value == 0:
                await RisingEdge(dut.clock_i)
        
        await RisingEdge(dut.clock_i)
        dut.pdm_valid_i.value = 0
    
    # Check overflow flag
    assert dut.overflow_o.value == 1, "Overflow flag should be set when FIFO is full"
    
    # Re-enable downstream ready
    dut.pcm_ready_i.value = 1

@cocotb.test()
async def test_underflow_condition(dut):
    """Test FIFO underflow condition"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Try to read from empty FIFO
    dut.pcm_ready_i.value = 1
    
    # Wait for FIFO to be empty
    timeout = 0
    while timeout < 1000:
        await RisingEdge(dut.clock_i)
        if dut.pcm_valid_o.value == 0:
            break
        timeout += 1
    
    # Try to read
    await RisingEdge(dut.clock_i)
    
    # Check underflow flag
    assert dut.underflow_o.value == 1, "Underflow flag should be set when reading from empty FIFO"

@cocotb.test()
async def test_sine_wave_response(dut):
    """Test frequency response with sine wave input"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Generate sine wave PDM
    sample_rate = 1e9 / TestConfig.CLOCK_PERIOD_NS  # Hz
    frequency = 1000  # 1 kHz
    amplitude = 0.3
    num_samples = 10 * TestConfig.DECIMATION_RATIO  # 10 complete decimation cycles
    
    pdm_data = PDMGenerator.generate_sine_pdm(frequency, amplitude, num_samples, sample_rate)
    
    # Send PDM data and collect PCM output
    pcm_data = []
    sample_count = 0
    
    for i in range(0, len(pdm_data), TestConfig.DECIMATION_RATIO):
        # Send one decimation cycle
        for j in range(TestConfig.DECIMATION_RATIO):
            if i + j < len(pdm_data):
                await RisingEdge(dut.clock_i)
                dut.pdm_data_i.value = pdm_data[i + j]
                dut.pdm_valid_i.value = 1
                
                # Wait for ready
                while dut.pdm_ready_o.value == 0:
                    await RisingEdge(dut.clock_i)
        
        await RisingEdge(dut.clock_i)
        dut.pdm_valid_i.value = 0
        
        # Wait for PCM output
        timeout = 0
        while dut.pcm_valid_o.value == 0 and timeout < 1000:
            await RisingEdge(dut.clock_i)
            timeout += 1
        
        if timeout < 1000:
            pcm_data.append(dut.pcm_data_o.value)
            sample_count += 1
    
    # Check frequency response
    checker = PCMChecker(TestConfig.DATA_WIDTH, TestConfig.DECIMATION_RATIO)
    pcm_sample_rate = sample_rate / TestConfig.DECIMATION_RATIO
    is_valid, peak_freq = checker.check_sine_response(pcm_data, frequency, pcm_sample_rate)
    
    assert is_valid, f"Frequency response check failed. Expected {frequency} Hz, got {peak_freq} Hz"

@cocotb.test()
async def test_performance_throughput(dut):
    """Test performance and throughput"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Measure throughput
    num_samples = 100
    start_time = 0
    end_time = 0
    
    for sample in range(num_samples):
        pdm_data = [random.randint(0, 1) for _ in range(TestConfig.DECIMATION_RATIO)]
        
        if sample == 0:
            start_time = cocotb.utils.get_sim_time("ns")
        
        # Send PDM data
        for i, bit in enumerate(pdm_data):
            await RisingEdge(dut.clock_i)
            dut.pdm_data_i.value = bit
            dut.pdm_valid_i.value = 1
            
            # Wait for ready
            while dut.pdm_ready_o.value == 0:
                await RisingEdge(dut.clock_i)
        
        await RisingEdge(dut.clock_i)
        dut.pdm_valid_i.value = 0
        
        # Wait for PCM output
        timeout = 0
        while dut.pcm_valid_o.value == 0 and timeout < 1000:
            await RisingEdge(dut.clock_i)
            timeout += 1
        
        if sample == num_samples - 1:
            end_time = cocotb.utils.get_sim_time("ns")
    
    # Calculate throughput
    total_time = end_time - start_time
    throughput = num_samples / (total_time * 1e-9)  # samples per second
    
    # Check that throughput is reasonable (should be > 1 MSPS)
    assert throughput > 1e6, f"Throughput too low: {throughput} samples/sec"

@cocotb.test()
async def test_state_machine_coverage(dut):
    """Test state machine coverage and transitions"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Test state transitions
    dut.enable_i.value = 0
    await RisingEdge(dut.clock_i)
    
    dut.enable_i.value = 1
    dut.pdm_valid_i.value = 1
    
    # Cycle through states multiple times
    for cycle in range(10):
        for i in range(TestConfig.DECIMATION_RATIO):
            await RisingEdge(dut.clock_i)
            dut.pdm_data_i.value = random.randint(0, 1)
            
            # Wait for ready
            while dut.pdm_ready_o.value == 0:
                await RisingEdge(dut.clock_i)
    
    dut.pdm_valid_i.value = 0
    
    # Verify that state machine is working
    assert dut.busy_o.value == 1, "Busy signal should be high during processing"

@cocotb.test()
async def test_parameter_validation(dut):
    """Test parameter validation and edge cases"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Test with minimum duty cycle
    pdm_data = [0] * (TestConfig.DECIMATION_RATIO - 1) + [1]  # 1/16 duty cycle
    
    for i, bit in enumerate(pdm_data):
        await RisingEdge(dut.clock_i)
        dut.pdm_data_i.value = bit
        dut.pdm_valid_i.value = 1
        
        while dut.pdm_ready_o.value == 0:
            await RisingEdge(dut.clock_i)
    
    await RisingEdge(dut.clock_i)
    dut.pdm_valid_i.value = 0
    
    # Wait for PCM output
    timeout = 0
    while dut.pcm_valid_o.value == 0 and timeout < 1000:
        await RisingEdge(dut.clock_i)
        timeout += 1
    
    assert timeout < 1000, "Timeout waiting for PCM output"
    
    # Check that output is negative (low duty cycle)
    pcm_value = dut.pcm_data_o.value
    assert pcm_value < 0, f"Low duty cycle should produce negative PCM: got {pcm_value}"

@cocotb.test()
async def test_continuous_operation(dut):
    """Test continuous operation over extended period"""
    # Create clock
    clock = Clock(dut.clock_i, TestConfig.CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset and enable
    dut.reset_n_i.value = 0
    await Timer(100, units="ns")
    dut.reset_n_i.value = 1
    dut.enable_i.value = 1
    await Timer(50, units="ns")
    
    # Continuous operation test
    num_cycles = 50
    pcm_samples = []
    
    for cycle in range(num_cycles):
        # Generate random PDM data
        pdm_data = [random.randint(0, 1) for _ in range(TestConfig.DECIMATION_RATIO)]
        
        # Send PDM data
        for i, bit in enumerate(pdm_data):
            await RisingEdge(dut.clock_i)
            dut.pdm_data_i.value = bit
            dut.pdm_valid_i.value = 1
            
            while dut.pdm_ready_o.value == 0:
                await RisingEdge(dut.clock_i)
        
        await RisingEdge(dut.clock_i)
        dut.pdm_valid_i.value = 0
        
        # Wait for PCM output
        timeout = 0
        while dut.pcm_valid_o.value == 0 and timeout < 1000:
            await RisingEdge(dut.clock_i)
            timeout += 1
        
        if timeout < 1000:
            pcm_samples.append(dut.pcm_data_o.value)
    
    # Verify continuous operation
    assert len(pcm_samples) == num_cycles, f"Expected {num_cycles} PCM samples, got {len(pcm_samples)}"
    
    # Check that all PCM values are within valid range
    max_value = (1 << (TestConfig.DATA_WIDTH - 1)) - 1
    min_value = -(1 << (TestConfig.DATA_WIDTH - 1))
    
    for pcm_value in pcm_samples:
        assert min_value <= pcm_value <= max_value, f"PCM value out of range: {pcm_value}"

# Utility functions for test reporting
def generate_test_report():
    """Generate comprehensive test report"""
    report = {
        "test_name": "PDM to PCM Decimator Core",
        "version": "1.3.0",
        "test_cases": [
            "Reset sequence and initial state",
            "All zeros pattern",
            "All ones pattern", 
            "Alternating pattern",
            "Random pattern",
            "Backpressure handling",
            "Overflow condition",
            "Underflow condition",
            "Sine wave frequency response",
            "Performance throughput",
            "State machine coverage",
            "Parameter validation",
            "Continuous operation"
        ],
        "parameters": {
            "data_width": TestConfig.DATA_WIDTH,
            "decimation_ratio": TestConfig.DECIMATION_RATIO,
            "cic_stages": TestConfig.CIC_STAGES,
            "cic_decimation": TestConfig.CIC_DECIMATION,
            "halfband_decimation": TestConfig.HALFBAND_DECIMATION,
            "fir_taps": TestConfig.FIR_TAPS,
            "fifo_depth": TestConfig.FIFO_DEPTH,
            "clock_period_ns": TestConfig.CLOCK_PERIOD_NS
        },
        "performance_specs": {
            "passband_ripple": "0.1 dB",
            "stopband_attenuation": "98 dB",
            "max_clock_frequency": "100 MHz",
            "dynamic_range": "96 dB"
        }
    }
    return report

if __name__ == "__main__":
    # Generate test report
    report = generate_test_report()
    print("=== PDM to PCM Decimator Core Test Report ===")
    print(f"Version: {report['version']}")
    print(f"Test Cases: {len(report['test_cases'])}")
    print("Parameters:")
    for key, value in report['parameters'].items():
        print(f"  {key}: {value}")
    print("Performance Specifications:")
    for key, value in report['performance_specs'].items():
        print(f"  {key}: {value}")
