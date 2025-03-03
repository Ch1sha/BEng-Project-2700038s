`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: signal_gen_top
// Description: Top level module for signal generation that instantiates the
//              sine_wave module. This module interfaces with external FPGA I/O,
//              such as the system clock, reset, phase, and phase step inputs, and
//              provides a SINE_SIZE-bit sine wave output.
//////////////////////////////////////////////////////////////////////////////////

module signal_gen_top#(
    parameter SINE_SIZE = 12,
    parameter TABLE_SIZE = 268,
    parameter TABLE_REG_SIZE = 9,
    parameter PHASE_SIZE = 8 // resolution for phase input (from -180º to 180º)
) (
    input  wire                        clock,         // System clock input
    input  wire                        reset,         // Active-high reset signal
    input  wire signed [PHASE_SIZE:0]  phase,         // Phase input (-180º to 180º, resolution defined by PHASE_SIZE)
    input  wire signed [PHASE_SIZE:0]  phaseStep,     // Phase step input to control phase increment
    output wire [SINE_SIZE-1:0]          sine,          // 12-bit sine wave output
    output wire signed [PHASE_SIZE:0]  phaseIdxOut    // Phase index output from sine_wave module
    // Additional outputs can be added as required for your FPGA board
);

    // Instantiate the sine_wave module.
    sine_wave #(
        .SINE_SIZE(SINE_SIZE),
        .TABLE_SIZE(TABLE_SIZE),
        .TABLE_REG_SIZE(TABLE_REG_SIZE),
        .PHASE_SIZE(PHASE_SIZE)
    ) sine_wave_inst (
        .clock(clock),
        .reset(reset),
        .phase(phase),
        .phaseStep(phaseStep),
        .sine(sine),
        .phaseIdxOut(phaseIdxOut),
        .i()  // The 'i' output is unconnected in this top-level module
    );

endmodule
