import argparse
import concurrent.futures
import os
import math
import matplotlib.pyplot as plt
import numpy as np
import re

MODULE_ROOT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

def update_verilog_parameters(parameters: dict, filename):
    """
    Update the parameters in the Verilog file with the given dictionary.

    Args:
        parameters (dict): Dictionary containing the parameter names and values.
        filename (str): Name of the Verilog file
    """

    file_path = os.path.join(MODULE_ROOT_PATH, filename)

    with open(file_path, 'r') as file:
        content = file.read()

    # Regex pattern to match Verilog parameters (e.g., parameter NAME = VALUE)
    pattern = r"parameter\s+(\w+)\s*=\s*(\d+)"

    # Function to replace the parameter value
    def replacer(match):
        param_name = match.group(1)
        # Replace the parameter value if it's in the dictionary
        if param_name in parameters:
            new_value = parameters[param_name]
            return f"parameter {param_name} = {new_value}"
        return match.group(0)  # Keep the original line if parameter not in dictionary
    
    # replace the parameters in the verilog file
    updated_verilog_content = re.sub(pattern, replacer, content)

    with open(file_path, 'w') as file:
        file.write(updated_verilog_content)


def update_adc_readout(DATA_WIDTH: int):
    """
    Update the parameters in the ADC readout module with the given dictionary.

    Args:
        DATA_WIDTH (int): Data width of the ADC readout module.
    """

    parameters = {"DATA_WIDTH": DATA_WIDTH}
    update_verilog_parameters(parameters, 'adc_readout.v')

def update_adc_buffer(DATA_WIDTH: int, BUFFER_SIZE: int):
    """
    Update the parameters in the ADC buffer module with the given dictionary.

    Args:
        DATA_WIDTH (int): Data width of the ADC buffer module.
        BUFFER_SIZE (int): Size of the buffer.
    """

    parameters = {"DATA_WIDTH": DATA_WIDTH, "BUFFER_SIZE": BUFFER_SIZE, "ADDR_WIDTH": math.ceil(math.log2(BUFFER_SIZE+1))}
    update_verilog_parameters(parameters, 'adc_buffer.v')

def main():
    parser = argparse.ArgumentParser(description='Generate Verilog modules for ADC readout')
    parser.add_argument('--data_width', type=int, default=12, help='Data width of the ADC readout module')
    parser.add_argument('--buffer_size', type=int, default=4096, help='Size of the buffer')
    parser.add_argument('--no_generate', action='store_true', help='Do not generate and update the sine wave verilog modules.')
    args = parser.parse_args()

    if not args.no_generate:
        print("Generating ADC readout modules...")
        data_width = args.data_width
        buffer_size = args.buffer_size
        print(f"Data width: {data_width}")
        print(f"Buffer size: {buffer_size}")   
        update_adc_readout(data_width)
        update_adc_buffer(data_width, buffer_size)


if __name__ == "__main__":
    main()
