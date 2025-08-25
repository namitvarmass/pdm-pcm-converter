#=============================================================================
# PDM to PCM Decimator - Cocotb Configuration
#=============================================================================
# Description: Configuration file for cocotb testbenches following Vyges conventions
#              Defines test parameters, simulator settings, and test scenarios
#              Supports multi-stage filter chain verification (CIC + Half-band + FIR)
# Author: Vyges IP Development Team
# Date: 2025-08-25T13:26:01Z
# License: Apache-2.0
#=============================================================================

import os
import sys
import json
from typing import Dict, List, Any, Optional
from pathlib import Path

#=============================================================================
# Vyges IP Configuration
#=============================================================================

class VygesIPConfig:
    """Vyges IP-specific configuration following Vyges conventions"""
    
    # IP identification
    IP_NAME = "pdm_pcm_decimator"
    IP_VERSION = "1.4.0"
    IP_PREFIX = "PDM_PCM_CONVERTER"
    
    # Vyges metadata integration
    METADATA_FILE = "vyges-metadata.json"
    
    # Vyges-specific paths
    VYGES_RTL_DIR = "rtl"
    VYGES_TB_DIR = "tb"
    VYGES_DOCS_DIR = "docs"
    VYGES_SCRIPTS_DIR = "scripts"
    VYGES_CONSTRAINTS_DIR = "constraints"
    VYGES_INTEGRATION_DIR = "integration"
    
    # Vyges naming conventions
    MODULE_PREFIX = "pdm_pcm_decimator"
    SIGNAL_PREFIX = "pdm_pcm_converter"
    
    @staticmethod
    def get_vyges_metadata() -> Optional[Dict[str, Any]]:
        """Load Vyges metadata file"""
        try:
            metadata_path = Path(__file__).parent.parent.parent / VygesIPConfig.METADATA_FILE
            if metadata_path.exists():
                with open(metadata_path, 'r') as f:
                    return json.load(f)
        except Exception as e:
            print(f"Warning: Could not load Vyges metadata: {e}")
        return None

#=============================================================================
# Test Configuration (Vyges-compliant)
#=============================================================================

