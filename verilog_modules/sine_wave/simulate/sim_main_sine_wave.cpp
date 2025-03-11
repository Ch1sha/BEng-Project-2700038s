#include "Vsignal_gen_top.h"
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
    Vsignal_gen_top* top = new Vsignal_gen_top{contextp};

    // Set initial input values
    top->clock = 0;
    top->reset = 0;
    top->phase = phase;
    top->phaseStep = 1;

    // Print csv headers
    std::cout << "c,s,p,i" << std::endl;

    // Reset logic for 5 cycles
    int reset_cycles = -5;
    for (int i = 0; i < 10; i++) {
        top->clock = !top->clock;
        top->eval(); // Evaluate model on each clock edge

        if (top->clock) {
            std::cout << "" << reset_cycles << "," << static_cast<int>(top->sine) << "," << static_cast<int>(top->phaseIdxOut) << "," << static_cast<int>(top->i) << std::endl;
            reset_cycles++;
        }

        top->reset = 1;
        contextp->timeInc(1); // Increment time by 1 time unit
    }
    top->reset = 0;

    // Main simulation loop
    int cycleCount = 0;
    for (int i = 0; i < sim_time; i++) {
        top->clock = !top->clock; // Toggle clock

        // Set phase to 0 after 80 cycles
        if (cycleCount == 150){
            //top->phase = -90;
            //top->phaseStep = 3;
        }
        if (cycleCount == 300){
            //top->phase = 0;
            //top->phaseStep = 10;
        }

        // Evaluate model on both edges
        top->eval();

        // Capture output on the positive edge of clock
        if (top->clock) {
            std::cout << "" << cycleCount << "," << static_cast<int>(top->sine) << "," << static_cast<int>(top->phaseIdxOut) << "," << static_cast<int>(top->i) << std::endl;
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
