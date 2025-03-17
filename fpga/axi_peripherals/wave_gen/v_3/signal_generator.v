
`timescale 1 ns / 1 ps

module signal_generator #
(
    // Users to add parameters here
    parameter SINE_SIZE = 12,
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
        .S_AXIS_TVALID(phase_in_tvalid)
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
        .M_AXIS_TREADY(wave_out_tready)
    );

    // Add user logic here

    // phase is the first PHASE_SIZE bits of S_AXIS_TDATA
	// phaseStep is the next PHASE_SIZE bits of S_AXIS_TDATA
	wire signed [PHASE_SIZE:0] phase_from_slave;
	wire signed [PHASE_SIZE:0] phaseStep_from_slave;
	wire [SINE_SIZE-1:0] sine_val_to_master;

	// Signal generator module
	signal_gen_top signal_gen_top_inst(
		.clock(phase_in_aclk),
		.reset(phase_in_aresetn),
		.phase(phase_from_slave),
		.phaseStep(phaseStep_from_slave),
		.sine(sine_val_to_master)
	);

    // User logic ends

endmodule
