import pandas as pd
import matplotlib.pyplot as plt
import os



# Read the CSV file
csv_file = os.path.join(os.path.dirname(__file__), 'simulate','sine_wave_output.csv')
data = pd.read_csv(csv_file, header=None, names=['x', 'y'])

x = data['x']
y = data['y']

# Plot the sine wave
plt.plot(x, y)
plt.title('Sine Wave')
plt.xlabel('sample')
plt.ylabel('sine wave')
plt.grid(True)
plt.show()