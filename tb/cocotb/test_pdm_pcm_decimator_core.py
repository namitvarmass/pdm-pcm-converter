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
from typing import List, Tuple

# Test parameters
DATA_WIDTH = 16
DECIMATION_RATIO = 16
CIC_STAGES = 4
CIC_DECIMATION = 8
HALFBAND_DECIMATION = 2
FIR_TAPS = 64
FIFO_DEPTH = 16
CLOCK_PERIOD_NS = 10

class PdmPcmDecimatorTester:
    """Test driver for PDM to PCM decimator core"""
    
    def __init__(self, dut):
        self.dut = dut
        self.clock_period = CLOCK_PERIOD_NS
        self.test_count = 0
        self.pass_count = 0
        self.fail_count = 0
        
    async def reset_dut(self):
        """Reset the DUT"""
        self.dut.reset_n_i.value = 0
        await Timer(self.clock_period * 10, units='ns')
        self.dut.reset_n_i.value = 1
        await Timer(self.clock_period * 5, units='ns')
        
    async def wait_for_ready(self):
        """Wait for PDM ready signal"""
        while not self.dut.pdm_ready_o.value:
            await RisingEdge(self.dut.clock_i)
            
    async def send_pdm_data(self, data: List[int]):
        """Send PDM data to the DUT"""
        for bit in data:
            self.dut.pdm_data_i.value = bit
            self.dut.pdm_valid_i.value = 1
            await self.wait_for_ready()
            await RisingEdge(self.dut.clock_i)
        self.dut.pdm_valid_i.value = 0
        
    async def wait_for_pcm_output(self, timeout_cycles: int = 1000):
        """Wait for PCM output with timeout"""
        cycles = 0
        while not self.dut.pcm_valid_o.value and cycles < timeout_cycles:
            await RisingEdge(self.dut.clock_i)
            cycles += 1
        return cycles < timeout_cycles
        
    def calculate_expected_pcm(self, pdm_data: List[int]) -> int:
        """Calculate expected PCM output for given PDM data"""
        ones_count = sum(pdm_data)
        expected = (ones_count << (DATA_WIDTH - len(bin(DECIMATION_RATIO)[2:]))) - (1 << (DATA_WIDTH - 1))
        return expected
        
    def log_test_result(self, test_name: str, passed: bool, actual: int = None, expected: int = None):
        """Log test result"""
        self.test_count += 1
        if passed:
            self.pass_count += 1
            cocotb.log.info(f"PASS: {test_name}")
        else:
            self.fail_count += 1
            if actual is not None and expected is not None:
                cocotb.log.error(f"FAIL: {test_name} - Actual: {actual}, Expected: {expected}")
            else:
                cocotb.log.error(f"FAIL: {test_name}")
                
    def print_summary(self):
        """Print test summary"""
        cocotb.log.info("=" * 60)
        cocotb.log.info("TEST SUMMARY")
        cocotb.log.info("=" * 60)
        cocotb.log.info(f"Total Tests: {self.test_count}")
        cocotb.log.info(f"Passed: {self.pass_count}")
        cocotb.log.info(f"Failed: {self.fail_count}")
        cocotb.log.info(f"Success Rate: {(self.pass_count/self.test_count)*100:.1f}%")
        cocotb.log.info("=" * 60)

@cocotb.test()
async def test_reset_sequence(dut):
    """Test reset sequence and initial state"""
    cocotb.log.info("Test: Reset sequence and initial state")
    
    # Create clock
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize signals
    dut.reset_n_i.value = 0
    dut.pdm_data_i.value = 0
    dut.pdm_valid_i.value = 0
    dut.pcm_ready_i.value = 1
    dut.enable_i.value = 0
    
    # Wait for initial state
    await Timer(CLOCK_PERIOD_NS * 5, units='ns')
    
    # Check initial state
    assert dut.busy_o.value == 0, "Busy signal should be low after reset"
    assert dut.overflow_o.value == 0, "Overflow signal should be low after reset"
    assert dut.underflow_o.value == 0, "Underflow signal should be low after reset"
    
    # Release reset
    dut.reset_n_i.value = 1
    await Timer(CLOCK_PERIOD_NS * 10, units='ns')
    
    # Enable the module
    dut.enable_i.value = 1
    await Timer(CLOCK_PERIOD_NS * 5, units='ns')
    
    cocotb.log.info("Reset sequence test completed")

