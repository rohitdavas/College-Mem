there are two programs i have written

1. the Factorial.cu - the bigint support for gpu is not available, and to explore parallelism, I was not able to write the bigint support for CUDA.
    this programs works well upto 20! on GPU.

2. However, I wrote the bigint support for cpu file BigInt.cpp and it can upto a very large number factorial on CPU.

3. Please compile both using ** nvcc filename **