`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: adc_buffer
// Description: A dual‑port RAM with 4096 (2^12) locations of 8‑bit width.
//              One port is used for writing ADC samples, and the other for
//              reading the buffered data.
//////////////////////////////////////////////////////////////////////////////////

module adc_buffer #(
    parameter DATA_WIDTH = 12  // Parameter to define the width of the ADC input
    parameter BUFFER_SIZE = 4096 // Parameter to define the buffer size
    parameter ADDR_WIDTH = 12 // Parameter to define the address width (log2(BUFFER_SIZE))
) (
    input  logic        clock,       // Common clock (assumed same for read & write)
    input  logic        reset,       // Synchronous reset (if desired; see note below)
    // Write port
    input  logic        write_en,    // Write enable signal (active high)
    input  logic [ADDR_WIDTH-1:0] write_addr,  // 12‑bit write address (0 to 4095)
    input  logic [DATA_WIDTH-1:0] data_in, // ADC sample input (parameterized width)
    // Read port
    input  logic [ADDR_WIDTH-1:0] read_addr,   // 12‑bit read address
    output logic [DATA_WIDTH-1:0] data_out // Data output (parameterized width)
);

    logic [DATA_WIDTH-1:0] memory [0:BUFFER_SIZE-1]; // 4096 locations of 8‑bit width

    // Write and read – note that many FPGAs support inferring a dual‑port block RAM
    always @(posedge clock) begin
        if (reset) begin
            // wipe memory
            for (i = 0; i < 4096; i = i + 1) begin
                memory[i] <= 8'h00;
            end
        end else begin
            if (write_en)
                memory[write_addr] <= data_in;
            // Read operation (synchronous read)
        end
    end

endmodule
