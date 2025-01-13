# !/bin/bash
set -e

# This script will run the python scripts to generate the sine wave modules

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

# Set the default bit count
BITCOUNT=8

# Parse optional arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bit_count)
            if [[ -n "$2" ]]; then

            else
                echo "Error: --override_sample requires a value"
                exit 1
            fi
            ;;
        --override_sample)
            if [[ -n "$2" ]]; then

            else
                echo "Error: --override_sample requires a value"
                exit 1
            fi
            ;;
        --find_sample)
            if [[ -n "$2" ]]; then

            else
                echo "Error: --find_sample requires a value"
                exit 1
            fi
            ;;
        --plot_sample)
            PLOT=true
            shift
            ;;
        --plot_sine)
            PLOT=true
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

echo "Generating sine wave modules with ${BITCOUNT} bits"
echo "==============================================="

# Run the python script to generate the half_sine_table.v module and update the sine_table.v macros
echo "==Running generate_modules_sine.py=="
python ${MODULE_DIR}/generate/generate_modules_sine.py --bit_count ${BITCOUNT}
