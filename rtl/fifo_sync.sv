//=============================================================================
// Synchronous FIFO Module
//=============================================================================
// Description: Synchronous FIFO with configurable data width and depth
//              Supports overflow/underflow detection and flow control
// Author: Vyges IP Development Team
// Date: 2025-08-25T13:26:01Z
// License: Apache-2.0
//=============================================================================

module fifo_sync #(
    parameter int DATA_WIDTH = 16,      // Data width in bits
    parameter int FIFO_DEPTH = 16       // FIFO depth in entries
)(
    // Clock and Reset (Vyges standard interface)
    input  logic                                    clock_i,
    input  logic                                    reset_n_i,
    
    // Write Interface
    input  logic                                    wr_en_i,
    input  logic [DATA_WIDTH-1:0]                   wr_data_i,
    
    // Read Interface
    input  logic                                    rd_en_i,
    output logic [DATA_WIDTH-1:0]                   rd_data_o,
    
    // Status Interface
    output logic                                    full_o,
    output logic                                    empty_o,
    output logic                                    overflow_o,
    output logic                                    underflow_o
);

    // Local parameters
    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);
    
    // Internal signals
    logic [DATA_WIDTH-1:0] fifo_memory [FIFO_DEPTH-1:0];
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [ADDR_WIDTH:0] count;
    
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
            wr_ptr <= (wr_ptr == FIFO_DEPTH - 1) ? '0 : wr_ptr + 1'b1;
        end
    end
    
    // Read pointer
    always_ff @(posedge clock_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            rd_ptr <= '0;
        end else if (rd_en_i && !empty_o) begin
            rd_ptr <= (rd_ptr == FIFO_DEPTH - 1) ? '0 : rd_ptr + 1'b1;
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
    assign full_o = (count == FIFO_DEPTH);
    assign empty_o = (count == 0);
    assign overflow_o = wr_en_i && full_o;
    assign underflow_o = rd_en_i && empty_o;
    
endmodule : fifo_sync
