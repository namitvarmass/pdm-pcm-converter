#=============================================================================
# PDM to PCM Decimator - Cocotb Configuration
#=============================================================================
# Description: Configuration file for cocotb testbenches
#              Defines test parameters, simulator settings, and test scenarios
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

import os
import sys
from typing import Dict, List, Any

#=============================================================================
# Test Configuration
#=============================================================================

class TestConfig:
    """Configuration class for PDM to PCM decimator tests"""
    
    # Design parameters
    DATA_WIDTH = 16
    DECIMATION_RATIO = 16
    CIC_STAGES = 4
    CIC_DECIMATION = 8
    HALFBAND_DECIMATION = 2
    FIR_TAPS = 64
    FIFO_DEPTH = 16
    CLOCK_PERIOD_NS = 10  # 100MHz clock
    
    # Performance specifications
    PASSBAND_RIPPLE_DB = 0.1
    STOPBAND_ATTENUATION_DB = 98
    MAX_CLOCK_FREQUENCY_MHZ = 100
    DYNAMIC_RANGE_DB = 96
    
    # Test parameters
    TIMEOUT_CYCLES = 1000
    NUM_RANDOM_TESTS = 10
    NUM_PERFORMANCE_SAMPLES = 50
    NUM_CONCURRENT_SAMPLES = 10
    
    # Coverage settings
    COVERAGE_GOALS = {
        'line': 95.0,
        'branch': 90.0,
        'expression': 85.0,
        'fsm': 100.0,
        'toggle': 80.0
    }
    
    # Waveform settings
    WAVEFORM_ENABLED = True
    WAVEFORM_FORMAT = 'vcd'
    WAVEFORM_DEPTH = 10000
    
    # Logging settings
    LOG_LEVEL = 'INFO'
    LOG_FORMAT = 'reduced'
    ANSI_OUTPUT = True

#=============================================================================
# Simulator Configuration
#=============================================================================

class SimulatorConfig:
    """Configuration for different simulators"""
    
    # Icarus Verilog
    ICARUS_CONFIG = {
        'compile_args': ['-g2012'],
        'sim_args': ['-I$(RTL_DIR)'],
        'extra_args': ['-Wall', '-Wno-timescale']
    }
    
    # Verilator
    VERILATOR_CONFIG = {
        'compile_args': ['--cc', '--exe', '--build'],
        'sim_args': ['--trace', '--trace-depth', '10'],
        'extra_args': ['-Wall', '--lint-only']
    }
    
    # ModelSim/QuestaSim
    MODELSIM_CONFIG = {
        'compile_args': ['-sv', '-mfcu'],
        'sim_args': ['-do', 'run.do'],
        'extra_args': ['-voptargs=+acc']
    }
    
    # Xcelium
    XCELIUM_CONFIG = {
        'compile_args': ['-sv', '-full64'],
        'sim_args': ['-gui'],
        'extra_args': ['-access', '+rw']
    }

#=============================================================================
# Test Scenarios
#=============================================================================

