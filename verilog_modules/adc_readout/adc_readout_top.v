`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: adc_readout_top
// Description: 
//   Top-level module for interfacing with adc_readout. Provides external 
//   connectivity to ADC clock, reset, control signals, and read interface.
//////////////////////////////////////////////////////////////////////////////////

module adc_readout_top #(
    parameter DATA_WIDTH = 12  // Parameter defining ADC data width (adjustable)
) (
    input  wire                    adc_clock,      // ADC clock input
    input  wire                    reset,          // Active-high reset
    input  wire                    start_capture,  // Trigger signal for ADC capture
    input  wire [DATA_WIDTH-1:0]   adc_data,       // ADC data input
    output reg                     capture_done,   // Capture complete flag

    // Readout interface for external processing
    input  wire [11:0]             read_addr,      // Address input for reading stored data
    output reg [DATA_WIDTH-1:0]    read_data       // Data output from the captured buffer
);

    // Instantiate the adc_readout module
    adc_readout #(
        .DATA_WIDTH(DATA_WIDTH)
    ) adc_readout_inst (
        .adc_clock(adc_clock),
        .reset(reset),
        .start_capture(start_capture),
        .adc_data(adc_data),
        .capture_done(capture_done),
        .read_addr(read_addr),
        .read_data(read_data)
    );

endmodule
