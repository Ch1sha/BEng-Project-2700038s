import argparse
import concurrent.futures
import os
import math
import matplotlib.pyplot as plt
import numpy as np
import re
from skopt import gp_minimize
from skopt.space import Integer
from skopt.utils import use_named_args
from scipy.optimize import curve_fit
# generate all modules in the verilog module root directory
MODULE_ROOT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

## ============ half_sine_table.v generation ============
def generateSineTable(bitResolution:int, sampleCount:int) -> np.ndarray:
    """
    Generate a sine wave table with specified bit resolution and phase increment.

    :param bitResolution: The bit resolution for the output values. Default is 8 bits.
    :param sampleCount: The phase increment for generating the sine wave. Default is 100.
    :return: A numpy array containing the sine wave values scaled to fit the specified bit resolution.
    """

    amplitude=1 # DONT CHANGE THIS, need unitary amplitude for the sine wave
    # Frequency for the sine wave (1 Hz in this case, assuming normalized sampling)
    f = 1
    angularFreq = 2 * math.pi * f

    # Generate the sine wave table with values in the range [0, 2*amplitude]
    table = amplitude * np.array([math.sin(angularFreq * i / sampleCount) for i in range(int(-sampleCount/4), int(sampleCount/4))])

    # Scale to fit unsigned bit resolution, centred around amplitude
    max_val = (2 ** bitResolution) - 1  # Maximum value for the unsigned range
    table = np.round((table + 1) * (max_val / 2)).astype(int)  # Shifted and scaled
    return table

def construct_sine_table_module(sine_table: np.ndarray, bitResolution: int, filename='half_sine_table.v'):
    """
    Constructs a Verilog module for a sine wave table.

    This function generates a Verilog module that represents a sine wave table.
    The generated module includes an array of sine wave values and the size of the table.

    :param sine_table: List of integer values representing the sine wave.
    :param bitResolution: Integer representing the bit resolution of the sine wave values.
    :param filename: String representing the name of the output Verilog file. Default is 'half_sine_table.v'.
    """

    SINE_SIZE = bitResolution
    TABLE_SIZE = len(sine_table)
    TABLE_REG_SIZE = math.ceil(math.log2(TABLE_SIZE+1))
    filepath = os.path.join(MODULE_ROOT_PATH, filename)

    with open(filepath, 'w') as file:
        file.write('`define SINE_SIZE {}\n`define TABLE_SIZE {}\n`define TABLE_REG_SIZE {}\n\n'.format(SINE_SIZE, TABLE_SIZE, TABLE_REG_SIZE))
        file.write('module half_sine_table(\n')
        file.write('    output logic [`SINE_SIZE-1:0] sine_wave [0:`TABLE_SIZE-1],\n')
        file.write('    output logic [`TABLE_REG_SIZE-1:0] table_size\n')
        file.write(');\n')
        file.write('    initial begin\n')
        file.write('        table_size = `TABLE_SIZE-1;\n')
        for i, value in enumerate(sine_table):
            file.write('        sine_wave[{}] = {};\n'.format(i, value))
        file.write('    end\n')
        file.write('endmodule\n')

def optimise_sampleCount(bitCount, min_sample_val=None, max_sample_val=None, n_calls=100, n_initial_points=100, random_state=42):
    """
    Perform Bayesian optimisation to find the optimal sampleCount for a given bitcount.
    
    Parameters:
        n (int): Number of bits for amplitude resolution.
        m_min (int): Minimum value for `m` (default: 2^n).
        m_max (int): Maximum value for `m` (default: 4 * 2^n).
        n_calls (int): Number of optimisation calls (default: 50).
        n_initial_points (int): Number of initial points for the optimisation (default: 10).
        random_state (int): Random seed for reproducibility (default: 42).
        
    Returns:
        dict: A dictionary containing the optimal `m`, the minimum loss, and optimisation results.
    """
    # Default range for sampleCount
    if min_sample_val is None:
        min_sample_val = 2*bitCount**2
    if max_sample_val is None:
        max_sample_val = 4 * 2**bitCount

    # Define the search space for the sampleCount
    search_space = [Integer(min_sample_val, max_sample_val, name="sampleCount")]

    # Define the loss function
    def loss_function(bitCount, sampleCount):
        sine_table = generateSineTable(bitCount, sampleCount)
        unique_values = len(np.unique(sine_table))
        repeated_values = sampleCount - unique_values

        alpha = 0.05
        max_value = (2 ** bitCount) - 1

        # Penalty if the highest value is not achieved
        penalty = 0
        if sine_table.max() < max_value:
            penalty = 1000  # Large penalty to ensure this condition is prioritised
        return repeated_values - (alpha * sampleCount) + penalty

    # Define the optimisation function to wrap the loss function
    @use_named_args(search_space)
    def objective(**params):
        sampleCount = params["sampleCount"]
        return loss_function(bitCount, sampleCount)

    # Perform Bayesian optimisation
    result = gp_minimize(
        func=objective,
        dimensions=search_space,
        n_calls=n_calls,
        n_initial_points=n_initial_points,
        random_state=random_state, # For reproducibility
        verbose=False,
    )

    # Extract and return the results
    optimal_sampleCount = result.x[0]
    minimum_loss = result.fun

    return {
        "optimal_sampleCount": optimal_sampleCount,
        "minimum_loss": minimum_loss,
        "result": result,
    }


