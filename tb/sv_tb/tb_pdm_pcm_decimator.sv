//=============================================================================
// PDM to PCM Decimator Testbench
//=============================================================================
// Description: Testbench for PDM to PCM decimation filter
// Author: Vyges IP Development Team
// Date: 2025-08-25T13:26:01Z
// License: Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module tb_pdm_pcm_decimator;

    // Testbench parameters
    localparam int PDM_PCM_CONVERTER_DATA_WIDTH = 16;
    localparam int PDM_PCM_CONVERTER_DECIMATION_RATIO = 16; // Updated to new range
    localparam int PDM_PCM_CONVERTER_FIFO_DEPTH = 16;
    localparam int CLOCK_PERIOD = 10; // 100MHz clock
    
    // Clock and reset signals
    logic clock_i;
    logic reset_n_i;
    
    // DUT interface signals
    logic pdm_data_i;
    logic pdm_valid_i;
    logic pdm_ready_o;
    logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] pcm_data_o;
    logic pcm_valid_o;
    logic pcm_ready_i;
    logic enable_i;
    logic busy_o;
    logic overflow_o;
    logic underflow_o;
    
    // Testbench variables
    int test_count;
    int error_count;
    logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] expected_pcm;
    logic [PDM_PCM_CONVERTER_DECIMATION_RATIO-1:0] pdm_pattern;
    
    // Clock generation
    initial begin
        clock_i = 0;
        forever #(CLOCK_PERIOD/2) clock_i = ~clock_i;
    end
    
    // DUT instantiation
    pdm_pcm_decimator #(
        .PDM_PCM_CONVERTER_DATA_WIDTH(PDM_PCM_CONVERTER_DATA_WIDTH),
        .PDM_PCM_CONVERTER_DECIMATION_RATIO(PDM_PCM_CONVERTER_DECIMATION_RATIO),
        .PDM_PCM_CONVERTER_FIFO_DEPTH(PDM_PCM_CONVERTER_FIFO_DEPTH)
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
        
        // Reset sequence
        #(CLOCK_PERIOD * 10);
        reset_n_i = 1;
        #(CLOCK_PERIOD * 5);
        
        // Enable the module
        enable_i = 1;
        
        // Test 1: All zeros PDM pattern
        $display("Test 1: All zeros PDM pattern");
        test_all_zeros();
        
        // Test 2: All ones PDM pattern
        $display("Test 2: All ones PDM pattern");
        test_all_ones();
        
        // Test 3: Alternating PDM pattern
        $display("Test 3: Alternating PDM pattern");
        test_alternating();
        
        // Test 4: Random PDM pattern
        $display("Test 4: Random PDM pattern");
        test_random_pattern();
        
        // Test 5: Backpressure test
        $display("Test 5: Backpressure test");
        test_backpressure();
        
        // Test 6: Overflow test
        $display("Test 6: Overflow test");
        test_overflow();
        
        // Summary
        $display("Test Summary: %0d tests completed, %0d errors", test_count, error_count);
        if (error_count == 0) begin
            $display("All tests PASSED!");
        end else begin
            $display("Some tests FAILED!");
        end
        
        $finish;
    end
    
    // Test task: All zeros pattern
    task test_all_zeros();
        automatic int ones_count = 0;
        automatic int total_bits = PDM_PCM_CONVERTER_DECIMATION_RATIO;
        
        // Send all zeros
        for (int i = 0; i < PDM_PCM_CONVERTER_DECIMATION_RATIO; i++) begin
            @(posedge clock_i);
            pdm_data_i = 0;
            pdm_valid_i = 1;
            
            // Wait for ready
            while (!pdm_ready_o) @(posedge clock_i);
        end
        
        // Wait for PCM output
        @(posedge clock_i);
        pdm_valid_i = 0;
        
        // Wait for PCM valid
        while (!pcm_valid_o) @(posedge clock_i);
        
        // Check result
        expected_pcm = (ones_count << (PDM_PCM_CONVERTER_DATA_WIDTH - $clog2(PDM_PCM_CONVERTER_DECIMATION_RATIO))) - 
                      (1 << (PDM_PCM_CONVERTER_DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: All zeros pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
        end else begin
            $display("  FAIL: All zeros pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        test_count++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: All ones pattern
    task test_all_ones();
        automatic int ones_count = PDM_PCM_CONVERTER_DECIMATION_RATIO;
        automatic int total_bits = PDM_PCM_CONVERTER_DECIMATION_RATIO;
        
        // Send all ones
        for (int i = 0; i < PDM_PCM_CONVERTER_DECIMATION_RATIO; i++) begin
            @(posedge clock_i);
            pdm_data_i = 1;
            pdm_valid_i = 1;
            
            // Wait for ready
            while (!pdm_ready_o) @(posedge clock_i);
        end
        
        // Wait for PCM output
        @(posedge clock_i);
        pdm_valid_i = 0;
        
        // Wait for PCM valid
        while (!pcm_valid_o) @(posedge clock_i);
        
        // Check result
        expected_pcm = (ones_count << (PDM_PCM_CONVERTER_DATA_WIDTH - $clog2(PDM_PCM_CONVERTER_DECIMATION_RATIO))) - 
                      (1 << (PDM_PCM_CONVERTER_DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: All ones pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
        end else begin
            $display("  FAIL: All ones pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        test_count++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Alternating pattern
    task test_alternating();
        automatic int ones_count = PDM_PCM_CONVERTER_DECIMATION_RATIO / 2;
        automatic int total_bits = PDM_PCM_CONVERTER_DECIMATION_RATIO;
        
        // Send alternating pattern
        for (int i = 0; i < PDM_PCM_CONVERTER_DECIMATION_RATIO; i++) begin
            @(posedge clock_i);
            pdm_data_i = (i % 2);
            pdm_valid_i = 1;
            
            // Wait for ready
            while (!pdm_ready_o) @(posedge clock_i);
        end
        
        // Wait for PCM output
        @(posedge clock_i);
        pdm_valid_i = 0;
        
        // Wait for PCM valid
        while (!pcm_valid_o) @(posedge clock_i);
        
        // Check result
        expected_pcm = (ones_count << (PDM_PCM_CONVERTER_DATA_WIDTH - $clog2(PDM_PCM_CONVERTER_DECIMATION_RATIO))) - 
                      (1 << (PDM_PCM_CONVERTER_DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: Alternating pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
        end else begin
            $display("  FAIL: Alternating pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        test_count++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Random pattern
    task test_random_pattern();
        automatic int ones_count = 0;
        automatic int total_bits = PDM_PCM_CONVERTER_DECIMATION_RATIO;
        
        // Generate random pattern
        for (int i = 0; i < PDM_PCM_CONVERTER_DECIMATION_RATIO; i++) begin
            @(posedge clock_i);
            pdm_data_i = $random % 2;
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
        
        // Check result
        expected_pcm = (ones_count << (PDM_PCM_CONVERTER_DATA_WIDTH - $clog2(PDM_PCM_CONVERTER_DECIMATION_RATIO))) - 
                      (1 << (PDM_PCM_CONVERTER_DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: Random pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
        end else begin
            $display("  FAIL: Random pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        test_count++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Backpressure test
    task test_backpressure();
        // Disable downstream ready
        pcm_ready_i = 0;
        
        // Send multiple samples
        for (int sample = 0; sample < 3; sample++) begin
            for (int i = 0; i < PDM_PCM_CONVERTER_DECIMATION_RATIO; i++) begin
                @(posedge clock_i);
                pdm_data_i = $random % 2;
                pdm_valid_i = 1;
                
                // Wait for ready
                while (!pdm_ready_o) @(posedge clock_i);
            end
            @(posedge clock_i);
            pdm_valid_i = 0;
        end
        
        // Re-enable downstream ready
        pcm_ready_i = 1;
        
        // Check that no overflow occurred
        if (!overflow_o) begin
            $display("  PASS: Backpressure test - no overflow");
        end else begin
            $display("  FAIL: Backpressure test - overflow detected");
            error_count++;
        end
        test_count++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Overflow test
    task test_overflow();
        // Fill FIFO to capacity
        pcm_ready_i = 0;
        
        // Send more samples than FIFO can hold
        for (int sample = 0; sample < PDM_PCM_CONVERTER_FIFO_DEPTH + 2; sample++) begin
            for (int i = 0; i < PDM_PCM_CONVERTER_DECIMATION_RATIO; i++) begin
                @(posedge clock_i);
                pdm_data_i = 1;
                pdm_valid_i = 1;
                
                // Wait for ready
                while (!pdm_ready_o) @(posedge clock_i);
            end
            @(posedge clock_i);
            pdm_valid_i = 0;
        end
        
        // Check overflow flag
        if (overflow_o) begin
            $display("  PASS: Overflow test - overflow correctly detected");
        end else begin
            $display("  FAIL: Overflow test - overflow not detected");
            error_count++;
        end
        test_count++;
        
        // Re-enable downstream ready
        pcm_ready_i = 1;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Waveform dumping
    initial begin
        $dumpfile("tb_pdm_pcm_decimator.vcd");
        $dumpvars(0, tb_pdm_pcm_decimator);
    end
    
endmodule : tb_pdm_pcm_decimator
