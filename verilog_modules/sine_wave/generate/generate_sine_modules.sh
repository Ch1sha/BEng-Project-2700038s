# !/bin/bash
set -e

# This script will run the python scripts to generate the sine wave modules

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

BITCOUNT=8
# Check for an optional bit_count argument
if [[ "$1" == "--bit_count" ]]; then
    if [[ -n "$2" ]]; then
        BITCOUNT=$2
        shift 2
    else
        echo "Error: --bit_count requires a value"
        exit 1
    fi
else
    echo "No bitcount argument provided. Using default value of ${BITCOUNT}."
fi

# Run the python script to generate the half_sine_table.v module
python ${MODULE_DIR}/generate/generate_half_sine_table.py --bit_count ${BITCOUNT}

# Run the python script to generate the sine_wave.v module
python ${MODULE_DIR}/generate/generate_sine_wave.py --bit_count ${BITCOUNT}
