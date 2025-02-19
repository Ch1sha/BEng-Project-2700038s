#include "Vadc_readout.h"      // Generated from adc_readout.v
#include "verilated.h"
#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>             // For std::atoi

int main(int argc, char** argv) {
    // Create and configure the Verilator simulation context.
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    int sim_time = 5000;


    // Instantiate the top module (adc_readout)
    Vadc_readout* top = new Vadc_readout(contextp);

    // Open the ADC output CSV file.
    std::ifstream adc_file("adc_output.csv");
    if (!adc_file.is_open()) {
        std::cerr << "Error: Could not open adc_output.csv" << std::endl;
        return 1;
    }

    // Optionally, skip a header line if your CSV contains one.
    // std::string header;
    // std::getline(adc_file, header);

    // Set initial signal values.
    top->adc_clock    = 0;
    top->reset        = 1;
    top->start_capture = 0;
    top->adc_data     = 0;
    top->read_addr    = 0;

    // Apply reset for 5 cycles.
    for (int i = 0; i < 5; i++) {
        top->adc_clock = !top->adc_clock;
        top->eval();
        contextp->timeInc(1); // Increment simulation time (e.g. 1 ns per step)
    }
    top->reset = 0; // Deassert reset

    // Begin capture: assert start_capture for one clock cycle.
    top->start_capture = 1;
    top->adc_clock = !top->adc_clock;
    top->eval();
    contextp->timeInc(1);
    top->start_capture = 0;

    // Main simulation loop.
    int cycleCount = 0;
    while (!contextp->gotFinish() && cycleCount < sim_time) {
        // Toggle clock.
        top->adc_clock = !top->adc_clock;

        // On rising edge, feed ADC data from the CSV file.
        if (top->adc_clock) {
            std::string line;
            if (std::getline(adc_file, line)) {
                // Convert the CSV line to an integer (assumes one value per line).
                int adc_val = std::stoi(line);
                top->adc_data = adc_val;
            } else {
                // If the file has been exhausted, you may choose to hold the last value or send 0.
                top->adc_data = 0;
            }
        }

        // Evaluate the model.
        top->eval();
        contextp->timeInc(1);

        // Increment cycle counter only on rising edge.
        if (top->adc_clock) {
            cycleCount++;
        }

        // Check if capture is complete.
        if (top->capture_done) {
            std::cout << "Capture complete at cycle " << cycleCount << std::endl;
            break;
        }
    }

    // Finalise simulation.
    top->final();

    // Clean up.
    delete top;
    delete contextp;
    return 0;
}
