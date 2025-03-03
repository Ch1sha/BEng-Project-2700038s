`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: adc_buffer
// Description: A dual‑port RAM with BUFFER_SIZE (2^ADDR_WIDTH) locations of DATA_WIDTH‑bit width.
//              One port is used for writing ADC samples, and the other for
//              reading the buffered data.
//////////////////////////////////////////////////////////////////////////////////

module adc_buffer #(
    parameter DATA_WIDTH  = 12,     // Parameter to define the width of the ADC input
    parameter BUFFER_SIZE = 4096,   // Parameter to define the buffer size
    parameter ADDR_WIDTH  = 12      // Parameter to define the address width (log2(BUFFER_SIZE))
) (
    input  wire                      clock,       // Common clock (assumed same for read & write)
    input  wire                      reset,       // Synchronous reset
    // Write port
    input  wire                      write_en,    // Write enable signal (active high)
    input  wire [ADDR_WIDTH-1:0]     write_addr,  // 12‑bit write address (0 to 4095)
    input  wire [DATA_WIDTH-1:0]     data_in,     // ADC sample input
    // Read port
    input  wire [ADDR_WIDTH-1:0]     read_addr,   // 12‑bit read address
    output reg  [DATA_WIDTH-1:0]     data_out     // Data output
);

    // Declare memory array with specified width and size
    reg [DATA_WIDTH-1:0] memory [0:BUFFER_SIZE-1];

    integer i;  // Declare loop variable

    // Synchronous reset and write operations
    always @(posedge clock) begin
        if (reset) begin
            // Wipe memory using a loop variable
            for (i = 0; i < BUFFER_SIZE; i = i + 1) begin
                memory[i] <= {DATA_WIDTH{1'b0}};  // Initialize memory with zeros
            end
        end else begin
            if (write_en)
                memory[write_addr] <= data_in;
            // Synchronous read operation
            data_out <= memory[read_addr];
        end
    end

endmodule