class TestScenarios:
    """Predefined test scenarios for comprehensive testing"""
    
    @staticmethod
    def get_basic_scenarios() -> List[Dict[str, Any]]:
        """Get basic test scenarios"""
        return [
            {
                'name': 'all_zeros',
                'description': 'All zeros PDM pattern',
                'pdm_data': [0] * TestConfig.DECIMATION_RATIO,
                'expected_duty_cycle': 0.0,
                'expected_pcm_range': (-32768, -32000)
            },
            {
                'name': 'all_ones',
                'description': 'All ones PDM pattern',
                'pdm_data': [1] * TestConfig.DECIMATION_RATIO,
                'expected_duty_cycle': 1.0,
                'expected_pcm_range': (32000, 32767)
            },
            {
                'name': 'alternating',
                'description': 'Alternating PDM pattern',
                'pdm_data': [i % 2 for i in range(TestConfig.DECIMATION_RATIO)],
                'expected_duty_cycle': 0.5,
                'expected_pcm_range': (-1000, 1000)
            },
            {
                'name': 'quarter_ones',
                'description': '25% ones PDM pattern',
                'pdm_data': [1 if i < TestConfig.DECIMATION_RATIO//4 else 0 
                            for i in range(TestConfig.DECIMATION_RATIO)],
                'expected_duty_cycle': 0.25,
                'expected_pcm_range': (-16384, -12000)
            },
            {
                'name': 'three_quarter_ones',
                'description': '75% ones PDM pattern',
                'pdm_data': [1 if i < 3*TestConfig.DECIMATION_RATIO//4 else 0 
                            for i in range(TestConfig.DECIMATION_RATIO)],
                'expected_duty_cycle': 0.75,
                'expected_pcm_range': (12000, 16384)
            }
        ]
    
    @staticmethod
    def get_performance_scenarios() -> List[Dict[str, Any]]:
        """Get performance test scenarios"""
        return [
            {
                'name': 'throughput_test',
                'description': 'Maximum throughput test',
                'num_samples': TestConfig.NUM_PERFORMANCE_SAMPLES,
                'pattern_type': 'random',
                'backpressure': False,
                'expected_throughput_mhz': 10.0  # 10 MSPS
            },
            {
                'name': 'concurrent_test',
                'description': 'Concurrent read/write test',
                'num_samples': TestConfig.NUM_CONCURRENT_SAMPLES,
                'pattern_type': 'random',
                'backpressure': True,
                'expected_throughput_mhz': 5.0  # 5 MSPS with backpressure
            },
            {
                'name': 'stress_test',
                'description': 'Stress test with continuous operation',
                'num_samples': 100,
                'pattern_type': 'alternating',
                'backpressure': False,
                'expected_throughput_mhz': 8.0  # 8 MSPS
            }
        ]
    
    @staticmethod
    def get_error_scenarios() -> List[Dict[str, Any]]:
        """Get error condition test scenarios"""
        return [
            {
                'name': 'backpressure_test',
                'description': 'Backpressure handling test',
                'num_samples': 5,
                'backpressure_cycles': 50,
                'expected_overflow': False
            },
            {
                'name': 'overflow_test',
                'description': 'FIFO overflow test',
                'num_samples': TestConfig.FIFO_DEPTH + 2,
                'backpressure_cycles': 100,
                'expected_overflow': True
            },
            {
                'name': 'underflow_test',
                'description': 'FIFO underflow test',
                'num_samples': 1,
                'read_empty_fifo': True,
                'expected_underflow': True
            },
            {
                'name': 'disable_during_operation',
                'description': 'Disable module during operation',
                'num_samples': 1,
                'disable_cycles': 10,
                'expected_recovery': True
            }
        ]
    
    @staticmethod
    def get_filter_scenarios() -> List[Dict[str, Any]]:
        """Get filter response test scenarios"""
        return [
            {
                'name': 'sine_wave_approximation',
                'description': 'Sine wave approximation test',
                'frequency_hz': 1000,
                'amplitude': 0.5,
                'num_cycles': 5,
                'expected_response': 'bandpass'
            },
            {
                'name': 'dc_response',
                'description': 'DC response test',
                'dc_level': 0.5,
                'num_samples': 10,
                'expected_response': 'dc_preserved'
            },
            {
                'name': 'high_frequency_rejection',
                'description': 'High frequency rejection test',
                'frequency_hz': 8000,
                'amplitude': 1.0,
                'num_cycles': 3,
                'expected_response': 'rejected'
            }
        ]

#=============================================================================
# Coverage Configuration
#=============================================================================

class CoverageConfig:
    """Configuration for coverage collection and analysis"""
    
    # Coverage types
    COVERAGE_TYPES = ['line', 'branch', 'expression', 'fsm', 'toggle']
    
    # Coverage goals
    COVERAGE_GOALS = {
        'line': 95.0,
        'branch': 90.0,
        'expression': 85.0,
        'fsm': 100.0,
        'toggle': 80.0
    }
    
    # Coverage exclusions
    COVERAGE_EXCLUSIONS = [
        '*/tb/*',
        '*/test_*',
        '*/__pycache__/*',
        '*/build/*'
    ]
    
    # Coverage report formats
    REPORT_FORMATS = ['html', 'xml', 'text']
    
    @staticmethod
    def get_coverage_cmd_args() -> List[str]:
        """Get command line arguments for coverage"""
        args = []
        for coverage_type in CoverageConfig.COVERAGE_TYPES:
            args.extend(['--coverage', coverage_type])
        return args

