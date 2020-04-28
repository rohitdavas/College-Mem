#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <cmath>

#define POWER 24
#define THREAD 1024 

using namespace std;

__global__
void add_kernel(double *d_a, double *d_tmp, long k, long n)
{
    long i = blockIdx.x*blockDim.x + threadIdx.x;

    if (i + k < n)
    {
        d_tmp[i+k] = d_a[i+k] + d_a[i];
    }
}


__host__
double verify(double *a, double *b, long n)
{
    double *v; 
    v = (double *) malloc(n*sizeof(double));

    for (int i = 0; i < n; i++)
    {
        v[i] = a[i];
    }

    for (int i = 1; i<n; i++)
    {
        v[i] = v[i] + v[i-1];
    }

    for (int i = 1; i < n; i++)
    {
        v[i] = v[i] + v[i-1];
    }

    double maxError = 0; 
    for (int i = 0; i < n; i++)
    {
        maxError = fmax(maxError, fabs(v[i] - b[i]));
    }

    return maxError/v[n-1];
}



int main(int argc, const char *argv[])
{       
    if(argc == 1)
    {
        printf("filling the file with random inputs..\n");

        FILE *fp = fopen("./input","w");

        if (fp == NULL){
            printf("file pointer cannot be created\n");
            return 1; 
        }

        int n = 1 << 24;
        printf("no of elemets are: %d\n",n);
        fprintf(fp, "%d\n", n);

        srand(time(NULL));

        for (int i=0; i<n; i++)
            fprintf(fp, "%lg\n", ((double)(rand() % n))/100);

        fclose(fp);
        printf("Finished writing\n");
    }

    else if(argc ==2)
    {
        printf("input file provided. data will be read from it.");
    }


    FILE *fp = fopen("input","r");

    if (fp == NULL)
    {
        printf("there must be a file created in your current folder. please check and update the fopen.");
        return 1;
    }

    long n;
    fscanf(fp, "%ld\n", &n);
    printf("value of n: %ld\n",n);

    double *a = (double *)malloc(n*sizeof(double));
    double *b = (double *)malloc(n*sizeof(double));

    printf("reading the file... ");
    for(int i = 0; i<n; i++)
    {
        fscanf(fp, "%lg\n", &a[i]);
    } 
    printf("done.\n");

    fclose(fp);  

    printf("gpu computation start ...\n");
    //allocate memory on gpu 
    double *d_a, *d_tmp;
    cudaMalloc(&d_a, n*sizeof(double));
    cudaMalloc(&d_tmp, n*sizeof(double)); 

    // copy from cpu to gpu 
    cudaMemcpy(d_a, a, n*sizeof(double), cudaMemcpyHostToDevice);

    // copy content into temporary array
    cudaMemcpy(d_tmp, d_a, n*sizeof(double), cudaMemcpyDeviceToDevice);

    // first pass 

    for(long p = 0; p<= POWER; p++){
        add_kernel << <(n+THREAD -1)/THREAD, THREAD>>>(d_a, d_tmp,1<<p, n);
        cudaMemcpy(d_a, d_tmp, n*sizeof(double), cudaMemcpyDeviceToDevice);
    }


    //second pass 
    for(long p = 0; p<= POWER; p++){
        add_kernel << <(n+THREAD -1)/THREAD, THREAD>>>(d_a, d_tmp,1<<p, n);
        cudaMemcpy(d_a, d_tmp, n*sizeof(double), cudaMemcpyDeviceToDevice);
    }

    //copy back to cpu 
    cudaMemcpy(b, d_a, n*sizeof(double), cudaMemcpyDeviceToHost);

    //free memory on gpu 
    cudaFree(d_a);
    cudaFree(d_tmp);

    printf("gpu computation done.\n");

    //verify the answer
    printf("verifying results of GPU with classical approach\n");
    double max_error = verify(a, b, n);
    printf("error margin: %f\n\n", max_error);

}