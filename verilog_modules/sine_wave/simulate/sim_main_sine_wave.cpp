#include "Vsine_wave.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char** argv) {
    // Initialize Verilator context
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    int sim_time;
    int phase;

    // Retrieve command line arguments
    for (int i = 1; i < argc; i++) {
        if (std::string(argv[i]) == "--sim_time" && i + 1 < argc) {
            //printf("Setting simulation time to %d\n", std::atoi(argv[i + 1]));
            sim_time = std::atoi(argv[i + 1]);
            if (sim_time <= 0) {
                std::cerr << "Error: Invalid --sim_time value. Must be greater than 0." << std::endl;
                return 1;
            }
        }
        if (std::string(argv[i]) == "--phase" && i + 1 < argc) {
            //printf("Setting phase to %d\n", std::atoi(argv[i + 1]));
            phase = std::atoi(argv[i + 1]);
        }
    }

    // Instantiate the model
    Vsine_wave* top = new Vsine_wave{contextp};

    // Set initial input values
    top->clock = 0;
    top->reset = 1;
    top->phase = phase;

    // Reset logic for 5 cycles
    for (int i = 0; i < 10; i++) {
        top->clock = !top->clock;
        top->eval(); // Evaluate model on each clock edge
        if (contextp->time() > 5) { // Deactivate reset after 5 time units
            top->reset = 0;
        }
        contextp->timeInc(1); // Increment time by 1 time unit
    }

    // Main simulation loop
    int cycleCount = 0;
    for (int i = 0; i < sim_time; i++) {
        top->clock = !top->clock; // Toggle clock

        // Evaluate model on both edges
        top->eval();

        // Capture output on the positive edge of clock
        if (top->clock) {
            std::cout << "" << cycleCount << "," << static_cast<int>(top->sine) << std::endl;
            cycleCount++;
        }

        // Increment time by 1 time unit
        contextp->timeInc(1);
    }

    // Final model cleanup
    top->final();

    // Cleanup
    delete top;
    delete contextp;
    return 0;
}
