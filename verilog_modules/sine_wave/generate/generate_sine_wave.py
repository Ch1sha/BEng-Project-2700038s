import math
import numpy as np
import matplotlib.pyplot as plt
import re
import os
from generate_half_sine_table import generateSineTable
# generate all modules in the verilog module root directory
MODULE_ROOT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

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

if __name__ == '__main__':
    bitResolution = 12
    deltaPhase = bitResolution**2 # Scale the deltaPhase to the bit resolution to get a smooth sine wave
    print("Generating sine wave table with bit resolution {} and delta phase {}".format(bitResolution, deltaPhase))
    sine_table = generateSineTable( bitResolution=bitResolution, deltaPhase=deltaPhase)
    print("Sine wave table generated with {} samples".format(len(sine_table)))

    print("Constructing sine_wave.v module")
    update_sine_wave_macros(sine_table, bitResolution)
