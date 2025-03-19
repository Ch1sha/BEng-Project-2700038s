
`timescale 1 ns / 1 ps

module signal_generator #
(
    // Users to add parameters here
    parameter SINE_SIZE = 12,
    parameter TABLE_SIZE = 268,
    parameter TABLE_REG_SIZE = 9,
    parameter PHASE_SIZE = 8,

    // User parameters ends
    // Do not modify the parameters beyond this line


    // Parameters of Axi Slave Bus Interface phase_in
    parameter integer C_phase_in_TDATA_WIDTH	= 32,

    // Parameters of Axi Master Bus Interface wave_out
    parameter integer C_wave_out_TDATA_WIDTH	= 32,
    parameter integer C_wave_out_START_COUNT	= 32
)
(
    // Users to add ports here

    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface phase_in
    input wire  phase_in_aclk,
    input wire  phase_in_aresetn,
    output wire  phase_in_tready,
    input wire [C_phase_in_TDATA_WIDTH-1 : 0] phase_in_tdata,
    input wire [(C_phase_in_TDATA_WIDTH/8)-1 : 0] phase_in_tstrb,
    input wire  phase_in_tlast,
    input wire  phase_in_tvalid,

    // Ports of Axi Master Bus Interface wave_out
    input wire  wave_out_aclk,
    input wire  wave_out_aresetn,
    output wire  wave_out_tvalid,
    output wire [C_wave_out_TDATA_WIDTH-1 : 0] wave_out_tdata,
    output wire [(C_wave_out_TDATA_WIDTH/8)-1 : 0] wave_out_tstrb,
    output wire  wave_out_tlast,
    input wire  wave_out_tready
);
    // Instantiation of Axi Bus Interface phase_in
    // Instantiation of Axi Bus Interface phase_in
    // ACLK     (input) is the clock input.
    // ARESETN  (input) is the active low reset signal.
    // TREADY  (output) is the flow control signal that is used to indicate that the slave is ready to accept data in.
    // TDATA    (input) is the payload that is used to provide the data that is passing into the interface.
    // TSTRB    (input) is the byte strobe signal that is used to indicate which byte lanes are valid.
    // TLAST    (input) is the signal that is used to indicate the end of a packet.
    // TVALID   (input) is the flow control signal that is used to indicate that the data on the TDATA bus is valid.

    signal_generator_slave_stream_v1_0_phase_in # ( 
        .C_S_AXIS_TDATA_WIDTH(C_phase_in_TDATA_WIDTH)
    ) signal_generator_slave_stream_v1_0_phase_in_inst (
        .S_AXIS_ACLK(phase_in_aclk),
        .S_AXIS_ARESETN(phase_in_aresetn),
        .S_AXIS_TREADY(phase_in_tready),
        .S_AXIS_TDATA(phase_in_tdata),
        .S_AXIS_TSTRB(phase_in_tstrb),
        .S_AXIS_TLAST(phase_in_tlast),
        .S_AXIS_TVALID(phase_in_tvalid),
        .phase_s_out(phase_from_slave),
        .phaseStep_s_out(phaseStep_from_slave)
    );

    // Instantiation of Axi Bus Interface wave_out
	// ACLK    (input) is the clock input.
	// ARESETN (input) is the active low reset signal.
	// TVALID (output) is the flow control signal that is used to indicate that the data on the TDATA bus is valid.
	// TDATA  (output) is the payload that is used to provide the data that is passing across the interface.
	// TSTRB  (output) is the byte strobe signal that is used to indicate which byte lanes are valid.
	// TLAST  (output) is the signal that is used to indicate the end of a packet.
	// TREADY  (input) is the flow control signal that is used to indicate that the master is ready to send data.

    signal_generator_master_stream_v1_0_wave_out # ( 
        .C_M_AXIS_TDATA_WIDTH(C_wave_out_TDATA_WIDTH),
        .C_M_START_COUNT(C_wave_out_START_COUNT)
    ) signal_generator_master_stream_v1_0_wave_out_inst (
        .M_AXIS_ACLK(wave_out_aclk),
        .M_AXIS_ARESETN(wave_out_aresetn),
        .M_AXIS_TVALID(wave_out_tvalid),
        .M_AXIS_TDATA(wave_out_tdata),
        .M_AXIS_TSTRB(wave_out_tstrb),
        .M_AXIS_TLAST(wave_out_tlast),
        .M_AXIS_TREADY(wave_out_tready),
        .sine_m_in(sine_val_to_master)
    );

    // Add user logic here

    // phase is the first PHASE_SIZE bits of S_AXIS_TDATA
	// phaseStep is the next PHASE_SIZE bits of S_AXIS_TDATA
	wire signed [PHASE_SIZE:0] phase_from_slave;
	wire signed [PHASE_SIZE:0] phaseStep_from_slave;
	wire [SINE_SIZE-1:0] sine_val_to_master;

	//-------------------------------------------------------------------------
    // Inline Sine Generation Logic (Flattened signal_gen_top, sine_wave, and half_sine_table)
    //-------------------------------------------------------------------------
    reg [SINE_SIZE-1:0] sine_reg;
    assign sine_val_to_master = sine_reg;
    // Internal registers and variables for computation
    reg  signed [TABLE_REG_SIZE:0] i;
    reg  signed [PHASE_SIZE:0]     prev_phase;
    integer phaseIdx;
    integer tableSize;
    reg  reverseTraversal; // Flag to indicate reverse traversal

    // Half-sine table ROM
    // Register for the current sine value from the lookup table
    reg [SINE_SIZE-1:0] sine_val;
    // Lookup table ROM for the half sine wave
    reg [SINE_SIZE-1:0] sine_table_rom [0:TABLE_SIZE-1];
    reg [TABLE_REG_SIZE:0] table_size_wire;

    // Initialise the lookup table
    initial begin
        table_size_wire = TABLE_SIZE - 1;
        sine_table_rom[0]   = 0;
        sine_table_rom[1]   = 0;
        sine_table_rom[2]   = 1;
        sine_table_rom[3]   = 1;
        sine_table_rom[4]   = 2;
        sine_table_rom[5]   = 4;
        sine_table_rom[6]   = 5;
        sine_table_rom[7]   = 7;
        sine_table_rom[8]   = 9;
        sine_table_rom[9]   = 11;
        sine_table_rom[10]  = 14;
        sine_table_rom[11]  = 17;
        sine_table_rom[12]  = 20;
        sine_table_rom[13]  = 24;
        sine_table_rom[14]  = 28;
        sine_table_rom[15]  = 32;
        sine_table_rom[16]  = 36;
        sine_table_rom[17]  = 41;
        sine_table_rom[18]  = 45;
        sine_table_rom[19]  = 51;
        sine_table_rom[20]  = 56;
        sine_table_rom[21]  = 62;
        sine_table_rom[22]  = 68;
        sine_table_rom[23]  = 74;
        sine_table_rom[24]  = 80;
        sine_table_rom[25]  = 87;
        sine_table_rom[26]  = 94;
        sine_table_rom[27]  = 102;
        sine_table_rom[28]  = 109;
        sine_table_rom[29]  = 117;
        sine_table_rom[30]  = 125;
        sine_table_rom[31]  = 134;
        sine_table_rom[32]  = 142;
        sine_table_rom[33]  = 151;
        sine_table_rom[34]  = 160;
        sine_table_rom[35]  = 170;
        sine_table_rom[36]  = 180;
        sine_table_rom[37]  = 190;
        sine_table_rom[38]  = 200;
        sine_table_rom[39]  = 210;
        sine_table_rom[40]  = 221;
        sine_table_rom[41]  = 232;
        sine_table_rom[42]  = 243;
        sine_table_rom[43]  = 255;
        sine_table_rom[44]  = 266;
        sine_table_rom[45]  = 278;
        sine_table_rom[46]  = 291;
        sine_table_rom[47]  = 303;
        sine_table_rom[48]  = 316;
        sine_table_rom[49]  = 329;
        sine_table_rom[50]  = 342;
        sine_table_rom[51]  = 355;
        sine_table_rom[52]  = 369;
        sine_table_rom[53]  = 383;
        sine_table_rom[54]  = 397;
        sine_table_rom[55]  = 411;
        sine_table_rom[56]  = 426;
        sine_table_rom[57]  = 440;
        sine_table_rom[58]  = 455;
        sine_table_rom[59]  = 470;
        sine_table_rom[60]  = 486;
        sine_table_rom[61]  = 502;
        sine_table_rom[62]  = 517;
        sine_table_rom[63]  = 533;
        sine_table_rom[64]  = 550;
        sine_table_rom[65]  = 566;
        sine_table_rom[66]  = 583;
        sine_table_rom[67]  = 600;
        sine_table_rom[68]  = 617;
        sine_table_rom[69]  = 634;
        sine_table_rom[70]  = 651;
        sine_table_rom[71]  = 669;
        sine_table_rom[72]  = 687;
        sine_table_rom[73]  = 705;
        sine_table_rom[74]  = 723;
        sine_table_rom[75]  = 742;
        sine_table_rom[76]  = 760;
        sine_table_rom[77]  = 779;
        sine_table_rom[78]  = 798;
        sine_table_rom[79]  = 817;
        sine_table_rom[80]  = 836;
        sine_table_rom[81]  = 856;
        sine_table_rom[82]  = 875;
        sine_table_rom[83]  = 895;
        sine_table_rom[84]  = 915;
        sine_table_rom[85]  = 935;
        sine_table_rom[86]  = 955;
        sine_table_rom[87]  = 976;
        sine_table_rom[88]  = 996;
        sine_table_rom[89]  = 1017;
        sine_table_rom[90]  = 1038;
        sine_table_rom[91]  = 1059;
        sine_table_rom[92]  = 1080;
        sine_table_rom[93]  = 1101;
        sine_table_rom[94]  = 1122;
        sine_table_rom[95]  = 1144;
        sine_table_rom[96]  = 1165;
        sine_table_rom[97]  = 1187;
        sine_table_rom[98]  = 1209;
        sine_table_rom[99]  = 1231;
        sine_table_rom[100] = 1253;
        sine_table_rom[101] = 1275;
        sine_table_rom[102] = 1297;
        sine_table_rom[103] = 1320;
        sine_table_rom[104] = 1342;
        sine_table_rom[105] = 1365;
        sine_table_rom[106] = 1387;
        sine_table_rom[107] = 1410;
        sine_table_rom[108] = 1433;
        sine_table_rom[109] = 1456;
        sine_table_rom[110] = 1479;
        sine_table_rom[111] = 1502;
        sine_table_rom[112] = 1525;
        sine_table_rom[113] = 1549;
        sine_table_rom[114] = 1572;
        sine_table_rom[115] = 1595;
        sine_table_rom[116] = 1619;
        sine_table_rom[117] = 1642;
        sine_table_rom[118] = 1666;
        sine_table_rom[119] = 1689;
        sine_table_rom[120] = 1713;
        sine_table_rom[121] = 1737;
        sine_table_rom[122] = 1760;
        sine_table_rom[123] = 1784;
        sine_table_rom[124] = 1808;
        sine_table_rom[125] = 1832;
        sine_table_rom[126] = 1856;
        sine_table_rom[127] = 1880;
        sine_table_rom[128] = 1904;
        sine_table_rom[129] = 1928;
        sine_table_rom[130] = 1952;
        sine_table_rom[131] = 1976;
        sine_table_rom[132] = 2000;
        sine_table_rom[133] = 2023;
        sine_table_rom[134] = 2048;
        sine_table_rom[135] = 2072;
        sine_table_rom[136] = 2095;
        sine_table_rom[137] = 2119;
        sine_table_rom[138] = 2143;
        sine_table_rom[139] = 2167;
        sine_table_rom[140] = 2191;
        sine_table_rom[141] = 2215;
        sine_table_rom[142] = 2239;
        sine_table_rom[143] = 2263;
        sine_table_rom[144] = 2287;
        sine_table_rom[145] = 2311;
        sine_table_rom[146] = 2335;
        sine_table_rom[147] = 2358;
        sine_table_rom[148] = 2382;
        sine_table_rom[149] = 2406;
        sine_table_rom[150] = 2429;
        sine_table_rom[151] = 2453;
        sine_table_rom[152] = 2476;
        sine_table_rom[153] = 2500;
        sine_table_rom[154] = 2523;
        sine_table_rom[155] = 2546;
        sine_table_rom[156] = 2570;
        sine_table_rom[157] = 2593;
        sine_table_rom[158] = 2616;
        sine_table_rom[159] = 2639;
        sine_table_rom[160] = 2662;
        sine_table_rom[161] = 2685;
        sine_table_rom[162] = 2708;
        sine_table_rom[163] = 2730;
        sine_table_rom[164] = 2753;
        sine_table_rom[165] = 2775;
        sine_table_rom[166] = 2798;
        sine_table_rom[167] = 2820;
        sine_table_rom[168] = 2842;
        sine_table_rom[169] = 2864;
        sine_table_rom[170] = 2886;
        sine_table_rom[171] = 2908;
        sine_table_rom[172] = 2930;
        sine_table_rom[173] = 2951;
        sine_table_rom[174] = 2973;
        sine_table_rom[175] = 2994;
        sine_table_rom[176] = 3015;
        sine_table_rom[177] = 3036;
        sine_table_rom[178] = 3057;
        sine_table_rom[179] = 3078;
        sine_table_rom[180] = 3099;
        sine_table_rom[181] = 3119;
        sine_table_rom[182] = 3140;
        sine_table_rom[183] = 3160;
        sine_table_rom[184] = 3180;
        sine_table_rom[185] = 3200;
        sine_table_rom[186] = 3220;
        sine_table_rom[187] = 3239;
        sine_table_rom[188] = 3259;
        sine_table_rom[189] = 3278;
        sine_table_rom[190] = 3297;
        sine_table_rom[191] = 3316;
        sine_table_rom[192] = 3335;
        sine_table_rom[193] = 3353;
        sine_table_rom[194] = 3372;
        sine_table_rom[195] = 3390;
        sine_table_rom[196] = 3408;
        sine_table_rom[197] = 3426;
        sine_table_rom[198] = 3444;
        sine_table_rom[199] = 3461;
        sine_table_rom[200] = 3478;
        sine_table_rom[201] = 3495;
        sine_table_rom[202] = 3512;
        sine_table_rom[203] = 3529;
        sine_table_rom[204] = 3545;
        sine_table_rom[205] = 3562;
        sine_table_rom[206] = 3578;
        sine_table_rom[207] = 3593;
        sine_table_rom[208] = 3609;
        sine_table_rom[209] = 3625;
        sine_table_rom[210] = 3640;
        sine_table_rom[211] = 3655;
        sine_table_rom[212] = 3669;
        sine_table_rom[213] = 3684;
        sine_table_rom[214] = 3698;
        sine_table_rom[215] = 3712;
        sine_table_rom[216] = 3726;
        sine_table_rom[217] = 3740;
        sine_table_rom[218] = 3753;
        sine_table_rom[219] = 3766;
        sine_table_rom[220] = 3779;
        sine_table_rom[221] = 3792;
        sine_table_rom[222] = 3804;
        sine_table_rom[223] = 3817;
        sine_table_rom[224] = 3829;
        sine_table_rom[225] = 3840;
        sine_table_rom[226] = 3852;
        sine_table_rom[227] = 3863;
        sine_table_rom[228] = 3874;
        sine_table_rom[229] = 3885;
        sine_table_rom[230] = 3895;
        sine_table_rom[231] = 3905;
        sine_table_rom[232] = 3915;
        sine_table_rom[233] = 3925;
        sine_table_rom[234] = 3935;
        sine_table_rom[235] = 3944;
        sine_table_rom[236] = 3953;
        sine_table_rom[237] = 3961;
        sine_table_rom[238] = 3970;
        sine_table_rom[239] = 3978;
        sine_table_rom[240] = 3986;
        sine_table_rom[241] = 3993;
        sine_table_rom[242] = 4001;
        sine_table_rom[243] = 4008;
        sine_table_rom[244] = 4015;
        sine_table_rom[245] = 4021;
        sine_table_rom[246] = 4027;
        sine_table_rom[247] = 4033;
        sine_table_rom[248] = 4039;
        sine_table_rom[249] = 4044;
        sine_table_rom[250] = 4050;
        sine_table_rom[251] = 4054;
        sine_table_rom[252] = 4059;
        sine_table_rom[253] = 4063;
        sine_table_rom[254] = 4067;
        sine_table_rom[255] = 4071;
        sine_table_rom[256] = 4075;
        sine_table_rom[257] = 4078;
        sine_table_rom[258] = 4081;
        sine_table_rom[259] = 4084;
        sine_table_rom[260] = 4086;
        sine_table_rom[261] = 4088;
        sine_table_rom[262] = 4090;
        sine_table_rom[263] = 4091;
        sine_table_rom[264] = 4093;
        sine_table_rom[265] = 4094;
        sine_table_rom[266] = 4094;
        sine_table_rom[267] = 4095;
    end

    // Combinational block to select the sine value from the lookup table
    always @(*) begin
        sine_val = sine_table_rom[i];
    end

    // sine_wave.v logic
    // Function: Calculate the starting index based on a given phase index.
    function integer calculate_start_index;
        input integer phaseIndex;
        integer midpoint;
        integer start_index;
        begin
            midpoint = TABLE_SIZE / 2;
            start_index = midpoint + phaseIndex;
            if (start_index < 0)
                start_index = -start_index;
            calculate_start_index = start_index;
        end
    endfunction

    // Function: Converts phase in degrees to a table index value.
    function signed [PHASE_SIZE:0] phase_to_phaseVal;
        input signed [PHASE_SIZE:0] phaseIn;
        reg signed [PHASE_SIZE:0] minVal; // Minimum phase value
        reg signed [PHASE_SIZE:0] maxVal; // Maximum phase value (midpoint)
        begin
            minVal = -3 * (TABLE_SIZE / 2) + 1;
            maxVal = (TABLE_SIZE / 2) - 1;
            if (phaseIn >= 0 && phaseIn <= 90)
                // Map [0º, 90º] to [0, maxVal]
                phase_to_phaseVal = (phaseIn * maxVal) / 90;
            else if (phaseIn > 90 && phaseIn <= 180)
                // Map [90º, 180º] to [minVal, -TABLE_SIZE]
                phase_to_phaseVal = minVal + ((phaseIn - 90) * maxVal) / 90;
            else if (phaseIn >= -180 && phaseIn < 0)
                // Map [-180º, 0º] to [TABLE_SIZE, 0]
                phase_to_phaseVal = -TABLE_SIZE + ((phaseIn + 180) * TABLE_SIZE) / 180;
            else
                // Clamp phase to valid range [-180º, 180º]
                phase_to_phaseVal = (phaseIn > 180) ? maxVal : minVal;
        end
    endfunction

    // Syncronous logic to update the sine value based on the phase input
    always @(posedge phase_in_aclk or negedge phase_in_aresetn) begin
        if (phase_in_aresetn==1'b0) begin
            sine_reg        <= 0;
            prev_phase      <= 0;
            i               <= calculate_start_index(0);
            reverseTraversal<= 0;
        end else if (phase_from_slave != prev_phase) begin
            tableSize  = table_size_wire;
            prev_phase <= phase_from_slave;
            phaseIdx   = phase_to_phaseVal(phase_from_slave);
            i          <= calculate_start_index(phaseIdx);
            if (phase_from_slave >= 0) begin
                case (phase_from_slave)
                    90:  reverseTraversal <= 1;
                    180: reverseTraversal <= 1;
                    default: reverseTraversal <= (i < TABLE_SIZE - 1) ? 0 : 1;
                endcase
            end else begin
                case (phase_from_slave)
                    -90:  reverseTraversal <= 0;
                    -180: reverseTraversal <= 1;
                    default: reverseTraversal <= (i > 0) ? 1 : 0;
                endcase
            end
            sine_reg <= sine_val;
        end else begin
            sine_reg <= sine_val;
            if (!reverseTraversal) begin
                if (i >= tableSize - phaseStep_from_slave)
                    reverseTraversal <= 1;
                if (i + phaseStep_from_slave <= tableSize)
                    i <= i + phaseStep_from_slave;
            end else begin
                if (i <= phaseStep_from_slave)
                    reverseTraversal <= 0;
                if (i - phaseStep_from_slave >= 0)
                    i <= i - phaseStep_from_slave;
            end
        end
    end


    // User logic ends

endmodule
