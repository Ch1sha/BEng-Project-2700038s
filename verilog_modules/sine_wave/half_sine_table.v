`define SINE_SIZE 8
`define TABLE_SIZE 32
`define TABLE_REG_SIZE 6

module half_sine_table(
    output logic [`SINE_SIZE-1:0] sine_wave [0:`TABLE_SIZE-1],
    output logic [`TABLE_REG_SIZE-1:0] table_size
);
    initial begin
        table_size = `TABLE_SIZE-1;
        sine_wave[0] = 0;
        sine_wave[1] = 1;
        sine_wave[2] = 2;
        sine_wave[3] = 5;
        sine_wave[4] = 10;
        sine_wave[5] = 15;
        sine_wave[6] = 21;
        sine_wave[7] = 29;
        sine_wave[8] = 37;
        sine_wave[9] = 47;
        sine_wave[10] = 57;
        sine_wave[11] = 67;
        sine_wave[12] = 79;
        sine_wave[13] = 90;
        sine_wave[14] = 103;
        sine_wave[15] = 115;
        sine_wave[16] = 128;
        sine_wave[17] = 140;
        sine_wave[18] = 152;
        sine_wave[19] = 165;
        sine_wave[20] = 176;
        sine_wave[21] = 188;
        sine_wave[22] = 198;
        sine_wave[23] = 208;
        sine_wave[24] = 218;
        sine_wave[25] = 226;
        sine_wave[26] = 234;
        sine_wave[27] = 240;
        sine_wave[28] = 245;
        sine_wave[29] = 250;
        sine_wave[30] = 253;
        sine_wave[31] = 254;
    end
endmodule
