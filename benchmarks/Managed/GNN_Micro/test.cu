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
#define NI 2048
#define NJ 2048

/* Thread block dimensions */
#define DIM_THREAD_BLOCK_X 32
#define DIM_THREAD_BLOCK_Y 8

/* Can switch DATA_TYPE between float and double */
typedef int DATA_TYPE;

#define clock_value_t  long long;

__device__ void c_sleep(long long sleep_cycles)
{
    long long start = clock64();
    long long cycles_elapsed;
    do { cycles_elapsed = clock64() - start; } 
    while (cycles_elapsed < sleep_cycles);
}

__global__ void Test_kernel(DATA_TYPE *A, DATA_TYPE *B, int* C)
{

	__shared__ int s_temp;

	long bidx = blockIdx.x;
	for(int itr = 0; itr < 1; itr++){
		int temp2 = 0;
			for(int j = 0; j < 5; j++){
			temp2 += B[bidx*1024*512 + threadIdx.x + j * 1024*514+itr];
			}
		C[bidx * 64 + threadIdx.x] = temp2 +  C[bidx * 64 + threadIdx.x] ;
		__syncthreads();	

		if(threadIdx.x == 0){
			int temp = 0;
			for(int j = 0; j < 5;j++){
				temp += A[(bidx + itr % 3) * 1024 * 512 * j];
			}
			s_temp = temp;
		}
		__syncthreads();
		//reguar
		 temp2 = 0;
			for(int j = 0; j < 5; j++){
			temp2 += B[bidx*1024*512 + threadIdx.x + j * 1024*514+itr];
			}
		C[bidx * 64 + threadIdx.x + 1] = temp2 + C[bidx * 64 + threadIdx.x + 1];
		__syncthreads();	
	}	
}


void Test(DATA_TYPE* A, DATA_TYPE* B, DATA_TYPE* C)
{
	
	Test_kernel<<<1, 128>>>(A, B, C);

	cudaDeviceSynchronize();
}


int main(int argc, char *argv[])
{
	DATA_TYPE* A;
	DATA_TYPE* B;  
	DATA_TYPE* C;
	
	cudaMallocManaged( &A, 2*NI*NJ*sizeof(DATA_TYPE) );
	cudaMallocManaged( &B, 2*NI*NJ*sizeof(DATA_TYPE) );
	cudaMallocManaged( &C, 2*NI*NJ*sizeof(DATA_TYPE) );


	Test(A, B,C);
	

	cudaFree(A);
	cudaFree(B);
	
	return 0;
}