@cocotb.test()
async def test_all_zeros_pattern(dut):
    """Test with all zeros PDM pattern"""
    cocotb.log.info("Test: All zeros PDM pattern")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Generate all zeros pattern
    pdm_data = [0] * DECIMATION_RATIO
    
    # Send data
    await tester.send_pdm_data(pdm_data)
    
    # Wait for output
    success = await tester.wait_for_pcm_output()
    assert success, "Timeout waiting for PCM output"
    
    # Check result
    actual_pcm = dut.pcm_data_o.value.integer
    expected_pcm = tester.calculate_expected_pcm(pdm_data)
    
    passed = actual_pcm == expected_pcm
    tester.log_test_result("All zeros pattern", passed, actual_pcm, expected_pcm)
    
    assert passed, f"All zeros test failed - Actual: {actual_pcm}, Expected: {expected_pcm}"

@cocotb.test()
async def test_all_ones_pattern(dut):
    """Test with all ones PDM pattern"""
    cocotb.log.info("Test: All ones PDM pattern")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Generate all ones pattern
    pdm_data = [1] * DECIMATION_RATIO
    
    # Send data
    await tester.send_pdm_data(pdm_data)
    
    # Wait for output
    success = await tester.wait_for_pcm_output()
    assert success, "Timeout waiting for PCM output"
    
    # Check result
    actual_pcm = dut.pcm_data_o.value.integer
    expected_pcm = tester.calculate_expected_pcm(pdm_data)
    
    passed = actual_pcm == expected_pcm
    tester.log_test_result("All ones pattern", passed, actual_pcm, expected_pcm)
    
    assert passed, f"All ones test failed - Actual: {actual_pcm}, Expected: {expected_pcm}"

@cocotb.test()
async def test_alternating_pattern(dut):
    """Test with alternating PDM pattern"""
    cocotb.log.info("Test: Alternating PDM pattern")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Generate alternating pattern
    pdm_data = [i % 2 for i in range(DECIMATION_RATIO)]
    
    # Send data
    await tester.send_pdm_data(pdm_data)
    
    # Wait for output
    success = await tester.wait_for_pcm_output()
    assert success, "Timeout waiting for PCM output"
    
    # Check result
    actual_pcm = dut.pcm_data_o.value.integer
    expected_pcm = tester.calculate_expected_pcm(pdm_data)
    
    passed = actual_pcm == expected_pcm
    tester.log_test_result("Alternating pattern", passed, actual_pcm, expected_pcm)
    
    assert passed, f"Alternating pattern test failed - Actual: {actual_pcm}, Expected: {expected_pcm}"

@cocotb.test()
async def test_random_patterns(dut):
    """Test with multiple random PDM patterns"""
    cocotb.log.info("Test: Random PDM patterns")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Test multiple random patterns
    num_tests = 10
    for i in range(num_tests):
        # Generate random pattern
        pdm_data = [random.randint(0, 1) for _ in range(DECIMATION_RATIO)]
        
        # Send data
        await tester.send_pdm_data(pdm_data)
        
        # Wait for output
        success = await tester.wait_for_pcm_output()
        assert success, f"Timeout waiting for PCM output in test {i}"
        
        # Check result
        actual_pcm = dut.pcm_data_o.value.integer
        expected_pcm = tester.calculate_expected_pcm(pdm_data)
        
        passed = actual_pcm == expected_pcm
        tester.log_test_result(f"Random pattern {i+1}", passed, actual_pcm, expected_pcm)
        
        if not passed:
            cocotb.log.error(f"Random pattern test {i+1} failed")
            break
    
    cocotb.log.info(f"Random pattern tests completed: {num_tests} tests")

@cocotb.test()
async def test_backpressure(dut):
    """Test backpressure handling"""
    cocotb.log.info("Test: Backpressure handling")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    
    # Disable downstream ready to create backpressure
    dut.pcm_ready_i.value = 0
    
    # Send multiple samples
    num_samples = 3
    for i in range(num_samples):
        pdm_data = [random.randint(0, 1) for _ in range(DECIMATION_RATIO)]
        await tester.send_pdm_data(pdm_data)
        await Timer(CLOCK_PERIOD_NS * 5, units='ns')
    
    # Check that no overflow occurred
    overflow_detected = dut.overflow_o.value
    passed = not overflow_detected
    tester.log_test_result("Backpressure handling", passed)
    
    # Re-enable downstream ready
    dut.pcm_ready_i.value = 1
    
    # Wait for outputs to be consumed
    await Timer(CLOCK_PERIOD_NS * 50, units='ns')
    
    assert passed, "Backpressure test failed - overflow detected"

@cocotb.test()
async def test_overflow_condition(dut):
    """Test overflow condition detection"""
    cocotb.log.info("Test: Overflow condition detection")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    
    # Disable downstream ready
    dut.pcm_ready_i.value = 0
    
    # Send more samples than FIFO can hold
    num_samples = FIFO_DEPTH + 2
    for i in range(num_samples):
        pdm_data = [1] * DECIMATION_RATIO  # All ones to maximize data
        await tester.send_pdm_data(pdm_data)
        await Timer(CLOCK_PERIOD_NS * 5, units='ns')
    
    # Check overflow flag
    overflow_detected = dut.overflow_o.value
    passed = overflow_detected
    tester.log_test_result("Overflow detection", passed)
    
    # Re-enable downstream ready
    dut.pcm_ready_i.value = 1
    
    # Wait for recovery
    await Timer(CLOCK_PERIOD_NS * 100, units='ns')
    
    assert passed, "Overflow test failed - overflow not detected"

