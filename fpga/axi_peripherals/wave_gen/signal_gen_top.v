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
    input  wire                             clock,         // System clock input
    input  wire                             reset,         // Active-high reset signal, will act as active low enable signal
    input  wire signed [PHASE_SIZE:0]       phase,         // Phase input (-180º to 180º, resolution defined by PHASE_SIZE)
    input  wire signed [PHASE_SIZE:0]       phaseStep,     // Phase step input to control phase increment
    output reg [SINE_SIZE-1:0]              sine         // 12-bit sine wave output
);

    // Internal signal to connect to the sine wave output
    wire [SINE_SIZE-1:0] sine_val;

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
        .sine(sine_val)
    );

    // The reset signal will also act as the enable signal for the sine wave output
    // Active high for the reset, active low for the enable
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            sine <= 0;
        end else begin
            sine <= sine_val;
        end
    end

endmodule
