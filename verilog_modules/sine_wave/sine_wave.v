/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off BLKSEQ */
`define SINE_SIZE 8
`define TABLE_SIZE 32
`define TABLE_REG_SIZE 6
`define PHASE_SIZE 8 // resolution for phase input (from -180º to 180º)
`define M_PI (22/7)

module sine_wave (
    input logic clock, 
    input logic reset,
    input logic signed [`PHASE_SIZE:0] phase, // phase input determines the starting point of the sine wave, no -1 to handle signed values
    output logic [`SINE_SIZE-1:0] sine // n-bit Sine wave output
);

    logic [`SINE_SIZE-1:0] sine_wave_table [0:`TABLE_SIZE-1]; // 50 samples of sine wave
    logic [`TABLE_REG_SIZE-1:0] logic_table_size;
    half_sine_table sine_table_inst (
        .sine_wave(sine_wave_table),
        .table_size(logic_table_size)
    );

    // Signal to hold the previous value of phase
    logic signed [`PHASE_SIZE:0] prev_phase;

    integer tableSize;
    integer i = phase; // Start from the given phase
    logic reverseTraversal = 0; // Reverse traversal flag

    // Function to calculate the starting index based on phase
    function integer calculate_start_index(input integer phaseVal);

        real phaseRad;
        real scaled_phase;
        integer start_index;
        begin
            // Convert phase (degrees) to radians
            phaseRad = phaseVal * `M_PI / 180.0;

            // Scale phase from -π to π into the table size range [0, TABLE_SIZE-1]
            scaled_phase = (phaseRad + `M_PI) * (`TABLE_SIZE) / (2.0 * `M_PI);

            // Truncate the scaled phase and wrap it using modulo operation
            start_index = $rtoi(scaled_phase) % (`TABLE_SIZE);

            // Ensure the index is positive
            if (start_index < 0) begin
                start_index = start_index + `TABLE_SIZE;
            end

            calculate_start_index = start_index;
        end
    endfunction

    always_ff @(posedge clock or posedge reset) begin
        if (reset || phase != prev_phase) begin
            tableSize <= logic_table_size; // Assign constant table size on reset
            prev_phase <= phase; // Update previous phase

            // Set initial traversal direction based on phase sign
            if (phase >= 0) begin
                reverseTraversal <= 0; // Start with forward traversal
            end else begin
                reverseTraversal <= 1; // Start with reverse traversal
            end

            // Set initial index based on phase offset
            i <= calculate_start_index(phase);
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
