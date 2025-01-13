import math
import matplotlib.pyplot as plt
import numpy as np
import re
from skopt import gp_minimize
from skopt.space import Integer
from skopt.utils import use_named_args

from generate_modules_sine import generateSineTable, optimise_sampleCount

def main():
    bitsToCycle = [i for i in range(3, 17)]
    print(bitsToCycle)
    bit_idealSample_dict = {}

    for bits in bitsToCycle:
        bit_idealSample_dict[bits] = optimise_sampleCount(bits)["optimal_sampleCount"]
    
    print(bit_idealSample_dict)
main()