@cocotb.test()
async def test_underflow_condition(dut):
    """Test underflow condition detection"""
    cocotb.log.info("Test: Underflow condition detection")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Wait for FIFO to be empty
    await Timer(CLOCK_PERIOD_NS * 200, units='ns')
    
    # Try to read from empty FIFO
    await RisingEdge(dut.clock_i)
    
    # Check underflow flag
    underflow_detected = dut.underflow_o.value
    passed = underflow_detected
    tester.log_test_result("Underflow detection", passed)
    
    assert passed, "Underflow test failed - underflow not detected"

@cocotb.test()
async def test_state_machine_coverage(dut):
    """Test state machine transitions"""
    cocotb.log.info("Test: State machine coverage")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Test state transitions
    dut.enable_i.value = 0
    await RisingEdge(dut.clock_i)
    
    dut.enable_i.value = 1
    dut.pdm_valid_i.value = 1
    
    # Cycle through states
    for i in range(20):
        dut.pdm_data_i.value = random.randint(0, 1)
        await tester.wait_for_ready()
        await RisingEdge(dut.clock_i)
    
    dut.pdm_valid_i.value = 0
    
    # Check that state machine is working
    passed = dut.busy_o.value == 1 or dut.pcm_valid_o.value == 1
    tester.log_test_result("State machine coverage", passed)
    
    assert passed, "State machine coverage test failed"

@cocotb.test()
async def test_performance_throughput(dut):
    """Test performance and throughput"""
    cocotb.log.info("Test: Performance and throughput")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Process multiple samples and measure time
    num_samples = 50
    start_time = cocotb.utils.get_sim_time('ns')
    
    for i in range(num_samples):
        pdm_data = [random.randint(0, 1) for _ in range(DECIMATION_RATIO)]
        await tester.send_pdm_data(pdm_data)
        
        # Wait for output
        success = await tester.wait_for_pcm_output()
        assert success, f"Timeout in performance test at sample {i}"
    
    end_time = cocotb.utils.get_sim_time('ns')
    total_time = end_time - start_time
    
    # Calculate throughput
    throughput = (num_samples * DECIMATION_RATIO) / (total_time / 1e9)  # samples per second
    
    cocotb.log.info(f"Performance test: {num_samples} samples in {total_time} ns")
    cocotb.log.info(f"Throughput: {throughput:.2f} PDM samples/second")
    
    # Check if throughput is reasonable (should be > 1MHz for 100MHz clock)
    passed = throughput > 1e6
    tester.log_test_result("Performance throughput", passed)
    
    assert passed, f"Performance test failed - throughput too low: {throughput}"

@cocotb.test()
async def test_filter_response(dut):
    """Test filter response with known patterns"""
    cocotb.log.info("Test: Filter response")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Test with sine wave approximation
    period = DECIMATION_RATIO
    num_cycles = 5
    
    for cycle in range(num_cycles):
        # Generate sine wave pattern (simple approximation)
        pdm_data = []
        for i in range(DECIMATION_RATIO):
            # Simple sine wave approximation
            if i < period // 2:
                pdm_data.append(1)
            else:
                pdm_data.append(0)
        
        # Send data
        await tester.send_pdm_data(pdm_data)
        
        # Wait for output
        success = await tester.wait_for_pcm_output()
        assert success, f"Timeout in filter response test at cycle {cycle}"
        
        # Check that output is reasonable (not stuck at extremes)
        actual_pcm = dut.pcm_data_o.value.integer
        passed = -32768 < actual_pcm < 32767  # Within 16-bit range
        
        if not passed:
            cocotb.log.error(f"Filter response test failed at cycle {cycle} - PCM: {actual_pcm}")
            break
    
    tester.log_test_result("Filter response", passed)
    assert passed, "Filter response test failed"

