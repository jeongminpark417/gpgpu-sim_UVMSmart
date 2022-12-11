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

#define clock_value_t  long long;

__device__ void c_sleep(long long sleep_cycles)
{
    long long start = clock64();
    long long cycles_elapsed;
    do { cycles_elapsed = clock64() - start; } 
    while (cycles_elapsed < sleep_cycles);
}

__global__ void Test_kernel(DATA_TYPE *A, DATA_TYPE *B)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	int a1 = A[i];
	int a2 = A[i+1];
	
//	if(threadIdx.x != 0) return;

	if(a1 < a2){
		for(int k = a1; a1 < a2; a1++){
			a2 = (a1 | a2);
		}
	}
	else{
		int a3 = a1;
		a1 = a2;
		a2 = a3;
		for(int k = a1; a1 < a2; a1++){ 
			a2 = (a1 | a2); 
		}
	}
	int temp = (a1 + A[i]) + (a2 + A[i + 1]);	
	int x = 0;
	for(int k = 0; k < 100; k++){
		if ((temp)  == 0) x++;	
	}	
	B[i] =temp + x;


//c_sleep(10000);	

	
}


void Test(DATA_TYPE* A, DATA_TYPE* B)
{
	
	Test_kernel<<<10, 32>>>(A, B);

	cudaDeviceSynchronize();
}


int main(int argc, char *argv[])
{
	DATA_TYPE* A;
	DATA_TYPE* B;  

	cudaMallocManaged( &A, 2*NI*NJ*sizeof(DATA_TYPE) );
	cudaMallocManaged( &B, 2*NI*NJ*sizeof(DATA_TYPE) );

	Test(A, B);
	

	cudaFree(A);
	cudaFree(B);
	
	return 0;
}

