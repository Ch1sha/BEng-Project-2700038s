import math
import numpy as np
import matplotlib.pyplot as plt
import re
import os

# generate all modules in the verilog module root directory
MODULE_ROOT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')

def generateSineTable(bitResolution:int, deltaPhase:int) -> np.ndarray:
    """
    Generate a sine wave table with specified bit resolution and phase increment.

    :param bitResolution: The bit resolution for the output values. Default is 8 bits.
    :param deltaPhase: The phase increment for generating the sine wave. Default is 100.
    :return: A numpy array containing the sine wave values scaled to fit the specified bit resolution.
    """

    amplitude=1 # DONT CHANGE THIS, need unitary amplitude for the sine wave
    # Frequency for the sine wave (1 Hz in this case, assuming normalized sampling)
    f = 1
    angularFreq = 2 * math.pi * f

    # Generate the sine wave table with values in the range [0, 2*amplitude]
    table = amplitude * np.array([math.sin(angularFreq * i / deltaPhase) for i in range(int(-deltaPhase/4), int(deltaPhase/4))])
    
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
        file.write('module half_sine_table(\n')
        file.write('`define SINE_SIZE {}\n`define TABLE_SIZE {}\n`define TABLE_REG_SIZE {}\n'.format(SINE_SIZE, TABLE_SIZE, TABLE_REG_SIZE))
        file.write('    output logic [`SINE_SIZE-1:0] sine_wave [0:`TABLE_SIZE-1],\n')
        file.write('    output logic [`TABLE_REG_SIZE-1:0] table_size\n')
        file.write(');\n')
        file.write('    initial begin\n')
        file.write('        table_size = `TABLE_SIZE-1;\n')
        for i, value in enumerate(sine_table):
            file.write('        sine_wave[{}] = {};\n'.format(i, value))
        file.write('    end\n')
        file.write('endmodule\n')

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

    print("Constructing sine wave table module")
    construct_sine_table_module(sine_table, bitResolution)
    update_sine_wave_macros(sine_table, bitResolution)
    # plotSineWave(sine_table)