class TestConfig:
    """Configuration class for PDM to PCM decimator tests following Vyges conventions"""
    
    # Design parameters (Vyges UPPER_SNAKE_CASE with IP prefix)
    PDM_PCM_CONVERTER_DATA_WIDTH = 16
    PDM_PCM_CONVERTER_DECIMATION_RATIO = 16
    PDM_PCM_CONVERTER_CIC_STAGES = 4
    PDM_PCM_CONVERTER_CIC_DECIMATION = 8
    PDM_PCM_CONVERTER_HALFBAND_DECIMATION = 2
    PDM_PCM_CONVERTER_FIR_TAPS = 64
    PDM_PCM_CONVERTER_FIFO_DEPTH = 16
    PDM_PCM_CONVERTER_CLOCK_PERIOD_NS = 10  # 100MHz clock
    
    # Performance specifications (Vyges-compliant naming)
    PDM_PCM_CONVERTER_PASSBAND_RIPPLE_DB = 0.1
    PDM_PCM_CONVERTER_STOPBAND_ATTENUATION_DB = 98
    PDM_PCM_CONVERTER_MAX_CLOCK_FREQUENCY_MHZ = 100
    PDM_PCM_CONVERTER_DYNAMIC_RANGE_DB = 96
    
    # Test parameters (Vyges-compliant naming)
    PDM_PCM_CONVERTER_TIMEOUT_CYCLES = 1000
    PDM_PCM_CONVERTER_NUM_RANDOM_TESTS = 10
    PDM_PCM_CONVERTER_NUM_PERFORMANCE_SAMPLES = 50
    PDM_PCM_CONVERTER_NUM_CONCURRENT_SAMPLES = 10
    
    # Coverage settings (Vyges-compliant naming)
    PDM_PCM_CONVERTER_COVERAGE_GOALS = {
        'line': 95.0,
        'branch': 90.0,
        'expression': 85.0,
        'fsm': 100.0,
        'toggle': 80.0
    }
    
    # Waveform settings (Vyges-compliant naming)
    PDM_PCM_CONVERTER_WAVEFORM_ENABLED = True
    PDM_PCM_CONVERTER_WAVEFORM_FORMAT = 'vcd'
    PDM_PCM_CONVERTER_WAVEFORM_DEPTH = 10000
    
    # Logging settings (Vyges-compliant naming)
    PDM_PCM_CONVERTER_LOG_LEVEL = 'INFO'
    PDM_PCM_CONVERTER_LOG_FORMAT = 'reduced'
    PDM_PCM_CONVERTER_ANSI_OUTPUT = True
    
    # Legacy aliases for backward compatibility
    @property
    def DATA_WIDTH(self) -> int:
        return self.PDM_PCM_CONVERTER_DATA_WIDTH
    
    @property
    def DECIMATION_RATIO(self) -> int:
        return self.PDM_PCM_CONVERTER_DECIMATION_RATIO
    
    @property
    def CIC_STAGES(self) -> int:
        return self.PDM_PCM_CONVERTER_CIC_STAGES
    
    @property
    def CIC_DECIMATION(self) -> int:
        return self.PDM_PCM_CONVERTER_CIC_DECIMATION
    
    @property
    def HALFBAND_DECIMATION(self) -> int:
        return self.PDM_PCM_CONVERTER_HALFBAND_DECIMATION
    
    @property
    def FIR_TAPS(self) -> int:
        return self.PDM_PCM_CONVERTER_FIR_TAPS
    
    @property
    def FIFO_DEPTH(self) -> int:
        return self.PDM_PCM_CONVERTER_FIFO_DEPTH
    
    @property
    def CLOCK_PERIOD_NS(self) -> int:
        return self.PDM_PCM_CONVERTER_CLOCK_PERIOD_NS

#=============================================================================
# Simulator Configuration (Vyges-compliant)
#=============================================================================

class SimulatorConfig:
    """Configuration for different simulators following Vyges conventions"""
    
    # Icarus Verilog (open-source)
    PDM_PCM_CONVERTER_ICARUS_CONFIG = {
        'compile_args': ['-g2012'],
        'sim_args': ['-I$(RTL_DIR)'],
        'extra_args': ['-Wall', '-Wno-timescale'],
        'tool_name': 'icarus',
        'tool_type': 'open_source'
    }
    
    # Verilator (open-source)
    PDM_PCM_CONVERTER_VERILATOR_CONFIG = {
        'compile_args': ['--cc', '--exe', '--build'],
        'sim_args': ['--trace', '--trace-depth', '10'],
        'extra_args': ['-Wall', '--lint-only'],
        'tool_name': 'verilator',
        'tool_type': 'open_source'
    }
    
    # ModelSim/QuestaSim (proprietary)
    PDM_PCM_CONVERTER_MODELSIM_CONFIG = {
        'compile_args': ['-sv', '-mfcu'],
        'sim_args': ['-do', 'run.do'],
        'extra_args': ['-voptargs=+acc'],
        'tool_name': 'modelsim',
        'tool_type': 'proprietary'
    }
    
    # Xcelium (proprietary)
    PDM_PCM_CONVERTER_XCELIUM_CONFIG = {
        'compile_args': ['-sv', '-full64'],
        'sim_args': ['-gui'],
        'extra_args': ['-access', '+rw'],
        'tool_name': 'xcelium',
        'tool_type': 'proprietary'
    }
    
    # Legacy aliases for backward compatibility
    ICARUS_CONFIG = PDM_PCM_CONVERTER_ICARUS_CONFIG
    VERILATOR_CONFIG = PDM_PCM_CONVERTER_VERILATOR_CONFIG
    MODELSIM_CONFIG = PDM_PCM_CONVERTER_MODELSIM_CONFIG
    XCELIUM_CONFIG = PDM_PCM_CONVERTER_XCELIUM_CONFIG

