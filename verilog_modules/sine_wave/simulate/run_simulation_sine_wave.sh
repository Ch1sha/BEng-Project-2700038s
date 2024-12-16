#!/bin/bash
set -e

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

simulation_filename="sim_main_sine_wave"
verilog_module_filename="sine_wave"

# compile the simulation of the sine_wave module
verilator --cc --exe --build -j 0 -Wall -I${MODULE_DIR} ${MODULE_DIR}/simulate/${simulation_filename}.cpp ${MODULE_DIR}/${verilog_module_filename}.v
echo ""
echo "Compiled the simulation of the ${verilog_module_filename}.v module"

# delete the csv if it is present
output_csv="${MODULE_DIR}/simulate/${verilog_module_filename}_output.csv"
if [ -f "$output_csv" ]; then
    echo "Overriding the existing csv file..."
    rm "$output_csv"
fi

# Default values
SIM_TIME=250
PHASE=0
# Flags to check if arguments are provided
SIM_TIME_PROVIDED=false
PHASE_PROVIDED=false

# Parse optional arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --sim_time)
            if [[ -n "$2" ]]; then
                SIM_TIME=$2
                SIM_TIME_PROVIDED=true
                shift 2
            else
                echo "Error: --sim_time requires a value"
                exit 1
            fi
            ;;
        --phase)
            if [[ -n "$2" ]]; then
                PHASE=$2
                PHASE_PROVIDED=true
                shift 2
            else
                echo "Error: --phase requires a value"
                exit 1
            fi
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

echo "" # newline
if $SIM_TIME_PROVIDED; then
    echo "Simulation time set to ${SIM_TIME} cycles"
else
    echo "No simulation time argument provided. Using default value of ${SIM_TIME} cycles."
fi
if $PHASE_PROVIDED; then
    echo "Phase set to ${PHASE} cycles"
else
    echo "No phase argument provided. Using default value of ${PHASE} cycles."
fi

# Run the simulation, and save the output to a csv file
${MODULE_DIR}/simulate/obj_dir/V${verilog_module_filename} --sim_time ${SIM_TIME} --phase ${PHASE} >> ${output_csv}

echo "Simulation of the ${verilog_module_filename}.v module is complete"

# Check for the --no-plot argument
if [[ "$1" != "--no-plot" ]]; then
    echo "Plotting the output of the simulation..."
    python ${MODULE_DIR}/simulate/plot_sine_wave.py
else
    echo "Plotting is disabled."
fi
