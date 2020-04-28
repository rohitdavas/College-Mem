1. the algo will generate 1 << 24 elements randomly and saves it to the file input.
2. after compiling, if **there is no input file**, run : ./a.out simpy and code will generate an input file itself and proceed with calculations. 

3.[not neccessary to do] if you have input file, you can pass along with run: ./a.out input, in which case code will not need to generate random file and will be fast. [it's not necessary to do.]

to compile: nvcc prefix_sum.cu 