#=============================================================================
# Test Scenarios (Vyges-compliant)
#=============================================================================

class TestScenarios:
    """Predefined test scenarios for comprehensive testing following Vyges conventions"""
    
    @staticmethod
    def get_basic_scenarios() -> List[Dict[str, Any]]:
        """Get basic test scenarios with Vyges-compliant naming"""
        config = TestConfig()
        return [
            {
                'name': 'pdm_pcm_converter_all_zeros',
                'description': 'All zeros PDM pattern',
                'pdm_data': [0] * config.PDM_PCM_CONVERTER_DECIMATION_RATIO,
                'expected_duty_cycle': 0.0,
                'expected_pcm_range': (-32768, -32000)
            },
            {
                'name': 'pdm_pcm_converter_all_ones',
                'description': 'All ones PDM pattern',
                'pdm_data': [1] * config.PDM_PCM_CONVERTER_DECIMATION_RATIO,
                'expected_duty_cycle': 1.0,
                'expected_pcm_range': (32000, 32767)
            },
            {
                'name': 'pdm_pcm_converter_alternating',
                'description': 'Alternating PDM pattern',
                'pdm_data': [i % 2 for i in range(config.PDM_PCM_CONVERTER_DECIMATION_RATIO)],
                'expected_duty_cycle': 0.5,
                'expected_pcm_range': (-1000, 1000)
            },
            {
                'name': 'pdm_pcm_converter_quarter_ones',
                'description': '25% ones PDM pattern',
                'pdm_data': [1 if i < config.PDM_PCM_CONVERTER_DECIMATION_RATIO//4 else 0 
                            for i in range(config.PDM_PCM_CONVERTER_DECIMATION_RATIO)],
                'expected_duty_cycle': 0.25,
                'expected_pcm_range': (-16384, -12000)
            },
            {
                'name': 'pdm_pcm_converter_three_quarter_ones',
                'description': '75% ones PDM pattern',
                'pdm_data': [1 if i < 3*config.PDM_PCM_CONVERTER_DECIMATION_RATIO//4 else 0 
                            for i in range(config.PDM_PCM_CONVERTER_DECIMATION_RATIO)],
                'expected_duty_cycle': 0.75,
                'expected_pcm_range': (12000, 16384)
            }
        ]
    
    @staticmethod
    def get_performance_scenarios() -> List[Dict[str, Any]]:
        """Get performance test scenarios with Vyges-compliant naming"""
        config = TestConfig()
        return [
            {
                'name': 'pdm_pcm_converter_throughput_test',
                'description': 'Maximum throughput test',
                'num_samples': config.PDM_PCM_CONVERTER_NUM_PERFORMANCE_SAMPLES,
                'pattern_type': 'random',
                'backpressure': False,
                'expected_throughput_mhz': 10.0  # 10 MSPS
            },
            {
                'name': 'pdm_pcm_converter_concurrent_test',
                'description': 'Concurrent read/write test',
                'num_samples': config.PDM_PCM_CONVERTER_NUM_CONCURRENT_SAMPLES,
                'pattern_type': 'random',
                'backpressure': True,
                'expected_throughput_mhz': 5.0  # 5 MSPS with backpressure
            },
            {
                'name': 'pdm_pcm_converter_stress_test',
                'description': 'Stress test with continuous operation',
                'num_samples': 100,
                'pattern_type': 'alternating',
                'backpressure': False,
                'expected_throughput_mhz': 8.0  # 8 MSPS
            }
        ]
    
    @staticmethod
    def get_error_scenarios() -> List[Dict[str, Any]]:
        """Get error condition test scenarios with Vyges-compliant naming"""
        config = TestConfig()
        return [
            {
                'name': 'pdm_pcm_converter_backpressure_test',
                'description': 'Backpressure handling test',
                'num_samples': 5,
                'backpressure_cycles': 50,
                'expected_overflow': False
            },
            {
                'name': 'pdm_pcm_converter_overflow_test',
                'description': 'FIFO overflow test',
                'num_samples': config.PDM_PCM_CONVERTER_FIFO_DEPTH + 2,
                'backpressure_cycles': 100,
                'expected_overflow': True
            },
            {
                'name': 'pdm_pcm_converter_underflow_test',
                'description': 'FIFO underflow test',
                'num_samples': 1,
                'read_empty_fifo': True,
                'expected_underflow': True
            },
            {
                'name': 'pdm_pcm_converter_disable_during_operation',
                'description': 'Disable module during operation',
                'num_samples': 1,
                'disable_cycles': 10,
                'expected_recovery': True
            }
        ]
    
    @staticmethod
    def get_filter_scenarios() -> List[Dict[str, Any]]:
        """Get filter response test scenarios with Vyges-compliant naming"""
        return [
            {
                'name': 'pdm_pcm_converter_sine_wave_approximation',
                'description': 'Sine wave approximation test',
                'frequency_hz': 1000,
                'amplitude': 0.5,
                'num_cycles': 5,
                'expected_response': 'bandpass'
            },
            {
                'name': 'pdm_pcm_converter_dc_response',
                'description': 'DC response test',
                'dc_level': 0.5,
                'num_samples': 10,
                'expected_response': 'dc_preserved'
            },
            {
                'name': 'pdm_pcm_converter_high_frequency_rejection',
                'description': 'High frequency rejection test',
                'frequency_hz': 8000,
                'amplitude': 1.0,
                'num_cycles': 3,
                'expected_response': 'rejected'
            }
        ]

