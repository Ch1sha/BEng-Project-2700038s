import pandas as pd
import matplotlib.pyplot as plt
import os

# Read the CSV file
csv_file = os.path.join(os.path.dirname(__file__),'signal_gen_top_output.csv')

data = pd.read_csv(csv_file) 

x = data['c']
y = data['s']
z = data['p']
t = data['i']

# Plot the sine wave
plt.step(x, y)
plt.title('Sine Wave Simulation', fontsize=20)
plt.xlabel('Clock Cycle',fontsize=16)
plt.ylabel('Amplitude (uint)', fontsize=16)
plt.grid(True)
plt.show()
