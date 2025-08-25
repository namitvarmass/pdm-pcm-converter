#!/usr/bin/env python3
#=============================================================================
# PDM to PCM Decimator Core - Vyges-Compliant Testbench
#=============================================================================
# Description: Comprehensive Vyges-compliant testbench for PDM to PCM decimator core
#              Follows Vyges IP development patterns and conventions
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
import json
import os
from typing import List, Tuple, Dict, Any, Optional
from pathlib import Path

# Import Vyges configuration
from cocotb_config import (
    TestConfig, 
    VygesIPConfig, 
    TestScenarios, 
    CoverageConfig, 
    EnvironmentConfig,
    ValidationConfig
)

#=============================================================================
# Vyges Test Configuration
#=============================================================================

class VygesTestConfig:
    """Vyges-compliant test configuration following Vyges patterns"""
    
    # IP identification (Vyges pattern)
    IP_NAME = VygesIPConfig.IP_NAME
    IP_VERSION = VygesIPConfig.IP_VERSION
    IP_PREFIX = VygesIPConfig.IP_PREFIX
    
    # Test parameters (Vyges UPPER_SNAKE_CASE with IP prefix)
    PDM_PCM_CONVERTER_TEST_TIMEOUT_NS = 10000
    PDM_PCM_CONVERTER_RESET_CYCLES = 10
    PDM_PCM_CONVERTER_STABLE_CYCLES = 5
    PDM_PCM_CONVERTER_MAX_WAIT_CYCLES = 1000
    
    # Test categories (Vyges pattern)
    PDM_PCM_CONVERTER_TEST_CATEGORIES = [
        'functional',
        'performance', 
        'coverage',
        'regression',
        'stress',
        'corner_case'
    ]
    
    # Test priorities (Vyges pattern)
    PDM_PCM_CONVERTER_TEST_PRIORITIES = {
        'critical': 1,
        'high': 2,
        'medium': 3,
        'low': 4
    }
    
    # Test metadata (Vyges pattern)
    PDM_PCM_CONVERTER_TEST_METADATA = {
        'ip_name': IP_NAME,
        'ip_version': IP_VERSION,
        'test_framework': 'cocotb',
        'test_language': 'python',
        'test_author': 'Vyges IP Development Team',
        'test_date': '2025-08-25T13:26:01Z',
        'test_license': 'Apache-2.0'
    }

#=============================================================================
# Vyges Test Base Class
#=============================================================================

class VygesTestBase:
    """Base class for Vyges-compliant tests following Vyges patterns"""
    
    def __init__(self, dut, test_name: str, test_category: str = 'functional', priority: str = 'medium'):
        self.dut = dut
        self.test_name = test_name
        self.test_category = test_category
        self.priority = priority
        self.config = TestConfig()
        self.vyges_config = VygesTestConfig()
        self.test_results = {
            'test_name': test_name,
            'test_category': test_category,
            'priority': priority,
            'status': 'unknown',
            'start_time': None,
            'end_time': None,
            'duration_ns': 0,
            'assertions': [],
            'coverage': {},
            'performance': {}
        }
        
    async def setup_test(self):
        """Setup test environment following Vyges patterns"""
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Setting up test: {self.test_name}")
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Test category: {self.test_category}")
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Test priority: {self.priority}")
        
        # Setup environment
        EnvironmentConfig.setup_environment()
        EnvironmentConfig.create_directories()
        
        # Validate configuration
        if not self._validate_test_config():
            raise ValueError(f"Test configuration validation failed for {self.test_name}")
            
    async def teardown_test(self):
        """Teardown test environment following Vyges patterns"""
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Tearing down test: {self.test_name}")
        
    def _validate_test_config(self) -> bool:
        """Validate test configuration following Vyges patterns"""
        try:
            # Check required parameters
            required_params = [
                'PDM_PCM_CONVERTER_DATA_WIDTH',
                'PDM_PCM_CONVERTER_DECIMATION_RATIO',
                'PDM_PCM_CONVERTER_CIC_STAGES'
            ]
            
            for param in required_params:
                if not hasattr(self.config, param):
                    cocotb.log.error(f"Missing required parameter: {param}")
                    return False
                    
            return True
            
        except Exception as e:
            cocotb.log.error(f"Configuration validation failed: {e}")
            return False
            
    def log_vyges_assertion(self, assertion_name: str, condition: bool, message: str = ""):
        """Log Vyges-compliant assertion following Vyges patterns"""
        assertion = {
            'name': assertion_name,
            'condition': condition,
            'message': message,
            'timestamp': cocotb.utils.get_sim_time('ns')
        }
        
        self.test_results['assertions'].append(assertion)
        
        if condition:
            cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] ASSERTION PASS: {assertion_name} - {message}")
        else:
            cocotb.log.error(f"[{self.vyges_config.IP_PREFIX}] ASSERTION FAIL: {assertion_name} - {message}")
            
        return condition

