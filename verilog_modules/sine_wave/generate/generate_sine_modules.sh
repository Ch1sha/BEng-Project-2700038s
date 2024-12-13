# !/bin/bash
set -e

# This script will run the python scripts to generate the sine wave modules

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

# Run the python script to generate the half_sine_table.v module
python ${MODULE_DIR}/generate/generate_half_sine_table.py

# Run the python script to generate the sine_wave.v module
python ${MODULE_DIR}/generate/generate_sine_wave.py
