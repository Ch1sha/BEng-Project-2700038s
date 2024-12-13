import argparse
import os
import math
import numpy as np
import matplotlib.pyplot as plt
import re
from generate_half_sine_table import generateSineTable, MODULE_ROOT_PATH

# Function to update macros in the Verilog file
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
    deltaPhase = bitResolution**2 # Scale the deltaPhase to the bit resolution to get a smooth sine wave

    sine_table = generateSineTable(bitResolution=bitResolution, deltaPhase=deltaPhase)
    print("Sine wave table generated with bit resolution = {}, delta phase = {}, and {} samples".format(bitResolution, deltaPhase, len(sine_table)))

    update_sine_wave_macros(sine_table, bitResolution)
    print("sine_wave.v updated with SINE_SIZE = {} and TABLE_SIZE = {}\n".format(bitResolution, len(sine_table)))

if __name__ == '__main__':
    main()