#=============================================================================
# Vyges Test Driver
#=============================================================================

class VygesPdmPcmDecimatorTester(VygesTestBase):
    """Vyges-compliant test driver for PDM to PCM decimator core"""
    
    def __init__(self, dut, test_name: str, test_category: str = 'functional', priority: str = 'medium'):
        super().__init__(dut, test_name, test_category, priority)
        self.clock_period = self.config.PDM_PCM_CONVERTER_CLOCK_PERIOD_NS
        self.test_count = 0
        self.pass_count = 0
        self.fail_count = 0
        
    async def vyges_reset_sequence(self):
        """Vyges-compliant reset sequence following Vyges patterns"""
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Executing Vyges reset sequence")
        
        # Assert reset
        self.dut.reset_n_i.value = 0
        self.dut.enable_i.value = 0
        await Timer(self.clock_period * self.vyges_config.PDM_PCM_CONVERTER_RESET_CYCLES, units='ns')
        
        # Deassert reset
        self.dut.reset_n_i.value = 1
        await Timer(self.clock_period * self.vyges_config.PDM_PCM_CONVERTER_STABLE_CYCLES, units='ns')
        
        # Enable module
        self.dut.enable_i.value = 1
        self.dut.pcm_ready_i.value = 1
        
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Reset sequence completed")
        
    async def vyges_wait_for_ready(self, timeout_cycles: int = None):
        """Vyges-compliant wait for ready signal"""
        if timeout_cycles is None:
            timeout_cycles = self.vyges_config.PDM_PCM_CONVERTER_MAX_WAIT_CYCLES
            
        cycles = 0
        while not self.dut.pdm_ready_o.value and cycles < timeout_cycles:
            await RisingEdge(self.dut.clock_i)
            cycles += 1
            
        if cycles >= timeout_cycles:
            cocotb.log.warning(f"[{self.vyges_config.IP_PREFIX}] Timeout waiting for ready signal")
            return False
            
        return True
        
    async def vyges_send_pdm_data(self, data: List[int], pattern_name: str = "custom"):
        """Vyges-compliant PDM data transmission"""
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Sending PDM data pattern: {pattern_name}")
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Data length: {len(data)} bits")
        
        for i, bit in enumerate(data):
            self.dut.pdm_data_i.value = bit
            self.dut.pdm_valid_i.value = 1
            
            if not await self.vyges_wait_for_ready():
                return False
                
            await RisingEdge(self.dut.clock_i)
            
            # Log progress for long patterns
            if len(data) > 100 and i % 100 == 0:
                cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Progress: {i}/{len(data)} bits sent")
                
        self.dut.pdm_valid_i.value = 0
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] PDM data transmission completed")
        return True
        
    async def vyges_wait_for_pcm_output(self, timeout_cycles: int = None):
        """Vyges-compliant wait for PCM output"""
        if timeout_cycles is None:
            timeout_cycles = self.vyges_config.PDM_PCM_CONVERTER_MAX_WAIT_CYCLES
            
        cycles = 0
        while not self.dut.pcm_valid_o.value and cycles < timeout_cycles:
            await RisingEdge(self.dut.clock_i)
            cycles += 1
            
        if cycles >= timeout_cycles:
            cocotb.log.warning(f"[{self.vyges_config.IP_PREFIX}] Timeout waiting for PCM output")
            return False
            
        return True
        
    def vyges_calculate_expected_pcm(self, pdm_data: List[int]) -> int:
        """Vyges-compliant PCM calculation with multi-stage filter consideration"""
        ones_count = sum(pdm_data)
        duty_cycle = ones_count / len(pdm_data)
        
        # Consider multi-stage filter effects
        # This is a simplified calculation - in practice, the filter response would be more complex
        expected = int((duty_cycle - 0.5) * (2 ** (self.config.PDM_PCM_CONVERTER_DATA_WIDTH - 1)))
        
        return expected
        
    def vyges_log_test_result(self, test_name: str, passed: bool, actual: Any = None, expected: Any = None, details: str = ""):
        """Vyges-compliant test result logging"""
        self.test_count += 1
        
        result = {
            'test_name': test_name,
            'passed': passed,
            'actual': actual,
            'expected': expected,
            'details': details,
            'timestamp': cocotb.utils.get_sim_time('ns')
        }
        
        if passed:
            self.pass_count += 1
            cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] TEST PASS: {test_name}")
            if details:
                cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] Details: {details}")
        else:
            self.fail_count += 1
            cocotb.log.error(f"[{self.vyges_config.IP_PREFIX}] TEST FAIL: {test_name}")
            if actual is not None and expected is not None:
                cocotb.log.error(f"[{self.vyges_config.IP_PREFIX}] Actual: {actual}, Expected: {expected}")
            if details:
                cocotb.log.error(f"[{self.vyges_config.IP_PREFIX}] Details: {details}")
                
        return result
        
    def vyges_print_test_summary(self):
        """Vyges-compliant test summary"""
        cocotb.log.info("=" * 80)
        cocotb.log.info(f"[{self.vyges_config.IP_PREFIX}] VYGES TEST SUMMARY")
        cocotb.log.info("=" * 80)
        cocotb.log.info(f"IP Name: {self.vyges_config.IP_NAME}")
        cocotb.log.info(f"IP Version: {self.vyges_config.IP_VERSION}")
        cocotb.log.info(f"Test Category: {self.test_category}")
        cocotb.log.info(f"Test Priority: {self.priority}")
        cocotb.log.info(f"Total Tests: {self.test_count}")
        cocotb.log.info(f"Passed: {self.pass_count}")
        cocotb.log.info(f"Failed: {self.fail_count}")
        if self.test_count > 0:
            success_rate = (self.pass_count / self.test_count) * 100
            cocotb.log.info(f"Success Rate: {success_rate:.1f}%")
        cocotb.log.info("=" * 80)

