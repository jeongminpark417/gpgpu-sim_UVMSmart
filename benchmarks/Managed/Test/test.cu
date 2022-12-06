/**
 * 2DConvolution.cu: This file is part of the PolyBench/GPU 1.0 test suite.
 *
 *
 * Contact: Scott Grauer-Gray <sgrauerg@gmail.com>
 * Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://www.cse.ohio-state.edu/~pouchet/software/polybench/GPU
 */

#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <sys/time.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <cuda.h>

//define the error threshold for the results "not matching"
#define PERCENT_DIFF_ERROR_THRESHOLD 0.05

#define GPU_DEVICE 0

/* Problem size */
#define NI 1024
#define NJ 1024

/* Thread block dimensions */
#define DIM_THREAD_BLOCK_X 32
#define DIM_THREAD_BLOCK_Y 8

/* Can switch DATA_TYPE between float and double */
typedef float DATA_TYPE;

__global__ void Test_kernel(DATA_TYPE *A, DATA_TYPE *B)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;

	B[i] = A[i];	
}


void Test(DATA_TYPE* A, DATA_TYPE* B)
{
	
	Test_kernel<<<10, 64>>>(A, B);

	cudaDeviceSynchronize();
}


int main(int argc, char *argv[])
{
	DATA_TYPE* A;
	DATA_TYPE* B;  

	cudaMallocManaged( &A, NI*NJ*sizeof(DATA_TYPE) );
	cudaMallocManaged( &B, NI*NJ*sizeof(DATA_TYPE) );

	Test(A, B);
	

	cudaFree(A);
	cudaFree(B);
	
	return 0;
}

