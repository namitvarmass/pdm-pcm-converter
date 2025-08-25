//=============================================================================
// PDM to PCM Decimator Integration Wrapper
//=============================================================================
// Description: Integration wrapper for PDM to PCM decimation filter
//              Provides simplified interface and parameter configuration
// Author: Vyges IP Development Team
// Date: 2025-08-25T13:26:01Z
// License: Apache-2.0
//=============================================================================

module pdm_pcm_decimator_wrapper #(
    parameter int PDM_PCM_CONVERTER_DATA_WIDTH = 16,      // PCM output data width (8-32 bits)
    parameter int PDM_PCM_CONVERTER_DECIMATION_RATIO = 16, // Decimation ratio (2:1 to 48:1)
    parameter int PDM_PCM_CONVERTER_FIFO_DEPTH = 16       // FIFO depth
)(
    // Clock and Reset
    input  wire                                    clk,
    input  wire                                    rst_n,
    
    // PDM Input Interface (simplified)
    input  wire                                    pdm_in,
    input  wire                                    pdm_valid,
    output wire                                    pdm_ready,
    
    // PCM Output Interface (simplified)
    output wire [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] pcm_out,
    output wire                                    pcm_valid,
    input  wire                                    pcm_ready,
    
    // Status and Control
    input  wire                                    enable,
    output wire                                    busy,
    output wire                                    overflow,
    output wire                                    underflow
);

    // Instantiate the main PDM to PCM decimator
    pdm_pcm_decimator #(
        .PDM_PCM_CONVERTER_DATA_WIDTH(PDM_PCM_CONVERTER_DATA_WIDTH),
        .PDM_PCM_CONVERTER_DECIMATION_RATIO(PDM_PCM_CONVERTER_DECIMATION_RATIO),
        .PDM_PCM_CONVERTER_FIFO_DEPTH(PDM_PCM_CONVERTER_FIFO_DEPTH)
    ) pdm_pcm_decimator_inst (
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

endmodule : pdm_pcm_decimator_wrapper
