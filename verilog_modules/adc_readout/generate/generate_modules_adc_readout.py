import argparse
import os
import math
import matplotlib.pyplot as plt
import numpy as np
import re

MODULE_ROOT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
ADC_OUTPUT_SIMULATION_PATH = os.path.join(MODULE_ROOT_PATH, 'simulate/')

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
    return range(num_samples), adc_output

def export_to_csv(data, filename):
    """
    Export the given data to a CSV file with two columns.

    Args:
        data (tuple): Tuple containing two arrays (x and y) to be exported.
        filename (str): Name of the CSV file.
    """
    x, y = data
    np.savetxt(filename, np.column_stack((x, y)), delimiter=",", fmt='%d', header="Sample,Amplitude", comments='')

def plotSineWave(sine_table: np.ndarray):
    """
    Plots a sine wave using the provided sine table.

    :param sine_table: A numpy array containing the sine wave values to be plotted.
    :type sine_table: np.ndarray
    """

    plt.step(*sine_table, where='mid')
    plt.title('Simulated ADC Output')
    plt.xlabel('Samples')
    plt.ylabel('Value')
    plt.grid(True)
    plt.show()

def main():
    parser = argparse.ArgumentParser(description='Generate Verilog modules for ADC readout')
    parser.add_argument('--data_width', type=int, default=12, help='Data width of the ADC readout module')
    parser.add_argument('--buffer_size', type=int, default=4096, help='Size of the buffer')
    parser.add_argument('--no_generate', action='store_true', help='Do not generate and update the sine wave verilog modules.')
    parser.add_argument('--sim_adc',type=int, nargs='+', default=1, help='Simulate the ADC output and export to a CSV file: x y z where x is the wave frequency, y is the number of adc output samples, and z is the sample rate')
    parser.add_argument('--plot', action='store_true', help='Plot the simulated ADC output')
    args = parser.parse_args()

    data_width = args.data_width
    buffer_size = args.buffer_size

    if not args.no_generate:
        print("Generating ADC readout modules...")
        print(f"Data width: {data_width}")
        print(f"Buffer size: {buffer_size}")   
        update_adc_readout(data_width)
        update_adc_buffer(data_width, buffer_size)
   
    if args.sim_adc:
        frequency = args.sim_adc[0]
        num_samples = args.sim_adc[1] if len(args.sim_adc) > 1 else 4096
        sampling_rate = args.sim_adc[2] if len(args.sim_adc) > 2 else 100

        print(f"Simulating ADC output: Frequency={frequency}, Num Samples={num_samples}, Sampling Rate={sampling_rate}")
        adc_output = simulate_adc_output(data_width, num_samples, frequency, sampling_rate)

        # export the ADC output to a CSV file
        export_to_csv(adc_output, os.path.join(ADC_OUTPUT_SIMULATION_PATH, 'adc_output.csv'))

        if args.plot:
            print("Plotting the simulated ADC output...")
            plotSineWave(adc_output)

if __name__ == "__main__":
    main()
