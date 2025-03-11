`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: sine_wave
// Description: Generates a sine wave based on the given phase and phase step.
//              The sine wave is generated using a lookup table with a specified
//              size and resolution. The module supports phase input and phase
//              step input to control the phase increment.
//////////////////////////////////////////////////////////////////////////////////
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off BLKSEQ */
/* verilator lint_off WIDTHTRUNC */

module sine_wave #(
    parameter SINE_SIZE = 12,
    parameter TABLE_SIZE = 268,
    parameter TABLE_REG_SIZE = 9,
    parameter PHASE_SIZE = 8 // resolution for phase input (from -180º to 180º)
) (
    input  wire                             clock,         // System clock input
    input  wire                             reset,         // Active-high reset signal, will act as active low enable signal
    input  wire signed [PHASE_SIZE:0]       phase,         // Phase input (-180º to 180º, resolution defined by PHASE_SIZE)
    input  wire signed [PHASE_SIZE:0]       phaseStep,     // Phase step input to control phase increment
    output reg [SINE_SIZE-1:0]              sine,          // 12-bit sine wave output
    output reg signed [PHASE_SIZE:0]        phaseIdxOut,   // Phase index output from sine_wave module
    output reg signed [TABLE_REG_SIZE:0]    i              // Index output from sine_wave module for debugging
);

    // Wires to connect to the half-sine table ROM
    wire [SINE_SIZE-1:0] sine_val;
    wire [TABLE_REG_SIZE-1:0] table_size_wire;

    // Instantiate the half-sine table module as a ROM.
    // The address input is derived from the lower bits of i.
    half_sine_table #(
        .SINE_SIZE(SINE_SIZE),
        .TABLE_SIZE(TABLE_SIZE),
        .TABLE_REG_SIZE(TABLE_REG_SIZE)
    ) sine_table_inst (
        .addr(i),
        .data(sine_val),
        .table_size(table_size_wire)
    );

    // Signal to hold the previous value of phase
    reg signed [PHASE_SIZE:0] prev_phase;
    integer phaseIdx;
    integer tableSize;
    reg reverseTraversal; // Flag to indicate reverse traversal

    // Function to calculate the starting index based on phase
    function integer calculate_start_index;
        input integer phaseIndex;
        integer midpoint;
        integer start_index;
        begin
            midpoint = (TABLE_SIZE / 2);    // Exact midpoint index of the sine table
            // Offset from midpoint
            start_index = midpoint + phaseIndex;
            // Ensure the index is positive
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

    always @(posedge clock or posedge reset) begin
        if (reset || phase != prev_phase) begin
            tableSize = table_size_wire;   // Obtain the constant table size from the ROM (TABLE_SIZE - 1)
            prev_phase = phase;            // Update previous phase
            // Convert input phase into a table index
            phaseIdx = phase_to_phaseVal(phase);
            phaseIdxOut <= phaseIdx;
            // Set initial index based on phase offset
            i <= calculate_start_index(phaseIdx);

            // Set initial traversal direction based on phase value
            if (phase >= 0) begin
                case (phase)
                    90: begin
                        // At 90º, reverse traversal
                        reverseTraversal <= 1;
                    end
                    180: begin
                        // At 180º, reverse traversal
                        reverseTraversal <= 1;
                    end
                    default: begin
                        // General case: forward traversal
                        reverseTraversal <= (i < TABLE_SIZE - 1) ? 0 : 1;
                    end
                endcase
            end else begin
                case (phase)
                    -90: begin
                        // At -90º, forward traversal
                        reverseTraversal <= 0;
                    end
                    -180: begin
                        // At -180º, reverse traversal
                        reverseTraversal <= 1;
                    end
                    default: begin
                        // General case: reverse traversal
                        reverseTraversal <= (i > 0) ? 1 : 0;
                    end
                endcase
            end

            sine <= sine_val;      // Set initial output from the ROM
        end else begin
            // Update the output with the current sine value from the ROM
            sine <= sine_val;

            // Update index based on traversal direction
            if (!reverseTraversal) begin     // Forward traversal
                if (i >= tableSize - phaseStep) begin
                    reverseTraversal <= 1;   // Switch to reverse traversal at the end
                end
                if (i + phaseStep <= tableSize) begin
                    i <= i + phaseStep;      // Increment if within bounds
                end
            end else begin                   // Reverse traversal
                if (i <= phaseStep) begin
                    reverseTraversal <= 0;   // Switch to forward traversal at the start
                end
                if (i - phaseStep >= 0) begin
                    i <= i - phaseStep;      // Decrement if within bounds
                end
            end
        end
    end

endmodule
