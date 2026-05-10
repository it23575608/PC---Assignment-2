#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define N 10000000 // Array size

// CUDA Kernel function for vector addition
// __global__ indicates this runs on the GPU and is called from the host (CPU)
__global__ void vectorAdd(const int *__restrict__ A, const int *__restrict__ B, int *__restrict__ C, int numElements) {
    // Grid-stride loop allows handling arrays larger than the grid
    // and can improve performance by reducing kernel launch overhead
    for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < numElements; i += blockDim.x * gridDim.x) {
        C[i] = A[i] + B[i];
    }
}

int main(void) {
    size_t size = N * sizeof(int);
    
    // Allocate host (CPU) memory
    int *h_A = (int *)malloc(size);
    int *h_B = (int *)malloc(size);
    int *h_C = (int *)malloc(size);

    if (h_A == NULL || h_B == NULL || h_C == NULL) {
        printf("Failed to allocate host vectors!\n");
        return 1;
    }

    // Initialize host arrays
    for (int i = 0; i < N; ++i) {
        h_A[i] = i;
        h_B[i] = i * 2;
    }

    // Allocate device (GPU) memory
    int *d_A = NULL;
    int *d_B = NULL;
    int *d_C = NULL;

    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);

    // Create CUDA events for timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Copy data from host to device
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // Define grid and block dimensions
    // We use blocks of 256 threads
    int threadsPerBlock = 256;
    // Calculate number of blocks needed to cover all elements
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    // Start timing
    cudaEventRecord(start);

    // Launch the CUDA kernel
    // The <<<blocksPerGrid, threadsPerBlock>>> syntax configures the execution grid
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, N);

    // Stop timing
    cudaEventRecord(stop);
    
    // Copy result back to host
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    
    // Wait for the stop event to complete to get accurate timing
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    // Verify results
    printf("CUDA Vector Addition\n");
    printf("Array size: %d\n", N);
    printf("C[0] = %d (Expected: %d)\n", h_C[0], 0 + 0);
    printf("C[%d] = %d (Expected: %d)\n", N-1, h_C[N-1], (N-1) + (N-1)*2);
    printf("Execution time: %f seconds\n", milliseconds / 1000.0f);

    // Clean up
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    // Free device memory
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    // Free host memory
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
