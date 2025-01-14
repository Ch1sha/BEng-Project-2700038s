# !/bin/bash
set -e

# This script will run the python scripts to generate the sine wave modules

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

# Set the default bit count
BITCOUNT=false
SAMPLE_OVERRIDE=false
FIND_IDEAL_SAMPLES=false
PLOT_SAMPLES=false
PLOT_SINE=false

flag_string=""

# Parse optional arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bit_count)
            if [[ -n "$2" ]]; then
                BITCOUNT=$2
                flag_string="${flag_string} --bit_count ${BITCOUNT}"
                shift 2
            else
                echo "Error: --bit_count requires a value"
                exit 1
            fi
            ;;
        --override_sample)
            if [[ -n "$2" ]]; then
                SAMPLE_OVERRIDE=$2
                flag_string="${flag_string} --override_sample ${SAMPLE_OVERRIDE}"
                shift 2
            else
                echo "Error: --override_sample requires a value"
                exit 1
            fi
            ;;
        --find_sample)
            if [[ -n "$2" ]]; then
                FIND_IDEAL_SAMPLES=$2
                flag_string="${flag_string} --find_sample ${FIND_IDEAL_SAMPLES}"
                shift 2
            else
                echo "Error: --find_sample requires a value"
                exit 1
            fi
            ;;
        --plot_sample)
            PLOT_SAMPLES=true
            flag_string="${flag_string} --plot_sample"
            shift
            ;;
        --plot_sine)
            PLOT_SINE=true
            flag_string="${flag_string} --plot_sine"
            shift
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

# Check if the bit count is provided
if [ "$BITCOUNT" = false ]; then
    echo "No --bit_count provided, using default value of 8 bits"
    BITCOUNT=8
fi

echo "Generating sine wave modules with ${BITCOUNT} bits"
echo "==============================================="

# Run the python script to generate the half_sine_table.v module and update the sine_table.v macros
echo "==Running generate_modules_sine.py=="
python ${MODULE_DIR}/generate/generate_modules_sine.py ${flag_string}