#=============================================================================
# Environment Configuration
#=============================================================================

class EnvironmentConfig:
    """Environment-specific configuration"""
    
    # Directory paths
    RTL_DIR = os.path.join(os.path.dirname(__file__), '..', '..', 'rtl')
    TB_DIR = os.path.dirname(__file__)
    BUILD_DIR = os.path.join(TB_DIR, 'build')
    REPORTS_DIR = os.path.join(TB_DIR, 'reports')
    WAVEFORMS_DIR = os.path.join(TB_DIR, 'waveforms')
    COVERAGE_DIR = os.path.join(TB_DIR, 'coverage')
    
    # File patterns
    RTL_FILES = [
        os.path.join(RTL_DIR, 'fir_coefficients.sv'),
        os.path.join(RTL_DIR, 'fifo_sync.sv'),
        os.path.join(RTL_DIR, 'pdm_pcm_decimator_core.sv')
    ]
    
    TB_FILES = [
        os.path.join(TB_DIR, 'test_pdm_pcm_decimator_core.py')
    ]
    
    # Environment variables
    ENV_VARS = {
        'COCOTB_REDUCED_LOG_FMT': 'True',
        'COCOTB_ANSI_OUTPUT': 'True',
        'COCOTB_LOG_LEVEL': TestConfig.LOG_LEVEL,
        'COCOTB_RESULTS_FILE': os.path.join(REPORTS_DIR, 'results.xml'),
        'COCOTB_COVERAGE': 'True',
        'COCOTB_WAVES': 'True' if TestConfig.WAVEFORM_ENABLED else 'False'
    }
    
    @staticmethod
    def setup_environment():
        """Setup environment variables"""
        for key, value in EnvironmentConfig.ENV_VARS.items():
            os.environ[key] = str(value)
    
    @staticmethod
    def create_directories():
        """Create necessary directories"""
        dirs = [
            EnvironmentConfig.BUILD_DIR,
            EnvironmentConfig.REPORTS_DIR,
            EnvironmentConfig.WAVEFORMS_DIR,
            EnvironmentConfig.COVERAGE_DIR
        ]
        for dir_path in dirs:
            os.makedirs(dir_path, exist_ok=True)

#=============================================================================
# Validation Configuration
#=============================================================================

class ValidationConfig:
    """Configuration for validation and verification"""
    
    # Timing constraints
    TIMING_CONSTRAINTS = {
        'setup_time_ns': 1.0,
        'hold_time_ns': 0.5,
        'clock_to_q_ns': 2.0,
        'max_clock_frequency_mhz': TestConfig.MAX_CLOCK_FREQUENCY_MHZ
    }
    
    # Functional validation
    FUNCTIONAL_VALIDATION = {
        'data_width_range': (8, 32),
        'decimation_ratio_range': (2, 48),
        'fifo_depth_range': (8, 64),
        'cic_stages_range': (1, 8),
        'fir_taps_range': (16, 128)
    }
    
    # Performance validation
    PERFORMANCE_VALIDATION = {
        'min_throughput_msps': 1.0,
        'max_latency_cycles': 100,
        'max_power_mw': 100.0,
        'max_area_mm2': 1.0
    }
    
    # Error tolerance
    ERROR_TOLERANCE = {
        'pcm_accuracy_bits': 1,
        'frequency_response_db': 0.5,
        'timing_violation_ns': 0.1
    }

#=============================================================================
# Utility Functions
#=============================================================================

def get_simulator_config(simulator: str) -> Dict[str, Any]:
    """Get configuration for specific simulator"""
    configs = {
        'icarus': SimulatorConfig.ICARUS_CONFIG,
        'verilator': SimulatorConfig.VERILATOR_CONFIG,
        'modelsim': SimulatorConfig.MODELSIM_CONFIG,
        'questa': SimulatorConfig.MODELSIM_CONFIG,
        'xcelium': SimulatorConfig.XCELIUM_CONFIG
    }
    return configs.get(simulator, SimulatorConfig.ICARUS_CONFIG)

