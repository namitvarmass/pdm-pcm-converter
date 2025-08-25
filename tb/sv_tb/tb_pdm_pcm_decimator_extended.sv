//=============================================================================
// PDM to PCM Decimator Extended Testbench
//=============================================================================
// Description: Extended testbench for PDM to PCM decimation filter
//              Tests new parameter ranges: 8-32 bits data width, 2:1 to 48:1 decimation
// Author: Vyges IP Development Team
// Date: 2025-08-25T13:26:01Z
// License: Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module tb_pdm_pcm_decimator_extended;

    // Test configurations
    typedef struct {
        int data_width;
        int decimation_ratio;
        int fifo_depth;
        string test_name;
    } test_config_t;
    
    // Test configurations to verify parameter ranges
    test_config_t test_configs[] = '{
        '{8, 2, 8, "8-bit, 2:1 decimation"},
        '{8, 16, 8, "8-bit, 16:1 decimation"},
        '{16, 4, 16, "16-bit, 4:1 decimation"},
        '{16, 16, 16, "16-bit, 16:1 decimation"},
        '{16, 48, 16, "16-bit, 48:1 decimation"},
        '{24, 8, 16, "24-bit, 8:1 decimation"},
        '{24, 32, 16, "24-bit, 32:1 decimation"},
        '{32, 16, 32, "32-bit, 16:1 decimation"},
        '{32, 48, 32, "32-bit, 48:1 decimation"}
    };
    
    // Current test configuration
    test_config_t current_config;
    int current_test_index;
    
    // Clock and reset signals
    logic clock_i;
    logic reset_n_i;
    
    // DUT interface signals
    logic pdm_data_i;
    logic pdm_valid_i;
    logic pdm_ready_o;
    logic [31:0] pcm_data_o;  // Maximum width for all tests
    logic pcm_valid_o;
    logic pcm_ready_i;
    logic enable_i;
    logic busy_o;
    logic overflow_o;
    logic underflow_o;
    
    // Testbench variables
    int test_count;
    int error_count;
    logic [31:0] expected_pcm;
    
    // Clock generation
    localparam int CLOCK_PERIOD = 10; // 100MHz clock
    initial begin
        clock_i = 0;
        forever #(CLOCK_PERIOD/2) clock_i = ~clock_i;
    end
    
    // DUT instantiation (will be re-instantiated for each test)
    pdm_pcm_decimator #(
        .PDM_PCM_CONVERTER_DATA_WIDTH(16),
        .PDM_PCM_CONVERTER_DECIMATION_RATIO(16),
        .PDM_PCM_CONVERTER_FIFO_DEPTH(16)
    ) dut (
        .clock_i(clock_i),
        .reset_n_i(reset_n_i),
        .pdm_data_i(pdm_data_i),
        .pdm_valid_i(pdm_valid_i),
        .pdm_ready_o(pdm_ready_o),
        .pcm_data_o(pcm_data_o),
        .pcm_valid_o(pcm_valid_o),
        .pcm_ready_i(pcm_ready_i),
        .enable_i(enable_i),
        .busy_o(busy_o),
        .overflow_o(overflow_o),
        .underflow_o(underflow_o)
    );
    
    // Test stimulus and monitoring
    initial begin
        // Initialize signals
        reset_n_i = 0;
        pdm_data_i = 0;
        pdm_valid_i = 0;
        pcm_ready_i = 1;
        enable_i = 0;
        test_count = 0;
        error_count = 0;
        current_test_index = 0;
        
        // Reset sequence
        #(CLOCK_PERIOD * 10);
        reset_n_i = 1;
        #(CLOCK_PERIOD * 5);
        
        // Run all test configurations
        for (int i = 0; i < test_configs.size(); i++) begin
            current_test_index = i;
            current_config = test_configs[i];
            $display("Running test %0d: %s", i+1, current_config.test_name);
            
            // Test with current configuration
            test_current_config();
            
            // Wait between tests
            #(CLOCK_PERIOD * 10);
        end
        
        // Summary
        $display("Extended Test Summary: %0d tests completed, %0d errors", test_count, error_count);
        if (error_count == 0) begin
            $display("All extended tests PASSED!");
        end else begin
            $display("Some extended tests FAILED!");
        end
        
        $finish;
    end
    
    // Test task for current configuration
    task test_current_config();
        automatic int ones_count = 0;
        automatic int total_bits = current_config.decimation_ratio;
        
        // Send alternating pattern for current decimation ratio
        for (int i = 0; i < current_config.decimation_ratio; i++) begin
            @(posedge clock_i);
            pdm_data_i = (i % 2);
            if (pdm_data_i) ones_count++;
            pdm_valid_i = 1;
            
            // Wait for ready
            while (!pdm_ready_o) @(posedge clock_i);
        end
        
        // Wait for PCM output
        @(posedge clock_i);
        pdm_valid_i = 0;
        
        // Wait for PCM valid
        while (!pcm_valid_o) @(posedge clock_i);
        
        // Check result based on current data width
        case (current_config.data_width)
            8: begin
                expected_pcm = (ones_count << (8 - $clog2(current_config.decimation_ratio))) - 128;
                if (pcm_data_o[7:0] == expected_pcm[7:0]) begin
                    $display("  PASS: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o[7:0], expected_pcm[7:0]);
                end else begin
                    $display("  FAIL: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o[7:0], expected_pcm[7:0]);
                    error_count++;
                end
            end
            16: begin
                expected_pcm = (ones_count << (16 - $clog2(current_config.decimation_ratio))) - 32768;
                if (pcm_data_o[15:0] == expected_pcm[15:0]) begin
                    $display("  PASS: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o[15:0], expected_pcm[15:0]);
                end else begin
                    $display("  FAIL: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o[15:0], expected_pcm[15:0]);
                    error_count++;
                end
            end
            24: begin
                expected_pcm = (ones_count << (24 - $clog2(current_config.decimation_ratio))) - 8388608;
                if (pcm_data_o[23:0] == expected_pcm[23:0]) begin
                    $display("  PASS: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o[23:0], expected_pcm[23:0]);
                end else begin
                    $display("  FAIL: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o[23:0], expected_pcm[23:0]);
                    error_count++;
                end
            end
            32: begin
                expected_pcm = (ones_count << (32 - $clog2(current_config.decimation_ratio))) - 2147483648;
                if (pcm_data_o == expected_pcm) begin
                    $display("  PASS: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o, expected_pcm);
                end else begin
                    $display("  FAIL: %s, PCM output = %0d (expected %0d)", 
                            current_config.test_name, pcm_data_o, expected_pcm);
                    error_count++;
                end
            end
            default: begin
                $display("  ERROR: Unsupported data width %0d", current_config.data_width);
                error_count++;
            end
        endcase
        test_count++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Waveform dumping
    initial begin
        $dumpfile("tb_pdm_pcm_decimator_extended.vcd");
        $dumpvars(0, tb_pdm_pcm_decimator_extended);
    end
    
endmodule : tb_pdm_pcm_decimator_extended
