`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: adc_readout
// Description: Captures ADC data into a 4096‑byte buffer.
//              The ADC channel is assumed to deliver 8‑bit samples synchronously
//              with adc_clock. The capture is initiated with start_capture and
//              stops once the entire buffer is filled. A simple read interface
//              is provided for later processing.
//////////////////////////////////////////////////////////////////////////////////

module adc_readout #(
    parameter DATA_WIDTH = 12  // Parameter to define the width of the ADC input (adjust if ADC is 8-bit)
) (
    input  wire                    adc_clock,      // ADC clock
    input  wire                    reset,          // Synchronous reset (active high)
    input  wire                    start_capture,  // Signal to begin capturing ADC data
    input  wire [DATA_WIDTH-1:0]   adc_data,       // ADC sample data
    output reg                     capture_done,   // Flag that goes high when capture is complete
    // Read interface (e.g. for a processor or debug logic)
    input  wire [11:0]             read_addr,      // Address for reading out the stored data
    output wire [DATA_WIDTH-1:0]   read_data       // Output data from the buffer
);

    // Write pointer for the buffer – 12 bits to cover 4096 addresses.
    reg [11:0] write_ptr;
    // Flag to indicate that capture is ongoing.
    reg        capturing;

    // Instantiate the dual‑port buffer to store ADC data.
    adc_buffer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_adc_buffer (
        .clock      (adc_clock),
        .reset      (reset),
        .write_en   (capturing),    // Write enable is active during capture
        .write_addr (write_ptr),
        .data_in    (adc_data),
        .read_addr  (read_addr),
        .data_out   (read_data)
    );

    // ADC capture state machine
    always @(posedge adc_clock or posedge reset) begin
        if (reset) begin
            write_ptr    <= 12'd0;
            capturing    <= 1'b0;
            capture_done <= 1'b0;
        end else begin
            // Start capturing when start_capture is asserted and not already busy.
            if (start_capture && !capturing && !capture_done)
                capturing <= 1'b1;

            if (capturing) begin
                // Each clock cycle, the current adc_data is written to the buffer.
                // Increment the write pointer after each write.
                if (write_ptr == 12'd4095) begin
                    // Last address reached – capture is complete.
                    capturing    <= 1'b0;
                    capture_done <= 1'b1;
                end else begin
                    write_ptr <= write_ptr + 12'd1;
                end
            end
        end
    end

endmodule