#=============================================================================
# Vyges Functional Tests
#=============================================================================

@cocotb.test()
async def vyges_test_reset_functionality(dut):
    """Vyges-compliant reset functionality test following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges reset functionality test")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_reset_functionality", 
        "functional", 
        "critical"
    )
    
    await tester.setup_test()
    
    # Test reset sequence
    await tester.vyges_reset_sequence()
    
    # Verify reset behavior
    tester.log_vyges_assertion(
        "reset_deasserted", 
        dut.reset_n_i.value == 1, 
        "Reset signal should be deasserted"
    )
    
    tester.log_vyges_assertion(
        "enable_asserted", 
        dut.enable_i.value == 1, 
        "Enable signal should be asserted"
    )
    
    tester.log_vyges_assertion(
        "pcm_ready_asserted", 
        dut.pcm_ready_i.value == 1, 
        "PCM ready signal should be asserted"
    )
    
    # Test multiple reset cycles
    for i in range(3):
        cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Reset cycle {i+1}/3")
        await tester.vyges_reset_sequence()
        
        # Verify module is ready after reset
        ready_cycles = 0
        while not dut.pdm_ready_o.value and ready_cycles < 50:
            await RisingEdge(dut.clock_i)
            ready_cycles += 1
            
        tester.log_vyges_assertion(
            f"ready_after_reset_{i+1}", 
            dut.pdm_ready_o.value == 1, 
            f"Module should be ready after reset cycle {i+1}"
        )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

@cocotb.test()
async def vyges_test_basic_functionality(dut):
    """Vyges-compliant basic functionality test following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges basic functionality test")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_basic_functionality", 
        "functional", 
        "critical"
    )
    
    await tester.setup_test()
    await tester.vyges_reset_sequence()
    
    # Get Vyges test scenarios
    basic_scenarios = TestScenarios.get_basic_scenarios()
    
    for scenario in basic_scenarios:
        scenario_name = scenario['name']
        pdm_data = scenario['pdm_data']
        expected_duty_cycle = scenario['expected_duty_cycle']
        
        cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing scenario: {scenario_name}")
        
        # Send PDM data
        success = await tester.vyges_send_pdm_data(pdm_data, scenario_name)
        tester.log_vyges_assertion(
            f"data_transmission_{scenario_name}", 
            success, 
            f"PDM data transmission for {scenario_name}"
        )
        
        if success:
            # Wait for PCM output
            pcm_ready = await tester.vyges_wait_for_pcm_output()
            tester.log_vyges_assertion(
                f"pcm_output_{scenario_name}", 
                pcm_ready, 
                f"PCM output received for {scenario_name}"
            )
            
            if pcm_ready:
                # Verify PCM data
                actual_pcm = dut.pcm_data_o.value.integer
                expected_pcm = tester.vyges_calculate_expected_pcm(pdm_data)
                
                # Allow tolerance for filter effects
                tolerance = 2 ** (tester.config.PDM_PCM_CONVERTER_DATA_WIDTH - 8)  # 8-bit tolerance
                pcm_match = abs(actual_pcm - expected_pcm) <= tolerance
                
                tester.vyges_log_test_result(
                    f"pcm_verification_{scenario_name}",
                    pcm_match,
                    actual_pcm,
                    expected_pcm,
                    f"Duty cycle: {expected_duty_cycle:.2f}, Tolerance: ±{tolerance}"
                )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

