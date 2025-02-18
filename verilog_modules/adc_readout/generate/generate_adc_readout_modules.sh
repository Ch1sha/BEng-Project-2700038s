# !/bin/bash
set -e

# This script will run the python scripts to generate the sine wave modules

# Determine the verilog module's root directory, allowing the script to be run from any location
MODULE_DIR=$(dirname "$0")/..

# Set the default bit count
DATA_WIDTH=False
BUFFER_SIZE=False
NO_GENERATE=False

flag_string=""

# Parse optional arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --data_width)
            if [[ -n "$2" ]]; then
                DATA_WIDTH=$2
                flag_string="${flag_string} --data_width ${DATA_WIDTH}"
                shift 2
            else
                echo "Error: --data_width requires a value"
                exit 1
            fi
            ;;
        --buffer_size)
            if [[ -n "$2" ]]; then
                BUFFER_SIZE=$2
                flag_string="${flag_string} --buffer_size ${BUFFER_SIZE}"
                shift 2
            else
                echo "Error: --buffer_size requires a value"
                exit 1
            fi
            ;;
        --no_generate)
            NO_GENERATE=true
            flag_string="${flag_string} --no_generate"
            shift
            ;;
        -h|--help)
            echo "Usage: generate_adc_readout_modules.sh [OPTIONS]"
            echo "Options:"
            echo "  --data_width        Set the data width of the ADC readout"
            echo "  --buffer_size       Set the buffer size for the ADC readout"
            echo "  --no_generate       Skip generation of ADC readout modules"
            echo "  -h, --help          Display this help message"
            exit 0
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
done

if $NO_GENERATE; then
    echo "Skipping generation of adc readout modules"
else
    echo "Generating adc readout modules with ${BITCOUNT} bits"
fi
echo "==============================================="

# Run the python script to generate the half_sine_table.v module and update the sine_table.v macros
echo "==Running generate_modules_adc_readout.py=="
python ${MODULE_DIR}/generate/generate_modules_adc_readout.py ${flag_string}
