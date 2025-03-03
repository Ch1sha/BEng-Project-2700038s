`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: half_sine_table
// Description: This module contains a lookup table for a half sine wave.
//              The table is parameterised by size and bit resolution.
//              It provides a read interface: given an address, it outputs the
//              corresponding sine value. The maximum valid address is also provided.
//////////////////////////////////////////////////////////////////////////////////

module half_sine_table #(
    parameter SINE_SIZE = 8,
    parameter TABLE_SIZE = 56,
    parameter TABLE_REG_SIZE = 6
) (
    input  wire [TABLE_REG_SIZE-1:0] addr,       // Address to access the sine value
    output reg  [SINE_SIZE-1:0]      data,       // Sine value at the given address
    output wire [TABLE_REG_SIZE-1:0] table_size  // Maximum valid address (TABLE_SIZE - 1)
);

    // Internal memory array for the half sine wave lookup table
    reg [SINE_SIZE-1:0] sine_wave [0:TABLE_SIZE-1];

    // Constant assignment for table_size
    assign table_size = TABLE_SIZE - 1;

    // Initialise the lookup table with the sine values
    initial begin
        sine_wave[0]  = 0;
        sine_wave[1]  = 0;
        sine_wave[2]  = 1;
        sine_wave[3]  = 2;
        sine_wave[4]  = 3;
        sine_wave[5]  = 5;
        sine_wave[6]  = 7;
        sine_wave[7]  = 10;
        sine_wave[8]  = 13;
        sine_wave[9]  = 16;
        sine_wave[10] = 20;
        sine_wave[11] = 24;
        sine_wave[12] = 28;
        sine_wave[13] = 32;
        sine_wave[14] = 37;
        sine_wave[15] = 43;
        sine_wave[16] = 48;
        sine_wave[17] = 54;
        sine_wave[18] = 60;
        sine_wave[19] = 66;
        sine_wave[20] = 72;
        sine_wave[21] = 79;
        sine_wave[22] = 85;
        sine_wave[23] = 92;
        sine_wave[24] = 99;
        sine_wave[25] = 106;
        sine_wave[26] = 113;
        sine_wave[27] = 120;
        sine_wave[28] = 128;
        sine_wave[29] = 135;
        sine_wave[30] = 142;
        sine_wave[31] = 149;
        sine_wave[32] = 156;
        sine_wave[33] = 163;
        sine_wave[34] = 170;
        sine_wave[35] = 176;
        sine_wave[36] = 183;
        sine_wave[37] = 189;
        sine_wave[38] = 195;
        sine_wave[39] = 201;
        sine_wave[40] = 207;
        sine_wave[41] = 212;
        sine_wave[42] = 218;
        sine_wave[43] = 223;
        sine_wave[44] = 227;
        sine_wave[45] = 231;
        sine_wave[46] = 235;
        sine_wave[47] = 239;
        sine_wave[48] = 242;
        sine_wave[49] = 245;
        sine_wave[50] = 248;
        sine_wave[51] = 250;
        sine_wave[52] = 252;
        sine_wave[53] = 253;
        sine_wave[54] = 254;
        sine_wave[55] = 255;
    end

    // Immediately output the sine value corresponding to the input address
    always @(*) begin
        data = sine_wave[addr];
    end

endmodule