# ============ sine_wave.v generation ============
def update_sine_wave_macros(sine_table: np.ndarray, bitResolution: int, filename = 'sine_wave.v'):
    """
    Update the macro definitions for the sine_wave.v module.

    :param sine_table: List of integer values representing the sine wave.
    :param file_path: Path to the Verilog file to be updated.
    :param macros: Dictionary with macro names as keys and new values as values.
    """

    SINE_SIZE:int = bitResolution
    TABLE_SIZE:int = len(sine_table)
    TABLE_REG_SIZE:int = math.ceil(math.log2(TABLE_SIZE+1))
    file_path = os.path.join(MODULE_ROOT_PATH, filename)
    macros = {"SINE_SIZE": SINE_SIZE, "TABLE_SIZE": TABLE_SIZE, "TABLE_REG_SIZE": TABLE_REG_SIZE}

    with open(file_path, 'r') as file:
        content = file.read()

    # Regex pattern to match Verilog macros (e.g., `define NAME VALUE)
    pattern = r"`define\s+(\w+)\s+(.+)"

    def replacer(match):
        macro_name = match.group(1)
        # Replace the macro value if it's in the dictionary
        if macro_name in macros:
            new_value = macros[macro_name]
            return f"`define {macro_name} {new_value}"
        return match.group(0)  # Keep the original line if macro not in dictionary

    # Replace macros in the Verilog file
    updated_content = re.sub(pattern, replacer, content)

    # Overwrite the original file
    with open(file_path, 'w') as file:
        file.write(updated_content)

def plotSineWave(sine_table: np.ndarray):
    """
    Plots a sine wave using the provided sine table.

    :param sine_table: A numpy array containing the sine wave values to be plotted.
    :type sine_table: np.ndarray
    """

    plt.plot(sine_table)
    plt.title('Sine Wave')
    plt.xlabel('Samples')
    plt.ylabel('Sine Value')
    plt.grid(True)
    plt.show()

def main():
    parser = argparse.ArgumentParser(description='Generate a sine wave table.')
    parser.add_argument('--bit_count', type=int, default=8, help='The bit resolution for the sine wave values.')
    args = parser.parse_args()

    bitResolution = args.bit_count
    optimisation_results = optimise_sampleCount(bitResolution)
    sampleCount = optimisation_results["optimal_sampleCount"]
    deltaPhase = 360 / sampleCount

    # global variable to store the optimised sample count, to be used by generate_sine_wave.py
    global OPTIMISED_SAMPLE_COUNT
    OPTIMISED_SAMPLE_COUNT = sampleCount

    sine_table = generateSineTable(bitResolution=bitResolution, sampleCount=sampleCount)
    print("\nSine wave table generated with bit resolution = {}, delta phase = {}, and {} samples".format(bitResolution, deltaPhase, len(sine_table)))

    construct_sine_table_module(sine_table, bitResolution)
    print("half_sine_table.v generated with SINE_SIZE = {} and TABLE_SIZE = {}".format(bitResolution, len(sine_table)))

    update_sine_wave_macros(sine_table, bitResolution)
    print("sine_wave.v updated with SINE_SIZE = {} and TABLE_SIZE = {}\n".format(bitResolution, len(sine_table)))


def plot_ideal_sampleCount_data(maxBits=16):
    minBits = 2

    def optimise_sampleCount_wrapper(bits):
        return bits, optimise_sampleCount(bits)["optimal_sampleCount"]
    
    def thread_done_callback(future):
        bits, optimal_sampleCount = future.result()
        print(f"Thread done for bits: {bits}, optimal_sampleCount: {optimal_sampleCount}")

    bitsToCycle = np.arange(minBits, maxBits+1)
    print(bitsToCycle)

    # Use ThreadPoolExecutor for multithreading
    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = [executor.submit(optimise_sampleCount_wrapper, bits) for bits in bitsToCycle]
        for future in futures:
            future.add_done_callback(thread_done_callback)

    # Collect the results
    results = [future.result() for future in futures]


    # Populate the dictionary with the results
    bit_idealSample_dict = {bits: optimal_sampleCount for bits, optimal_sampleCount in results}
    print(bit_idealSample_dict)
    idealSamples = list(bit_idealSample_dict.values())

    # === Now try to fit the data to a curve
    # Define the exponential function
    exponential = lambda x, a, b, c : a * np.exp(b * x) + c
    #fit the data to the exponential curve
    params, covariance = curve_fit(exponential, bitsToCycle, idealSamples)
    a, b, c = params
    print(f"Exponential fit: a={a}, b={b}, c={c}")
    # Generate smooth x values for plotting the fitted curve
    x_smooth = np.linspace(min(bitsToCycle), max(bitsToCycle), 500)
    y_smooth = exponential(x_smooth, a, b, c)
    
    # Plot the original data points
    plt.scatter(bitsToCycle, idealSamples, label="Data Points", color="blue", zorder=5)

    # Plot the fitted exponential curve
    plt.plot(x_smooth, y_smooth, label=f"Fitted Curve: $y = {a:.2f}e^{{{b:.2f}x}} + {c:.2f}$", color="red", linewidth=2)

    # Add labels, legend, and title
    plt.xlabel('Bit Resolution')
    plt.ylabel('Ideal Sample Count')
    plt.title("Exponential Fit to Data")
    plt.legend()
    plt.grid(True)
    plt.show()

if __name__ == '__main__':
    main()