def validate_configuration() -> bool:
    """Validate the test configuration"""
    try:
        # Check file existence
        for rtl_file in EnvironmentConfig.RTL_FILES:
            if not os.path.exists(rtl_file):
                print(f"ERROR: RTL file not found: {rtl_file}")
                return False
        
        # Check parameter ranges
        if not (8 <= TestConfig.DATA_WIDTH <= 32):
            print(f"ERROR: DATA_WIDTH must be between 8 and 32, got {TestConfig.DATA_WIDTH}")
            return False
        
        if not (2 <= TestConfig.DECIMATION_RATIO <= 48):
            print(f"ERROR: DECIMATION_RATIO must be between 2 and 48, got {TestConfig.DECIMATION_RATIO}")
            return False
        
        # Check performance specs
        if TestConfig.PASSBAND_RIPPLE_DB > 1.0:
            print(f"ERROR: PASSBAND_RIPPLE_DB too high: {TestConfig.PASSBAND_RIPPLE_DB}")
            return False
        
        if TestConfig.STOPBAND_ATTENUATION_DB < 60:
            print(f"ERROR: STOPBAND_ATTENUATION_DB too low: {TestConfig.STOPBAND_ATTENUATION_DB}")
            return False
        
        print("Configuration validation passed!")
        return True
        
    except Exception as e:
        print(f"ERROR: Configuration validation failed: {e}")
        return False

def print_configuration_summary():
    """Print configuration summary"""
    print("=============================================================================")
    print("PDM to PCM Decimator - Cocotb Configuration Summary")
    print("=============================================================================")
    print(f"Design Parameters:")
    print(f"  Data Width: {TestConfig.DATA_WIDTH} bits")
    print(f"  Decimation Ratio: {TestConfig.DECIMATION_RATIO}")
    print(f"  CIC Stages: {TestConfig.CIC_STAGES}")
    print(f"  CIC Decimation: {TestConfig.CIC_DECIMATION}")
    print(f"  Half-band Decimation: {TestConfig.HALFBAND_DECIMATION}")
    print(f"  FIR Taps: {TestConfig.FIR_TAPS}")
    print(f"  FIFO Depth: {TestConfig.FIFO_DEPTH}")
    print(f"  Clock Period: {TestConfig.CLOCK_PERIOD_NS} ns ({1000/TestConfig.CLOCK_PERIOD_NS:.1f} MHz)")
    print()
    print(f"Performance Specifications:")
    print(f"  Passband Ripple: {TestConfig.PASSBAND_RIPPLE_DB} dB")
    print(f"  Stopband Attenuation: {TestConfig.STOPBAND_ATTENUATION_DB} dB")
    print(f"  Max Clock Frequency: {TestConfig.MAX_CLOCK_FREQUENCY_MHZ} MHz")
    print(f"  Dynamic Range: {TestConfig.DYNAMIC_RANGE_DB} dB")
    print()
    print(f"Test Configuration:")
    print(f"  Timeout Cycles: {TestConfig.TIMEOUT_CYCLES}")
    print(f"  Random Tests: {TestConfig.NUM_RANDOM_TESTS}")
    print(f"  Performance Samples: {TestConfig.NUM_PERFORMANCE_SAMPLES}")
    print(f"  Concurrent Samples: {TestConfig.NUM_CONCURRENT_SAMPLES}")
    print()
    print(f"Coverage Goals:")
    for coverage_type, goal in TestConfig.COVERAGE_GOALS.items():
        print(f"  {coverage_type}: {goal}%")
    print("=============================================================================")

#=============================================================================
# Main Configuration
#=============================================================================

if __name__ == "__main__":
    # Setup environment
    EnvironmentConfig.setup_environment()
    EnvironmentConfig.create_directories()
    
    # Validate configuration
    if validate_configuration():
        print_configuration_summary()
    else:
        sys.exit(1)