#=============================================================================
# Coverage Configuration (Vyges-compliant)
#=============================================================================

class CoverageConfig:
    """Configuration for coverage collection and analysis following Vyges conventions"""
    
    # Coverage types
    PDM_PCM_CONVERTER_COVERAGE_TYPES = ['line', 'branch', 'expression', 'fsm', 'toggle']
    
    # Coverage goals
    PDM_PCM_CONVERTER_COVERAGE_GOALS = {
        'line': 95.0,
        'branch': 90.0,
        'expression': 85.0,
        'fsm': 100.0,
        'toggle': 80.0
    }
    
    # Coverage exclusions
    PDM_PCM_CONVERTER_COVERAGE_EXCLUSIONS = [
        '*/tb/*',
        '*/test_*',
        '*/__pycache__/*',
        '*/build/*',
        '*/vyges_*/*'
    ]
    
    # Coverage report formats
    PDM_PCM_CONVERTER_REPORT_FORMATS = ['html', 'xml', 'text']
    
    # Legacy aliases for backward compatibility
    COVERAGE_TYPES = PDM_PCM_CONVERTER_COVERAGE_TYPES
    COVERAGE_GOALS = PDM_PCM_CONVERTER_COVERAGE_GOALS
    COVERAGE_EXCLUSIONS = PDM_PCM_CONVERTER_COVERAGE_EXCLUSIONS
    REPORT_FORMATS = PDM_PCM_CONVERTER_REPORT_FORMATS
    
    @staticmethod
    def get_coverage_cmd_args() -> List[str]:
        """Get command line arguments for coverage"""
        args = []
        for coverage_type in CoverageConfig.PDM_PCM_CONVERTER_COVERAGE_TYPES:
            args.extend(['--coverage', coverage_type])
        return args

#=============================================================================
# Environment Configuration (Vyges-compliant)
#=============================================================================

