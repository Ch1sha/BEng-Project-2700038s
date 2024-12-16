# !/bin/bash
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

# Check for an optional sim_time argument
SIM_TIME=250
if [[ "$1" == "--sim_time" ]]; then
    if [[ -n "$2" ]]; then
        SIM_TIME=$2
        shift 2
    else
        echo "Error: --bit_count requires a value"
        exit 1
    fi
else
    echo "No sim_time argument provided. Using default value of ${SIM_TIME}."
fi

# run the simulation, and save the output to a csv file
${MODULE_DIR}/simulate/obj_dir/V${verilog_module_filename} --sim_time ${SIM_TIME}  >> ${output_csv}

echo "Simulation of the ${verilog_module_filename}.v module is complete"

# Check for the --no-plot argument
if [[ "$1" != "--no-plot" ]]; then
    echo "Plotting the output of the simulation..."
    python ${MODULE_DIR}/simulate/plot_sine_wave.py
else
    echo "Plotting is disabled."
fi
