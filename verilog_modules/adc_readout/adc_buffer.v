`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: adc_buffer
// Description: A dual‑port RAM with 4096 (2^12) locations of 8‑bit width.
//              One port is used for writing ADC samples, and the other for
//              reading the buffered data.
//////////////////////////////////////////////////////////////////////////////////

module adc_buffer (
    input  logic        clk,         // Common clock (assumed same for read & write)
    input  logic        rst,         // Synchronous reset (if desired; see note below)
    // Write port
    input  logic        we,          // Write enable signal (active high)
    input  logic [11:0] write_addr,  // 12‑bit write address (0 to 4095)
    input  logic [7:0]  data_in,     // ADC sample input (8‑bit)
    // Read port
    input  logic [11:0] read_addr,   // 12‑bit read address
    output reg [7:0]  data_out     // Data output
);

    // Declare the memory array
    reg [7:0] mem [0:4095];

    // Write and read – note that many FPGAs support inferring a dual‑port block RAM
    always @(posedge clk) begin
        if (rst) begin
            // Optionally, you could initialise or clear the memory here if needed.
            // For many designs, you might not require memory initialisation.
        end else begin
            if (we)
                mem[write_addr] <= data_in;
            // Read operation (synchronous read)
            data_out <= mem[read_addr];
        end
    end

endmodule
