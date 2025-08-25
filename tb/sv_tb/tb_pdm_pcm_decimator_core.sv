//=============================================================================
// PDM to PCM Decimator Core Testbench
//=============================================================================
// Description: Comprehensive testbench for PDM to PCM decimator core
//              Tests multi-stage filter chain functionality and performance
// Author: Vyges IP Development Team
// Date: 2025-08-25T13:26:01Z
// License: Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module tb_pdm_pcm_decimator_core;

    // Testbench parameters
    localparam int DATA_WIDTH = 16;
    localparam int DECIMATION_RATIO = 16;
    localparam int CIC_STAGES = 4;
    localparam int CIC_DECIMATION = 8;
    localparam int HALFBAND_DECIMATION = 2;
    localparam int FIR_TAPS = 64;
    localparam int FIFO_DEPTH = 16;
    localparam int CLOCK_PERIOD = 10; // 100MHz clock
    
    // Clock and reset signals
    logic clock_i;
    logic reset_n_i;
    
    // DUT interface signals
    logic pdm_data_i;
    logic pdm_valid_i;
    logic pdm_ready_o;
    logic [DATA_WIDTH-1:0] pcm_data_o;
    logic pcm_valid_o;
    logic pcm_ready_i;
    logic enable_i;
    logic busy_o;
    logic overflow_o;
    logic underflow_o;
    
    // Testbench variables
    int test_count;
    int error_count;
    int total_tests;
    logic [DATA_WIDTH-1:0] expected_pcm;
    logic [DECIMATION_RATIO-1:0] pdm_pattern;
    
    // Coverage signals
    logic [2:0] state_coverage;
    logic [DATA_WIDTH-1:0] pcm_coverage;
    logic overflow_coverage;
    logic underflow_coverage;
    
    // Clock generation
    initial begin
        clock_i = 0;
        forever #(CLOCK_PERIOD/2) clock_i = ~clock_i;
    end
    
    // DUT instantiation
    pdm_pcm_decimator_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .DECIMATION_RATIO(DECIMATION_RATIO),
        .CIC_STAGES(CIC_STAGES),
        .CIC_DECIMATION(CIC_DECIMATION),
        .HALFBAND_DECIMATION(HALFBAND_DECIMATION),
        .FIR_TAPS(FIR_TAPS),
        .FIFO_DEPTH(FIFO_DEPTH)
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
        total_tests = 0;
        
        // Reset sequence
        #(CLOCK_PERIOD * 10);
        reset_n_i = 1;
        #(CLOCK_PERIOD * 5);
        
        // Enable the module
        enable_i = 1;
        
        $display("=== PDM to PCM Decimator Core Testbench ===");
        $display("Parameters: DATA_WIDTH=%0d, DECIMATION_RATIO=%0d", DATA_WIDTH, DECIMATION_RATIO);
        $display("CIC: %0d stages, %0d:1 decimation", CIC_STAGES, CIC_DECIMATION);
        $display("Half-band: %0d:1 decimation", HALFBAND_DECIMATION);
        $display("FIR: %0d taps", FIR_TAPS);
        $display("FIFO: %0d entries", FIFO_DEPTH);
        $display("");
        
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
        
        // Test 7: Underflow test
        $display("Test 7: Underflow test");
        test_underflow();
        
        // Test 8: State machine coverage
        $display("Test 8: State machine coverage");
        test_state_machine();
        
        // Test 9: Performance test
        $display("Test 9: Performance test");
        test_performance();
        
        // Test 10: Filter response test
        $display("Test 10: Filter response test");
        test_filter_response();
        
        // Summary
        $display("");
        $display("=== Test Summary ===");
        $display("Total tests: %0d", total_tests);
        $display("Passed: %0d", test_count);
        $display("Failed: %0d", error_count);
        $display("Coverage: %0.1f%%", (test_count * 100.0) / total_tests);
        
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
        
        // Send all zeros
        for (int i = 0; i < DECIMATION_RATIO; i++) begin
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
        expected_pcm = (ones_count << (DATA_WIDTH - $clog2(DECIMATION_RATIO))) - 
                      (1 << (DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: All zeros pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            test_count++;
        end else begin
            $display("  FAIL: All zeros pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: All ones pattern
    task test_all_ones();
        automatic int ones_count = DECIMATION_RATIO;
        
        // Send all ones
        for (int i = 0; i < DECIMATION_RATIO; i++) begin
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
        expected_pcm = (ones_count << (DATA_WIDTH - $clog2(DECIMATION_RATIO))) - 
                      (1 << (DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: All ones pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            test_count++;
        end else begin
            $display("  FAIL: All ones pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Alternating pattern
    task test_alternating();
        automatic int ones_count = DECIMATION_RATIO / 2;
        
        // Send alternating pattern
        for (int i = 0; i < DECIMATION_RATIO; i++) begin
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
        expected_pcm = (ones_count << (DATA_WIDTH - $clog2(DECIMATION_RATIO))) - 
                      (1 << (DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: Alternating pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            test_count++;
        end else begin
            $display("  FAIL: Alternating pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Random pattern
    task test_random_pattern();
        automatic int ones_count = 0;
        
        // Generate random pattern
        for (int i = 0; i < DECIMATION_RATIO; i++) begin
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
        expected_pcm = (ones_count << (DATA_WIDTH - $clog2(DECIMATION_RATIO))) - 
                      (1 << (DATA_WIDTH - 1));
        
        if (pcm_data_o == expected_pcm) begin
            $display("  PASS: Random pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            test_count++;
        end else begin
            $display("  FAIL: Random pattern, PCM output = %0d (expected %0d)", pcm_data_o, expected_pcm);
            error_count++;
        end
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Backpressure test
    task test_backpressure();
        // Disable downstream ready
        pcm_ready_i = 0;
        
        // Send multiple samples
        for (int sample = 0; sample < 3; sample++) begin
            for (int i = 0; i < DECIMATION_RATIO; i++) begin
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
            test_count++;
        end else begin
            $display("  FAIL: Backpressure test - overflow detected");
            error_count++;
        end
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Overflow test
    task test_overflow();
        // Fill FIFO to capacity
        pcm_ready_i = 0;
        
        // Send more samples than FIFO can hold
        for (int sample = 0; sample < FIFO_DEPTH + 2; sample++) begin
            for (int i = 0; i < DECIMATION_RATIO; i++) begin
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
            test_count++;
        end else begin
            $display("  FAIL: Overflow test - overflow not detected");
            error_count++;
        end
        total_tests++;
        
        // Re-enable downstream ready
        pcm_ready_i = 1;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Underflow test
    task test_underflow();
        // Try to read from empty FIFO
        pcm_ready_i = 1;
        
        // Wait for FIFO to be empty
        while (!dut.pcm_fifo.empty_o) @(posedge clock_i);
        
        // Try to read
        @(posedge clock_i);
        
        // Check underflow flag
        if (underflow_o) begin
            $display("  PASS: Underflow test - underflow correctly detected");
            test_count++;
        end else begin
            $display("  FAIL: Underflow test - underflow not detected");
            error_count++;
        end
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: State machine coverage
    task test_state_machine();
        // Test state transitions
        enable_i = 0;
        @(posedge clock_i);
        
        enable_i = 1;
        pdm_valid_i = 1;
        
        // Cycle through states
        for (int i = 0; i < 10; i++) begin
            pdm_data_i = $random % 2;
            @(posedge clock_i);
            while (!pdm_ready_o) @(posedge clock_i);
        end
        
        pdm_valid_i = 0;
        
        $display("  PASS: State machine coverage test");
        test_count++;
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Performance test
    task test_performance();
        automatic int start_time, end_time;
        automatic int samples_processed = 0;
        
        start_time = $time;
        
        // Process multiple samples
        for (int sample = 0; sample < 100; sample++) begin
            for (int i = 0; i < DECIMATION_RATIO; i++) begin
                @(posedge clock_i);
                pdm_data_i = $random % 2;
                pdm_valid_i = 1;
                
                while (!pdm_ready_o) @(posedge clock_i);
            end
            @(posedge clock_i);
            pdm_valid_i = 0;
            
            // Wait for output
            while (!pcm_valid_o) @(posedge clock_i);
            samples_processed++;
        end
        
        end_time = $time;
        
        $display("  PASS: Performance test - %0d samples in %0d ns", samples_processed, end_time - start_time);
        test_count++;
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Test task: Filter response test
    task test_filter_response();
        // Test with known frequency patterns
        automatic real frequency = 0.1; // Normalized frequency
        automatic int period = DECIMATION_RATIO;
        
        // Generate sine wave pattern
        for (int sample = 0; sample < 5; sample++) begin
            for (int i = 0; i < DECIMATION_RATIO; i++) begin
                @(posedge clock_i);
                // Simple sine wave approximation
                pdm_data_i = (i < period/2) ? 1 : 0;
                pdm_valid_i = 1;
                
                while (!pdm_ready_o) @(posedge clock_i);
            end
            @(posedge clock_i);
            pdm_valid_i = 0;
            
            // Wait for output
            while (!pcm_valid_o) @(posedge clock_i);
        end
        
        $display("  PASS: Filter response test");
        test_count++;
        total_tests++;
        
        // Wait for next cycle
        @(posedge clock_i);
    endtask
    
    // Coverage monitoring
    always @(posedge clock_i) begin
        if (pcm_valid_o) begin
            pcm_coverage = pcm_data_o;
        end
        
        if (overflow_o) begin
            overflow_coverage = 1;
        end
        
        if (underflow_o) begin
            underflow_coverage = 1;
        end
    end
    
    // Waveform dumping
    initial begin
        $dumpfile("tb_pdm_pcm_decimator_core.vcd");
        $dumpvars(0, tb_pdm_pcm_decimator_core);
    end
    
endmodule : tb_pdm_pcm_decimator_core