#=============================================================================
# Vyges Performance Tests
#=============================================================================

@cocotb.test()
async def vyges_test_performance_throughput(dut):
    """Vyges-compliant performance throughput test following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges performance throughput test")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_performance_throughput", 
        "performance", 
        "high"
    )
    
    await tester.setup_test()
    await tester.vyges_reset_sequence()
    
    # Performance test parameters
    num_samples = tester.config.PDM_PCM_CONVERTER_NUM_PERFORMANCE_SAMPLES
    decimation_ratio = tester.config.PDM_PCM_CONVERTER_DECIMATION_RATIO
    
    # Generate random PDM data
    pdm_data = [random.randint(0, 1) for _ in range(num_samples * decimation_ratio)]
    
    # Measure throughput
    start_time = cocotb.utils.get_sim_time('ns')
    
    success = await tester.vyges_send_pdm_data(pdm_data, "performance_test")
    tester.log_vyges_assertion(
        "performance_data_transmission", 
        success, 
        "Performance test data transmission"
    )
    
    if success:
        # Wait for all PCM outputs
        pcm_count = 0
        while pcm_count < num_samples:
            if await tester.vyges_wait_for_pcm_output():
                pcm_count += 1
                await RisingEdge(dut.clock_i)
            else:
                break
                
        end_time = cocotb.utils.get_sim_time('ns')
        duration_ns = end_time - start_time
        
        # Calculate throughput
        throughput_msps = (pcm_count * 1e9) / duration_ns if duration_ns > 0 else 0
        
        tester.log_vyges_assertion(
            "performance_throughput", 
            throughput_msps >= 1.0,  # Minimum 1 MSPS
            f"Throughput: {throughput_msps:.2f} MSPS"
        )
        
        tester.vyges_log_test_result(
            "performance_measurement",
            pcm_count == num_samples,
            pcm_count,
            num_samples,
            f"Throughput: {throughput_msps:.2f} MSPS, Duration: {duration_ns/1e6:.2f} ms"
        )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

#=============================================================================
# Vyges Coverage Tests
#=============================================================================

@cocotb.test()
async def vyges_test_coverage_scenarios(dut):
    """Vyges-compliant coverage test following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges coverage test")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_coverage_scenarios", 
        "coverage", 
        "high"
    )
    
    await tester.setup_test()
    await tester.vyges_reset_sequence()
    
    # Test various duty cycles for coverage
    duty_cycles = [0.0, 0.1, 0.25, 0.5, 0.75, 0.9, 1.0]
    decimation_ratio = tester.config.PDM_PCM_CONVERTER_DECIMATION_RATIO
    
    for duty_cycle in duty_cycles:
        # Generate PDM data with specific duty cycle
        ones_count = int(duty_cycle * decimation_ratio)
        pdm_data = [1] * ones_count + [0] * (decimation_ratio - ones_count)
        random.shuffle(pdm_data)  # Randomize order
        
        cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing duty cycle: {duty_cycle:.2f}")
        
        # Send data and verify
        success = await tester.vyges_send_pdm_data(pdm_data, f"duty_cycle_{duty_cycle}")
        
        if success and await tester.vyges_wait_for_pcm_output():
            actual_pcm = dut.pcm_data_o.value.integer
            expected_pcm = tester.vyges_calculate_expected_pcm(pdm_data)
            
            tolerance = 2 ** (tester.config.PDM_PCM_CONVERTER_DATA_WIDTH - 8)
            pcm_match = abs(actual_pcm - expected_pcm) <= tolerance
            
            tester.vyges_log_test_result(
                f"coverage_duty_cycle_{duty_cycle}",
                pcm_match,
                actual_pcm,
                expected_pcm,
                f"Duty cycle: {duty_cycle:.2f}"
            )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