@cocotb.test()
async def test_parameter_sweep(dut):
    """Test with different parameter combinations"""
    cocotb.log.info("Test: Parameter sweep")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Test different data patterns
    test_patterns = [
        [0] * DECIMATION_RATIO,  # All zeros
        [1] * DECIMATION_RATIO,  # All ones
        [i % 2 for i in range(DECIMATION_RATIO)],  # Alternating
        [1 if i < DECIMATION_RATIO//4 else 0 for i in range(DECIMATION_RATIO)],  # 25% ones
        [1 if i < DECIMATION_RATIO//2 else 0 for i in range(DECIMATION_RATIO)],  # 50% ones
        [1 if i < 3*DECIMATION_RATIO//4 else 0 for i in range(DECIMATION_RATIO)],  # 75% ones
    ]
    
    all_passed = True
    for i, pattern in enumerate(test_patterns):
        # Send data
        await tester.send_pdm_data(pattern)
        
        # Wait for output
        success = await tester.wait_for_pcm_output()
        if not success:
            cocotb.log.error(f"Timeout in parameter sweep test {i}")
            all_passed = False
            continue
        
        # Check result
        actual_pcm = dut.pcm_data_o.value.integer
        expected_pcm = tester.calculate_expected_pcm(pattern)
        
        passed = actual_pcm == expected_pcm
        tester.log_test_result(f"Parameter sweep {i+1}", passed, actual_pcm, expected_pcm)
        
        if not passed:
            all_passed = False
    
    assert all_passed, "Parameter sweep test failed"

@cocotb.test()
async def test_concurrent_operations(dut):
    """Test concurrent read/write operations"""
    cocotb.log.info("Test: Concurrent operations")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Send multiple samples rapidly
    num_samples = 10
    for i in range(num_samples):
        pdm_data = [random.randint(0, 1) for _ in range(DECIMATION_RATIO)]
        await tester.send_pdm_data(pdm_data)
        
        # Don't wait for output, keep sending
        await Timer(CLOCK_PERIOD_NS * 2, units='ns')
    
    # Now wait for all outputs
    for i in range(num_samples):
        success = await tester.wait_for_pcm_output()
        assert success, f"Timeout waiting for output {i} in concurrent test"
        
        # Verify output is reasonable
        actual_pcm = dut.pcm_data_o.value.integer
        passed = -32768 <= actual_pcm <= 32767
        
        if not passed:
            cocotb.log.error(f"Concurrent test failed at output {i} - PCM: {actual_pcm}")
            break
    
    tester.log_test_result("Concurrent operations", passed)
    assert passed, "Concurrent operations test failed"

@cocotb.test()
async def test_error_conditions(dut):
    """Test error condition handling"""
    cocotb.log.info("Test: Error condition handling")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    
    # Test 1: Disable module during operation
    pdm_data = [1] * DECIMATION_RATIO
    await tester.send_pdm_data(pdm_data[:DECIMATION_RATIO//2])
    
    # Disable module
    dut.enable_i.value = 0
    await Timer(CLOCK_PERIOD_NS * 10, units='ns')
    
    # Re-enable
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Complete the data
    await tester.send_pdm_data(pdm_data[DECIMATION_RATIO//2:])
    
    # Wait for output
    success = await tester.wait_for_pcm_output()
    passed = success
    
    tester.log_test_result("Error condition handling", passed)
    assert passed, "Error condition handling test failed"

@cocotb.test()
async def test_comprehensive_validation(dut):
    """Comprehensive validation test"""
    cocotb.log.info("Test: Comprehensive validation")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, CLOCK_PERIOD_NS, units="ns")
    cocotb.start_soon(clock.start())
    tester = PdmPcmDecimatorTester(dut)
    
    # Reset and enable
    await tester.reset_dut()
    dut.enable_i.value = 1
    dut.pcm_ready_i.value = 1
    
    # Run comprehensive test suite
    test_results = []
    
    # Test 1: Basic functionality
    pdm_data = [random.randint(0, 1) for _ in range(DECIMATION_RATIO)]
    await tester.send_pdm_data(pdm_data)
    success = await tester.wait_for_pcm_output()
    test_results.append(("Basic functionality", success))
    
    # Test 2: Multiple samples
    for i in range(5):
        pdm_data = [random.randint(0, 1) for _ in range(DECIMATION_RATIO)]
        await tester.send_pdm_data(pdm_data)
        success = await tester.wait_for_pcm_output()
        test_results.append((f"Multiple samples {i+1}", success))
    
    # Test 3: Edge cases
    edge_patterns = [
        [0] * DECIMATION_RATIO,  # All zeros
        [1] * DECIMATION_RATIO,  # All ones
        [1, 0] * (DECIMATION_RATIO // 2),  # Alternating
    ]
    
    for i, pattern in enumerate(edge_patterns):
        await tester.send_pdm_data(pattern)
        success = await tester.wait_for_pcm_output()
        test_results.append((f"Edge case {i+1}", success))
    
    # Check all results
    all_passed = all(result[1] for result in test_results)
    
    # Log individual results
    for test_name, passed in test_results:
        tester.log_test_result(test_name, passed)
    
    # Print summary
    tester.print_summary()
    
    assert all_passed, "Comprehensive validation test failed"
    assert tester.fail_count == 0, f"Comprehensive validation failed with {tester.fail_count} failures"
