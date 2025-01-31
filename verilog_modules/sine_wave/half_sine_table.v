`define SINE_SIZE 8
`define TABLE_SIZE 44
`define TABLE_REG_SIZE 6

module half_sine_table(
    output logic [`SINE_SIZE-1:0] sine_wave [0:`TABLE_SIZE-1],
    output logic [`TABLE_REG_SIZE-1:0] table_size
);
    initial begin
        table_size = `TABLE_SIZE-1;
        sine_wave[0] = 0;
        sine_wave[1] = 0;
        sine_wave[2] = 2;
        sine_wave[3] = 3;
        sine_wave[4] = 6;
        sine_wave[5] = 9;
        sine_wave[6] = 12;
        sine_wave[7] = 16;
        sine_wave[8] = 21;
        sine_wave[9] = 26;
        sine_wave[10] = 32;
        sine_wave[11] = 38;
        sine_wave[12] = 45;
        sine_wave[13] = 52;
        sine_wave[14] = 59;
        sine_wave[15] = 67;
        sine_wave[16] = 75;
        sine_wave[17] = 83;
        sine_wave[18] = 92;
        sine_wave[19] = 101;
        sine_wave[20] = 110;
        sine_wave[21] = 119;
        sine_wave[22] = 128;
        sine_wave[23] = 136;
        sine_wave[24] = 145;
        sine_wave[25] = 154;
        sine_wave[26] = 163;
        sine_wave[27] = 172;
        sine_wave[28] = 180;
        sine_wave[29] = 188;
        sine_wave[30] = 196;
        sine_wave[31] = 203;
        sine_wave[32] = 210;
        sine_wave[33] = 217;
        sine_wave[34] = 223;
        sine_wave[35] = 229;
        sine_wave[36] = 234;
        sine_wave[37] = 239;
        sine_wave[38] = 243;
        sine_wave[39] = 246;
        sine_wave[40] = 249;
        sine_wave[41] = 252;
        sine_wave[42] = 253;
        sine_wave[43] = 255;
    end
endmodule
