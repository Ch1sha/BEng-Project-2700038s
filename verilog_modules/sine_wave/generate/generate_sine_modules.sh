# !/bin/bash
set -e

# This script will run the python scripts to generate the sine wave modules

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

# Set the default bit count
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

echo "Generating sine wave modules with ${BITCOUNT} bits"
echo "==============================================="

# Run the python script to generate the half_sine_table.v module and update the sine_table.v macros
echo "==Running generate_modules_sine.py=="
python ${MODULE_DIR}/generate/generate_modules_sine.py --bit_count ${BITCOUNT}
