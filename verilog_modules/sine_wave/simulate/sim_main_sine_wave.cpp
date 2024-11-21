#include "Vsine_wave.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char** argv) {
    // Initialize Verilator context
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    // Instantiate the model
    Vsine_wave* top = new Vsine_wave{contextp};

    // Set initial input values
    top->clock = 0;
    top->reset = 1;
    top->phase = 0;

    // Reset logic for 5 cycles
    for (int i = 0; i < 10; i++) {
        top->clock = !top->clock;
        top->eval(); // Evaluate model
        if (contextp->time() > 5) { // Deactivate reset after 5 time units
            top->reset = 0;
        }
        contextp->timeInc(1); // Increment time by 1 time unit
    }

    // Main simulation loop
    int cycleCount = 0;
    for (int i = 0; i < 400; i++) { // Adjust if you need more/less cycles
        top->clock = !top->clock; // Toggle clock

        // Evaluate model on both edges
        top->eval();

        // Capture output on the positive edge of clock
        if (top->clock) {
            std::cout << "" << cycleCount << "," << static_cast<int>(top->sine) << std::endl;
            cycleCount++;
        }

        // Advance simulation time
        contextp->timeInc(1); // Increment time by 1 time unit
    }

    // Final model cleanup
    top->final();

    // Cleanup
    delete top;
    delete contextp;
    return 0;
}
