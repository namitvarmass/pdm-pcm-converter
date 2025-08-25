//=============================================================================
// PDM to PCM Decimation Filter
//=============================================================================
// Description: Converts PDM (Pulse Density Modulation) bitstream to PCM 
//              (Pulse Code Modulation) samples using a decimation filter
// Author: Vyges IP Development Team
// Date: 2025-08-25T13:26:01Z
// License: Apache-2.0
//=============================================================================

module pdm_pcm_decimator #(
    parameter int PDM_PCM_CONVERTER_DATA_WIDTH = 16,      // PCM output data width (8-32 bits)
    parameter int PDM_PCM_CONVERTER_DECIMATION_RATIO = 16, // Decimation ratio (2:1 to 48:1)
    parameter int PDM_PCM_CONVERTER_FILTER_ORDER = 4,     // Filter order for decimation
    parameter int PDM_PCM_CONVERTER_FIFO_DEPTH = 16       // FIFO depth for output buffering
)(
    // Clock and Reset
    input  logic                                    clock_i,
    input  logic                                    reset_n_i,
    
    // PDM Input Interface
    input  logic                                    pdm_data_i,      // PDM bitstream input
    input  logic                                    pdm_valid_i,     // PDM data valid
    output logic                                    pdm_ready_o,     // Ready to accept PDM data
    
    // PCM Output Interface
    output logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] pcm_data_o,     // PCM sample output
    output logic                                    pcm_valid_o,     // PCM data valid
    input  logic                                    pcm_ready_i,     // Downstream ready
    
    // Control Interface
    input  logic                                    enable_i,        // Module enable
    output logic                                    busy_o,          // Processing busy indicator
    output logic                                    overflow_o,      // FIFO overflow indicator
    output logic                                    underflow_o      // FIFO underflow indicator
);

    // Local parameters
    localparam int PDM_PCM_CONVERTER_COUNTER_WIDTH = $clog2(PDM_PCM_CONVERTER_DECIMATION_RATIO);
    localparam int PDM_PCM_CONVERTER_ACCUM_WIDTH = PDM_PCM_CONVERTER_DATA_WIDTH + PDM_PCM_CONVERTER_COUNTER_WIDTH;
    
    // Internal signals
    logic [PDM_PCM_CONVERTER_COUNTER_WIDTH-1:0] sample_counter;
    logic [PDM_PCM_CONVERTER_ACCUM_WIDTH-1:0] accumulator;
    logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] pcm_sample;
    logic sample_complete;
    logic fifo_full, fifo_empty;
    logic fifo_wr_en, fifo_rd_en;
    
    // State machine
    typedef enum logic [1:0] {
        PDM_PCM_CONVERTER_STATE_IDLE,
        PDM_PCM_CONVERTER_STATE_ACCUMULATE,
        PDM_PCM_CONVERTER_STATE_OUTPUT
    } pdm_pcm_converter_state_t;
    
    pdm_pcm_converter_state_t current_state, next_state;
    
    // Sample counter for decimation
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            sample_counter <= '0;
        end else if (enable_i && pdm_valid_i && pdm_ready_o) begin
            if (sample_counter == PDM_PCM_CONVERTER_DECIMATION_RATIO - 1) begin
                sample_counter <= '0;
            end else begin
                sample_counter <= sample_counter + 1'b1;
            end
        end
    end
    
    // Sample complete detection
    assign sample_complete = (sample_counter == PDM_PCM_CONVERTER_DECIMATION_RATIO - 1) && 
                            (pdm_valid_i && pdm_ready_o);
    
    // Accumulator for PDM to PCM conversion
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            accumulator <= '0;
        end else if (enable_i && pdm_valid_i && pdm_ready_o) begin
            if (sample_complete) begin
                // Reset accumulator for next sample
                accumulator <= (pdm_data_i ? 1 : 0);
            end else begin
                // Accumulate PDM bits
                accumulator <= accumulator + (pdm_data_i ? 1 : 0);
            end
        end
    end
    
    // PCM sample calculation (scaling and centering)
    always_comb begin
        // Scale accumulator to PCM range and center around zero
        pcm_sample = (accumulator << (PDM_PCM_CONVERTER_DATA_WIDTH - PDM_PCM_CONVERTER_COUNTER_WIDTH)) - 
                     (1 << (PDM_PCM_CONVERTER_DATA_WIDTH - 1));
    end
    
    // FIFO write enable
    assign fifo_wr_en = sample_complete && !fifo_full;
    
    // State machine sequential logic
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            current_state <= PDM_PCM_CONVERTER_STATE_IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    // State machine combinational logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            PDM_PCM_CONVERTER_STATE_IDLE: begin
                if (enable_i) begin
                    next_state = PDM_PCM_CONVERTER_STATE_ACCUMULATE;
                end
            end
            
            PDM_PCM_CONVERTER_STATE_ACCUMULATE: begin
                if (sample_complete) begin
                    next_state = PDM_PCM_CONVERTER_STATE_OUTPUT;
                end
            end
            
            PDM_PCM_CONVERTER_STATE_OUTPUT: begin
                if (fifo_rd_en) begin
                    next_state = PDM_PCM_CONVERTER_STATE_ACCUMULATE;
                end
            end
            
            default: begin
                next_state = PDM_PCM_CONVERTER_STATE_IDLE;
            end
        endcase
    end
    
    // Output FIFO for PCM samples
    fifo_sync #(
        .PDM_PCM_CONVERTER_DATA_WIDTH(PDM_PCM_CONVERTER_DATA_WIDTH),
        .PDM_PCM_CONVERTER_FIFO_DEPTH(PDM_PCM_CONVERTER_FIFO_DEPTH)
    ) pcm_fifo (
        .clock_i(clock_i),
        .reset_n_i(reset_n_i),
        .wr_en_i(fifo_wr_en),
        .wr_data_i(pcm_sample),
        .rd_en_i(fifo_rd_en),
        .rd_data_o(pcm_data_o),
        .full_o(fifo_full),
        .empty_o(fifo_empty),
        .overflow_o(overflow_o),
        .underflow_o(underflow_o)
    );
    
    // Output control signals
    assign pdm_ready_o = enable_i && !fifo_full && (current_state == PDM_PCM_CONVERTER_STATE_ACCUMULATE);
    assign fifo_rd_en = pcm_ready_i && !fifo_empty && (current_state == PDM_PCM_CONVERTER_STATE_OUTPUT);
    assign pcm_valid_o = !fifo_empty && (current_state == PDM_PCM_CONVERTER_STATE_OUTPUT);
    assign busy_o = (current_state != PDM_PCM_CONVERTER_STATE_IDLE);
    