class EnvironmentConfig:
    """Environment-specific configuration following Vyges conventions"""
    
    # Directory paths (Vyges-compliant)
    PDM_PCM_CONVERTER_RTL_DIR = os.path.join(os.path.dirname(__file__), '..', '..', VygesIPConfig.VYGES_RTL_DIR)
    PDM_PCM_CONVERTER_TB_DIR = os.path.dirname(__file__)
    PDM_PCM_CONVERTER_BUILD_DIR = os.path.join(PDM_PCM_CONVERTER_TB_DIR, 'build')
    PDM_PCM_CONVERTER_REPORTS_DIR = os.path.join(PDM_PCM_CONVERTER_TB_DIR, 'reports')
    PDM_PCM_CONVERTER_WAVEFORMS_DIR = os.path.join(PDM_PCM_CONVERTER_TB_DIR, 'waveforms')
    PDM_PCM_CONVERTER_COVERAGE_DIR = os.path.join(PDM_PCM_CONVERTER_TB_DIR, 'coverage')
    
    # File patterns (Vyges-compliant)
    PDM_PCM_CONVERTER_RTL_FILES = [
        os.path.join(PDM_PCM_CONVERTER_RTL_DIR, 'fir_coefficients.sv'),
        os.path.join(PDM_PCM_CONVERTER_RTL_DIR, 'fifo_sync.sv'),
        os.path.join(PDM_PCM_CONVERTER_RTL_DIR, 'pdm_pcm_decimator_core.sv')
    ]
    
    PDM_PCM_CONVERTER_TB_FILES = [
        os.path.join(PDM_PCM_CONVERTER_TB_DIR, 'test_pdm_pcm_decimator_core.py')
    ]
    
    # Environment variables (Vyges-compliant)
    PDM_PCM_CONVERTER_ENV_VARS = {
        'COCOTB_REDUCED_LOG_FMT': 'True',
        'COCOTB_ANSI_OUTPUT': 'True',
        'COCOTB_LOG_LEVEL': TestConfig().PDM_PCM_CONVERTER_LOG_LEVEL,
        'COCOTB_RESULTS_FILE': os.path.join(PDM_PCM_CONVERTER_REPORTS_DIR, 'results.xml'),
        'COCOTB_COVERAGE': 'True',
        'COCOTB_WAVES': 'True' if TestConfig().PDM_PCM_CONVERTER_WAVEFORM_ENABLED else 'False',
        'VYGES_IP_NAME': VygesIPConfig.IP_NAME,
        'VYGES_IP_VERSION': VygesIPConfig.IP_VERSION
    }
    
    # Legacy aliases for backward compatibility
    RTL_DIR = PDM_PCM_CONVERTER_RTL_DIR
    TB_DIR = PDM_PCM_CONVERTER_TB_DIR
    BUILD_DIR = PDM_PCM_CONVERTER_BUILD_DIR
    REPORTS_DIR = PDM_PCM_CONVERTER_REPORTS_DIR
    WAVEFORMS_DIR = PDM_PCM_CONVERTER_WAVEFORMS_DIR
    COVERAGE_DIR = PDM_PCM_CONVERTER_COVERAGE_DIR
    RTL_FILES = PDM_PCM_CONVERTER_RTL_FILES
    TB_FILES = PDM_PCM_CONVERTER_TB_FILES
    ENV_VARS = PDM_PCM_CONVERTER_ENV_VARS
    
    @staticmethod
    def setup_environment():
        """Setup environment variables"""
        for key, value in EnvironmentConfig.PDM_PCM_CONVERTER_ENV_VARS.items():
            os.environ[key] = str(value)
    
    @staticmethod
    def create_directories():
        """Create necessary directories"""
        dirs = [
            EnvironmentConfig.PDM_PCM_CONVERTER_BUILD_DIR,
            EnvironmentConfig.PDM_PCM_CONVERTER_REPORTS_DIR,
            EnvironmentConfig.PDM_PCM_CONVERTER_WAVEFORMS_DIR,
            EnvironmentConfig.PDM_PCM_CONVERTER_COVERAGE_DIR
        ]
        for dir_path in dirs:
            os.makedirs(dir_path, exist_ok=True)

