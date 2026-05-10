#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#define N 10000000 // Total array size

int main(int argc, char** argv) {
    int rank, size;
    int *A = NULL, *B = NULL, *C = NULL;
    int *local_A, *local_B, *local_C;
    double start_time, end_time;

    // Initialize MPI environment
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Calculate elements per process and displacements for Scatterv/Gatherv
    int *sendcounts = (int*)malloc(size * sizeof(int));
    int *displs = (int*)malloc(size * sizeof(int));
    
    int sum = 0;
    int rem = N % size; // elements remaining after division
    for (int i = 0; i < size; i++) {
        sendcounts[i] = N / size + (i < rem ? 1 : 0);
        displs[i] = sum;
        sum += sendcounts[i];
    }
    
    int local_N = sendcounts[rank];

    // Root process initializes the full arrays
    if (rank == 0) {
        A = (int*)malloc(N * sizeof(int));
        B = (int*)malloc(N * sizeof(int));
        C = (int*)malloc(N * sizeof(int));

        if (A == NULL || B == NULL || C == NULL) {
            printf("Memory allocation failed!\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        for (int i = 0; i < N; i++) {
            A[i] = i;
            B[i] = i * 2;
        }
    }

    // Allocate memory for local arrays on all processes
    local_A = (int*)malloc(local_N * sizeof(int));
    local_B = (int*)malloc(local_N * sizeof(int));
    local_C = (int*)malloc(local_N * sizeof(int));

    // Synchronize processes before starting the timer
    MPI_Barrier(MPI_COMM_WORLD);
    if (rank == 0) start_time = MPI_Wtime();

    // Scatter the arrays A and B from root to all processes using Scatterv
    MPI_Scatterv(A, sendcounts, displs, MPI_INT, local_A, local_N, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatterv(B, sendcounts, displs, MPI_INT, local_B, local_N, MPI_INT, 0, MPI_COMM_WORLD);

    // Perform local vector addition
    for (int i = 0; i < local_N; i++) {
        local_C[i] = local_A[i] + local_B[i];
    }

    // Gather the local results back to the root process array C using Gatherv
    MPI_Gatherv(local_C, local_N, MPI_INT, C, sendcounts, displs, MPI_INT, 0, MPI_COMM_WORLD);

    // Synchronize again to accurately measure time
    MPI_Barrier(MPI_COMM_WORLD);
    
    if (rank == 0) {
        end_time = MPI_Wtime();
        printf("MPI Vector Addition\n");
        printf("Array size: %d, Processes: %d\n", N, size);
        printf("C[0] = %d (Expected: %d)\n", C[0], 0 + 0);
        printf("C[%d] = %d (Expected: %d)\n", N-1, C[N-1], (N-1) + (N-1)*2);
        printf("Execution time: %f seconds\n", end_time - start_time);

        free(A);
        free(B);
        free(C);
    }

    free(local_A);
    free(local_B);
    free(local_C);
    free(sendcounts);
    free(displs);

    // Finalize MPI environment
    MPI_Finalize();
    return 0;
}