endmodule : pdm_pcm_decimator

//=============================================================================
// Synchronous FIFO Module
//=============================================================================
module fifo_sync #(
    parameter int PDM_PCM_CONVERTER_DATA_WIDTH = 16,      // Data width (8-32 bits)
    parameter int PDM_PCM_CONVERTER_FIFO_DEPTH = 16       // FIFO depth
)(
    input  logic                                    clock_i,
    input  logic                                    reset_n_i,
    input  logic                                    wr_en_i,
    input  logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] wr_data_i,
    input  logic                                    rd_en_i,
    output logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] rd_data_o,
    output logic                                    full_o,
    output logic                                    empty_o,
    output logic                                    overflow_o,
    output logic                                    underflow_o
);

    localparam int PDM_PCM_CONVERTER_ADDR_WIDTH = $clog2(PDM_PCM_CONVERTER_FIFO_DEPTH);
    
    logic [PDM_PCM_CONVERTER_DATA_WIDTH-1:0] fifo_memory [PDM_PCM_CONVERTER_FIFO_DEPTH-1:0];
    logic [PDM_PCM_CONVERTER_ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [PDM_PCM_CONVERTER_ADDR_WIDTH:0] count;
    
    // Memory array
    always_ff @(posedge clock_i) begin
        if (wr_en_i && !full_o) begin
            fifo_memory[wr_ptr] <= wr_data_i;
        end
    end
    
    // Read data output
    assign rd_data_o = fifo_memory[rd_ptr];
    
    // Write pointer
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            wr_ptr <= '0;
        end else if (wr_en_i && !full_o) begin
            wr_ptr <= (wr_ptr == PDM_PCM_CONVERTER_FIFO_DEPTH - 1) ? '0 : wr_ptr + 1'b1;
        end
    end
    
    // Read pointer
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            rd_ptr <= '0;
        end else if (rd_en_i && !empty_o) begin
            rd_ptr <= (rd_ptr == PDM_PCM_CONVERTER_FIFO_DEPTH - 1) ? '0 : rd_ptr + 1'b1;
        end
    end
    
    // Counter for full/empty detection
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            count <= '0;
        end else begin
            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10: count <= count + 1'b1;  // Write only
                2'b01: count <= count - 1'b1;  // Read only
                2'b11: count <= count;         // Read and write
                default: count <= count;       // No operation
            endcase
        end
    end
    
    // Status signals
    assign full_o = (count == PDM_PCM_CONVERTER_FIFO_DEPTH);
    assign empty_o = (count == 0);
    assign overflow_o = wr_en_i && full_o;
    assign underflow_o = rd_en_i && empty_o;
    
endmodule : fifo_sync