#=============================================================================
# Validation Configuration (Vyges-compliant)
#=============================================================================

class ValidationConfig:
    """Configuration for validation and verification following Vyges conventions"""
    
    # Timing constraints (Vyges-compliant naming)
    PDM_PCM_CONVERTER_TIMING_CONSTRAINTS = {
        'setup_time_ns': 1.0,
        'hold_time_ns': 0.5,
        'clock_to_q_ns': 2.0,
        'max_clock_frequency_mhz': TestConfig().PDM_PCM_CONVERTER_MAX_CLOCK_FREQUENCY_MHZ
    }
    
    # Functional validation (Vyges-compliant naming)
    PDM_PCM_CONVERTER_FUNCTIONAL_VALIDATION = {
        'data_width_range': (8, 32),
        'decimation_ratio_range': (2, 48),
        'fifo_depth_range': (8, 64),
        'cic_stages_range': (1, 8),
        'fir_taps_range': (16, 128)
    }
    
    # Performance validation (Vyges-compliant naming)
    PDM_PCM_CONVERTER_PERFORMANCE_VALIDATION = {
        'min_throughput_msps': 1.0,
        'max_latency_cycles': 100,
        'max_power_mw': 100.0,
        'max_area_mm2': 1.0
    }
    
    # Error tolerance (Vyges-compliant naming)
    PDM_PCM_CONVERTER_ERROR_TOLERANCE = {
        'pcm_accuracy_bits': 1,
        'frequency_response_db': 0.5,
        'timing_violation_ns': 0.1
    }
    
    # Legacy aliases for backward compatibility
    TIMING_CONSTRAINTS = PDM_PCM_CONVERTER_TIMING_CONSTRAINTS
    FUNCTIONAL_VALIDATION = PDM_PCM_CONVERTER_FUNCTIONAL_VALIDATION
    PERFORMANCE_VALIDATION = PDM_PCM_CONVERTER_PERFORMANCE_VALIDATION
    ERROR_TOLERANCE = PDM_PCM_CONVERTER_ERROR_TOLERANCE

#=============================================================================
# Utility Functions (Vyges-compliant)
#=============================================================================

def get_simulator_config(simulator: str) -> Dict[str, Any]:
    """Get configuration for specific simulator following Vyges conventions"""
    configs = {
        'icarus': SimulatorConfig.PDM_PCM_CONVERTER_ICARUS_CONFIG,
        'verilator': SimulatorConfig.PDM_PCM_CONVERTER_VERILATOR_CONFIG,
        'modelsim': SimulatorConfig.PDM_PCM_CONVERTER_MODELSIM_CONFIG,
        'questa': SimulatorConfig.PDM_PCM_CONVERTER_MODELSIM_CONFIG,
        'xcelium': SimulatorConfig.PDM_PCM_CONVERTER_XCELIUM_CONFIG
    }
    return configs.get(simulator, SimulatorConfig.PDM_PCM_CONVERTER_ICARUS_CONFIG)

def validate_configuration() -> bool:
    """Validate the test configuration following Vyges conventions"""
    try:
        config = TestConfig()
        
        # Check file existence
        for rtl_file in EnvironmentConfig.PDM_PCM_CONVERTER_RTL_FILES:
            if not os.path.exists(rtl_file):
                print(f"ERROR: RTL file not found: {rtl_file}")
                return False
        
        # Check parameter ranges
        if not (8 <= config.PDM_PCM_CONVERTER_DATA_WIDTH <= 32):
            print(f"ERROR: DATA_WIDTH must be between 8 and 32, got {config.PDM_PCM_CONVERTER_DATA_WIDTH}")
            return False
        
        if not (2 <= config.PDM_PCM_CONVERTER_DECIMATION_RATIO <= 48):
            print(f"ERROR: DECIMATION_RATIO must be between 2 and 48, got {config.PDM_PCM_CONVERTER_DECIMATION_RATIO}")
            return False
        
        # Check performance specs
        if config.PDM_PCM_CONVERTER_PASSBAND_RIPPLE_DB > 1.0:
            print(f"ERROR: PASSBAND_RIPPLE_DB too high: {config.PDM_PCM_CONVERTER_PASSBAND_RIPPLE_DB}")
            return False
        
        if config.PDM_PCM_CONVERTER_STOPBAND_ATTENUATION_DB < 60:
            print(f"ERROR: STOPBAND_ATTENUATION_DB too low: {config.PDM_PCM_CONVERTER_STOPBAND_ATTENUATION_DB}")
            return False
        
        # Check Vyges metadata integration
        metadata = VygesIPConfig.get_vyges_metadata()
        if metadata:
            print(f"Vyges metadata loaded: {metadata.get('name', 'Unknown')} v{metadata.get('version', 'Unknown')}")
        
        print("Configuration validation passed!")
        return True
        
    except Exception as e:
        print(f"ERROR: Configuration validation failed: {e}")
        return False

