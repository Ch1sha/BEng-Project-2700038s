/* verilator lint_off WIDTHEXPAND */
`define SINE_SIZE 8
`define TABLE_SIZE 32
`define TABLE_REG_SIZE 6
`define PHASE_SIZE `TABLE_REG_SIZE // resolution for phase input

module sine_wave (
    input logic clock, 
    input logic reset,
    input logic signed [`PHASE_SIZE-1:0] phase, // phase input determines the starting point of the sine wave
    output logic [`SINE_SIZE-1:0] sine // n-bit Sine wave output
);

    logic [`SINE_SIZE-1:0] sine_wave_table [0:`TABLE_SIZE-1]; // 50 samples of sine wave
    logic [`TABLE_REG_SIZE-1:0] logic_table_size;
    half_sine_table sine_table_inst (
        .sine_wave(sine_wave_table),
        .table_size(logic_table_size)
    );

    integer tableSize;
    integer i = phase; // Start from the given phase
    logic reverseTraversal = 0; // Reverse traversal flag

    // Function to calculate the starting index based on phase
    function integer calculate_start_index(input integer phaseVal, input integer tableSizeVal);
    /* verilator lint_off BLKSEQ */
        integer midpoint;
        integer scaled_phase;
        integer start_index;
        begin
            midpoint = (tableSizeVal - 1) / 2; // Exact midpoint index of the sine table

            // Scale phase within -tableSize/2 to +tableSize/2
            scaled_phase = phaseVal * (tableSizeVal - 1) / (2**6 - 1); // Scale phase to fit the table size

            // Offset from midpoint and apply wrapping
            start_index = (midpoint + scaled_phase) % tableSizeVal;

            // Handle negative wrapping
            if (start_index < 0) begin
                start_index = start_index + tableSizeVal;
            end

            calculate_start_index = start_index;
        end
    endfunction

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            tableSize <= logic_table_size; // Assign constant table size on reset

            // Set initial index based on phase offset
            i <= calculate_start_index(phase, tableSize);

            // Set initial traversal direction based on phase sign
            if (phase >= 0) begin
                reverseTraversal <= 0; // Start with forward traversal
            end else begin
                reverseTraversal <= 1; // Start with reverse traversal
            end

            sine <= sine_wave_table[i]; // Initial output
        end else begin
            // Output current sine wave sample
            sine <= sine_wave_table[i];

            // Update index based on traversal direction
            if (!reverseTraversal) begin // Forward traversal
                if (i == tableSize - 1) begin
                    reverseTraversal <= 1; // Switch to reverse traversal at the end
                end 
                i <= i + 1; // Continue moving forward

            end else begin // Reverse traversal
                if (i == 1) begin
                    reverseTraversal <= 0; // Switch to forward traversal at the start
                end
                i <= i - 1; // Continue moving back
            end
        end
    end
endmodule