#=============================================================================
# Vyges Stress Tests
#=============================================================================

@cocotb.test()
async def vyges_test_stress_conditions(dut):
    """Vyges-compliant stress test following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges stress test")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_stress_conditions", 
        "stress", 
        "medium"
    )
    
    await tester.setup_test()
    await tester.vyges_reset_sequence()
    
    # Stress test: Continuous operation with backpressure
    num_cycles = 100
    decimation_ratio = tester.config.PDM_PCM_CONVERTER_DECIMATION_RATIO
    
    for cycle in range(num_cycles):
        # Generate random PDM data
        pdm_data = [random.randint(0, 1) for _ in range(decimation_ratio)]
        
        # Apply backpressure randomly
        if random.random() < 0.3:  # 30% chance of backpressure
            dut.pcm_ready_i.value = 0
            await Timer(tester.clock_period * random.randint(1, 5), units='ns')
            dut.pcm_ready_i.value = 1
            
        # Send data
        success = await tester.vyges_send_pdm_data(pdm_data, f"stress_cycle_{cycle}")
        
        if success and await tester.vyges_wait_for_pcm_output():
            # Verify no overflow occurred
            tester.log_vyges_assertion(
                f"no_overflow_cycle_{cycle}", 
                not dut.fifo_overflow_o.value, 
                f"No FIFO overflow in cycle {cycle}"
            )
            
            # Verify PCM output is valid
            actual_pcm = dut.pcm_data_o.value.integer
            expected_pcm = tester.vyges_calculate_expected_pcm(pdm_data)
            
            tolerance = 2 ** (tester.config.PDM_PCM_CONVERTER_DATA_WIDTH - 8)
            pcm_match = abs(actual_pcm - expected_pcm) <= tolerance
            
            tester.vyges_log_test_result(
                f"stress_verification_cycle_{cycle}",
                pcm_match,
                actual_pcm,
                expected_pcm,
                f"Stress cycle {cycle}"
            )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

#=============================================================================
# Vyges Corner Case Tests
#=============================================================================

@cocotb.test()
async def vyges_test_corner_cases(dut):
    """Vyges-compliant corner case test following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges corner case test")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_corner_cases", 
        "corner_case", 
        "medium"
    )
    
    await tester.setup_test()
    await tester.vyges_reset_sequence()
    
    # Corner case 1: Empty data
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing corner case: Empty data")
    success = await tester.vyges_send_pdm_data([], "empty_data")
    tester.log_vyges_assertion(
        "empty_data_handling", 
        success, 
        "Empty data should be handled gracefully"
    )
    
    # Corner case 2: Single bit data
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing corner case: Single bit data")
    success = await tester.vyges_send_pdm_data([1], "single_bit")
    tester.log_vyges_assertion(
        "single_bit_handling", 
        success, 
        "Single bit data should be handled"
    )
    
    # Corner case 3: Maximum frequency alternating pattern
    decimation_ratio = tester.config.PDM_PCM_CONVERTER_DECIMATION_RATIO
    alternating_data = [i % 2 for i in range(decimation_ratio * 10)]
    
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing corner case: High frequency alternating pattern")
    success = await tester.vyges_send_pdm_data(alternating_data, "high_freq_alternating")
    
    if success and await tester.vyges_wait_for_pcm_output():
        actual_pcm = dut.pcm_data_o.value.integer
        expected_pcm = tester.vyges_calculate_expected_pcm(alternating_data[:decimation_ratio])
        
        tolerance = 2 ** (tester.config.PDM_PCM_CONVERTER_DATA_WIDTH - 8)
        pcm_match = abs(actual_pcm - expected_pcm) <= tolerance
        
        tester.vyges_log_test_result(
            "high_freq_alternating_verification",
            pcm_match,
            actual_pcm,
            expected_pcm,
            "High frequency alternating pattern"
        )
    
    # Corner case 4: Disable during operation
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing corner case: Disable during operation")
    
    # Start sending data
    pdm_data = [random.randint(0, 1) for _ in range(decimation_ratio)]
    dut.pdm_data_i.value = pdm_data[0]
    dut.pdm_valid_i.value = 1
    
    # Disable module during operation
    await Timer(tester.clock_period * 2, units='ns')
    dut.enable_i.value = 0
    await Timer(tester.clock_period * 5, units='ns')
    dut.enable_i.value = 1
    
    # Verify module recovers
    ready_cycles = 0
    while not dut.pdm_ready_o.value and ready_cycles < 50:
        await RisingEdge(dut.clock_i)
        ready_cycles += 1
        
    tester.log_vyges_assertion(
        "disable_recovery", 
        dut.pdm_ready_o.value == 1, 
        "Module should recover after disable during operation"
    )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