def print_configuration_summary():
    """Print configuration summary following Vyges conventions"""
    config = TestConfig()
    print("=============================================================================")
    print("PDM to PCM Decimator - Cocotb Configuration Summary (Vyges-compliant)")
    print("=============================================================================")
    print(f"Vyges IP Information:")
    print(f"  IP Name: {VygesIPConfig.IP_NAME}")
    print(f"  IP Version: {VygesIPConfig.IP_VERSION}")
    print(f"  IP Prefix: {VygesIPConfig.IP_PREFIX}")
    print()
    print(f"Design Parameters:")
    print(f"  Data Width: {config.PDM_PCM_CONVERTER_DATA_WIDTH} bits")
    print(f"  Decimation Ratio: {config.PDM_PCM_CONVERTER_DECIMATION_RATIO}")
    print(f"  CIC Stages: {config.PDM_PCM_CONVERTER_CIC_STAGES}")
    print(f"  CIC Decimation: {config.PDM_PCM_CONVERTER_CIC_DECIMATION}")
    print(f"  Half-band Decimation: {config.PDM_PCM_CONVERTER_HALFBAND_DECIMATION}")
    print(f"  FIR Taps: {config.PDM_PCM_CONVERTER_FIR_TAPS}")
    print(f"  FIFO Depth: {config.PDM_PCM_CONVERTER_FIFO_DEPTH}")
    print(f"  Clock Period: {config.PDM_PCM_CONVERTER_CLOCK_PERIOD_NS} ns ({1000/config.PDM_PCM_CONVERTER_CLOCK_PERIOD_NS:.1f} MHz)")
    print()
    print(f"Performance Specifications:")
    print(f"  Passband Ripple: {config.PDM_PCM_CONVERTER_PASSBAND_RIPPLE_DB} dB")
    print(f"  Stopband Attenuation: {config.PDM_PCM_CONVERTER_STOPBAND_ATTENUATION_DB} dB")
    print(f"  Max Clock Frequency: {config.PDM_PCM_CONVERTER_MAX_CLOCK_FREQUENCY_MHZ} MHz")
    print(f"  Dynamic Range: {config.PDM_PCM_CONVERTER_DYNAMIC_RANGE_DB} dB")
    print()
    print(f"Test Configuration:")
    print(f"  Timeout Cycles: {config.PDM_PCM_CONVERTER_TIMEOUT_CYCLES}")
    print(f"  Random Tests: {config.PDM_PCM_CONVERTER_NUM_RANDOM_TESTS}")
    print(f"  Performance Samples: {config.PDM_PCM_CONVERTER_NUM_PERFORMANCE_SAMPLES}")
    print(f"  Concurrent Samples: {config.PDM_PCM_CONVERTER_NUM_CONCURRENT_SAMPLES}")
    print()
    print(f"Coverage Goals:")
    for coverage_type, goal in config.PDM_PCM_CONVERTER_COVERAGE_GOALS.items():
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
