`define SINE_SIZE 8
`define TABLE_SIZE 64
`define TABLE_REG_SIZE 7

module half_sine_table(
    output logic [`SINE_SIZE-1:0] sine_wave [0:`TABLE_SIZE-1],
    output logic [`TABLE_REG_SIZE-1:0] table_size
);
    initial begin
        table_size = `TABLE_SIZE-1;
        sine_wave[0] = 0;
        sine_wave[1] = 0;
        sine_wave[2] = 1;
        sine_wave[3] = 2;
        sine_wave[4] = 3;
        sine_wave[5] = 4;
        sine_wave[6] = 6;
        sine_wave[7] = 8;
        sine_wave[8] = 10;
        sine_wave[9] = 13;
        sine_wave[10] = 16;
        sine_wave[11] = 19;
        sine_wave[12] = 22;
        sine_wave[13] = 26;
        sine_wave[14] = 29;
        sine_wave[15] = 34;
        sine_wave[16] = 38;
        sine_wave[17] = 42;
        sine_wave[18] = 47;
        sine_wave[19] = 52;
        sine_wave[20] = 57;
        sine_wave[21] = 62;
        sine_wave[22] = 68;
        sine_wave[23] = 73;
        sine_wave[24] = 79;
        sine_wave[25] = 85;
        sine_wave[26] = 91;
        sine_wave[27] = 97;
        sine_wave[28] = 103;
        sine_wave[29] = 109;
        sine_wave[30] = 115;
        sine_wave[31] = 121;
        sine_wave[32] = 128;
        sine_wave[33] = 134;
        sine_wave[34] = 140;
        sine_wave[35] = 146;
        sine_wave[36] = 152;
        sine_wave[37] = 158;
        sine_wave[38] = 164;
        sine_wave[39] = 170;
        sine_wave[40] = 176;
        sine_wave[41] = 182;
        sine_wave[42] = 187;
        sine_wave[43] = 193;
        sine_wave[44] = 198;
        sine_wave[45] = 203;
        sine_wave[46] = 208;
        sine_wave[47] = 213;
        sine_wave[48] = 217;
        sine_wave[49] = 221;
        sine_wave[50] = 226;
        sine_wave[51] = 229;
        sine_wave[52] = 233;
        sine_wave[53] = 236;
        sine_wave[54] = 239;
        sine_wave[55] = 242;
        sine_wave[56] = 245;
        sine_wave[57] = 247;
        sine_wave[58] = 249;
        sine_wave[59] = 251;
        sine_wave[60] = 252;
        sine_wave[61] = 253;
        sine_wave[62] = 254;
        sine_wave[63] = 255;
    end
endmodule
