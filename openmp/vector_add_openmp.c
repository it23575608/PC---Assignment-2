#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <sys/time.h>

#define N 10000000 // Array size

// Helper function to get current time in seconds
double get_time() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec * 1e-6;
}

int main() {
    int *A, *B, *C;
    double start_time, end_time;

    // Allocate memory for the arrays
    A = (int*)malloc(N * sizeof(int));
    B = (int*)malloc(N * sizeof(int));
    C = (int*)malloc(N * sizeof(int));

    if (A == NULL || B == NULL || C == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    // Initialize arrays
    for (int i = 0; i < N; i++) {
        A[i] = i;
        B[i] = i * 2;
    }

    start_time = get_time();

    // Perform vector addition using OpenMP
    #pragma omp parallel for
    for (int i = 0; i < N; i++) {
        C[i] = A[i] + B[i];
    }

    end_time = get_time();

    // Verify results (check first and last elements)
    printf("OpenMP Vector Addition\n");
    printf("Array size: %d\n", N);
    printf("C[0] = %d (Expected: %d)\n", C[0], 0 + 0);
    printf("C[%d] = %d (Expected: %d)\n", N-1, C[N-1], (N-1) + (N-1)*2);
    printf("Execution time: %f seconds\n", end_time - start_time);

    // Free memory
    free(A);
    free(B);
    free(C);

    return 0;
}
