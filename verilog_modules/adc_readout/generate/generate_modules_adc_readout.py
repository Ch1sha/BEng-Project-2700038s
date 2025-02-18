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

    parameters = {"DATA_WIDTH": DATA_WIDTH, "BUFFER_SIZE": BUFFER_SIZE, "ADDR_WIDTH": math.ceil(math.log2(BUFFER_SIZE))}
    update_verilog_parameters(parameters, 'adc_buffer.v')

def simulate_adc_output(data_width: int, num_samples: int, frequency: float, sampling_rate: float):
    """
    Simulate the ADC output using a sine wave.

    Args:
        data_width (int): Data width of the ADC.
        num_samples (int): Number of samples to generate.
        frequency (float): Frequency of the sine wave.
        sampling_rate (float): Sampling rate of the ADC.

    Returns:
        np.ndarray: Array containing the simulated ADC output.
    """
    t = np.arange(num_samples) / sampling_rate
    amplitude = 1
    angularFreq = 2 * np.pi * frequency

    max_val = (2 ** data_width) - 1  # Maximum value for the unsigned range
    sine_wave = amplitude * np.sin(angularFreq * t)
    adc_output = np.round((sine_wave + 1) * (max_val / 2)).astype(int)  # Shifted and scaled
    return adc_output

def main():
    parser = argparse.ArgumentParser(description='Generate Verilog modules for ADC readout')
    parser.add_argument('--data_width', type=int, default=12, help='Data width of the ADC readout module')
    parser.add_argument('--buffer_size', type=int, default=4096, help='Size of the buffer')
    parser.add_argument('--no_generate', action='store_true', help='Do not generate and update the sine wave verilog modules.')
    args = parser.parse_args()

    data_width = args.data_width
    buffer_size = args.buffer_size

    if not args.no_generate:
        print("Generating ADC readout modules...")
        print(f"Data width: {data_width}")
        print(f"Buffer size: {buffer_size}")   
        update_adc_readout(data_width)
        update_adc_buffer(data_width, buffer_size)
    
    # simulate the ADC output
    num_samples = 1024
    frequency = 1
    sampling_rate = 100
    adc_output = simulate_adc_output(data_width, num_samples, frequency, sampling_rate)

    # plot the ADC output
    plt.step(range(len(adc_output)), adc_output, where='mid')
    plt.xlabel('Sample')
    plt.ylabel('ADC Output')
    plt.title('Simulated ADC Output')
    plt.show()

if __name__ == "__main__":
    main()
