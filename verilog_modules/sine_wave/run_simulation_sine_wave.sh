# !/bin/bash
simulation_filename="sim_main_sine_wave"
verilog_module_filename="sine_wave"

# compile the simulation of the sine_wave module
verilator --cc --exe --build -j 0 -Wall simulate/${simulation_filename}.cpp ${verilog_module_filename}.v
echo ""
echo "Compiled the simulation of the ${verilog_module_filename}.v module"

# delete the csv if it is present
output_csv="simulate/${verilog_module_filename}_output.csv"
if [ -f "$output_csv" ]; then
    echo "Overriding the existing csv file..."
    rm "$output_csv"
fi

# run the simulation, and save the output to a csv file
./obj_dir/V${verilog_module_filename} >> ${output_csv}

echo "Simulation of the ${verilog_module_filename}.v module is complete"

echo "Plotting the output of the simulation..."

python plot_sine_wave.py