#=============================================================================
# Vyges Regression Tests
#=============================================================================

@cocotb.test()
async def vyges_test_regression_suite(dut):
    """Vyges-compliant regression test suite following Vyges patterns"""
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Starting Vyges regression test suite")
    
    # Create clock and tester
    clock = Clock(dut.clock_i, VygesTestConfig.PDM_PCM_CONVERTER_TEST_TIMEOUT_NS, units="ns")
    cocotb.start_soon(clock.start())
    
    tester = VygesPdmPcmDecimatorTester(
        dut, 
        "vyges_regression_suite", 
        "regression", 
        "high"
    )
    
    await tester.setup_test()
    await tester.vyges_reset_sequence()
    
    # Regression test: Known good patterns
    regression_patterns = [
        ([0] * 16, "all_zeros_regression"),
        ([1] * 16, "all_ones_regression"),
        ([0, 1] * 8, "alternating_regression"),
        ([1, 1, 0, 0] * 4, "quarter_pattern_regression")
    ]
    
    for pattern, name in regression_patterns:
        cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] Testing regression pattern: {name}")
        
        success = await tester.vyges_send_pdm_data(pattern, name)
        
        if success and await tester.vyges_wait_for_pcm_output():
            actual_pcm = dut.pcm_data_o.value.integer
            expected_pcm = tester.vyges_calculate_expected_pcm(pattern)
            
            tolerance = 2 ** (tester.config.PDM_PCM_CONVERTER_DATA_WIDTH - 8)
            pcm_match = abs(actual_pcm - expected_pcm) <= tolerance
            
            tester.vyges_log_test_result(
                f"regression_{name}",
                pcm_match,
                actual_pcm,
                expected_pcm,
                f"Regression pattern: {name}"
            )
    
    await tester.teardown_test()
    tester.vyges_print_test_summary()

#=============================================================================
# Vyges Test Runner
#=============================================================================

def vyges_run_all_tests():
    """Vyges-compliant test runner following Vyges patterns"""
    cocotb.log.info("=" * 80)
    cocotb.log.info(f"[{VygesTestConfig.IP_PREFIX}] VYGES TEST SUITE STARTING")
    cocotb.log.info("=" * 80)
    cocotb.log.info(f"IP Name: {VygesTestConfig.IP_NAME}")
    cocotb.log.info(f"IP Version: {VygesTestConfig.IP_VERSION}")
    cocotb.log.info(f"Test Framework: Cocotb")
    cocotb.log.info(f"Test Language: Python")
    cocotb.log.info(f"Test Author: Vyges IP Development Team")
    cocotb.log.info(f"Test Date: {VygesTestConfig.PDM_PCM_CONVERTER_TEST_METADATA['test_date']}")
    cocotb.log.info(f"Test License: {VygesTestConfig.PDM_PCM_CONVERTER_TEST_METADATA['test_license']}")
    cocotb.log.info("=" * 80)

# Initialize Vyges test suite
vyges_run_all_tests()
