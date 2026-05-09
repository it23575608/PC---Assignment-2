#!/bin/bash

# A simple script to compile and benchmark the Parallel Computing assignment implementations.

echo "======================================"
echo " Starting Parallel Computing Benchmarks"
echo "======================================"

# Array to store execution times for summary
declare -A execution_times

# 1. OpenMP
echo ""
echo "[1] Compiling and running OpenMP implementation..."
if gcc -fopenmp openmp/vector_add_openmp.c -o openmp/vector_add_openmp; then
    echo "Compilation successful. Running..."
    # Capture output to extract time
    output=$(./openmp/vector_add_openmp)
    echo "$output"
    time_val=$(echo "$output" | grep "Execution time" | awk '{print $3}')
    execution_times["OpenMP"]=$time_val
else
    echo "Failed to compile OpenMP program. Ensure gcc and OpenMP are installed."
    execution_times["OpenMP"]="Failed"
fi

# 2. MPI
echo ""
echo "[2] Compiling and running MPI implementation..."
if mpicc mpi/vector_add_mpi.c -o mpi/vector_add_mpi; then
    echo "Compilation successful. Running with 4 processes..."
    output=$(mpirun -np 4 ./mpi/vector_add_mpi)
    echo "$output"
    time_val=$(echo "$output" | grep "Execution time" | awk '{print $3}')
    execution_times["MPI"]=$time_val
else
    echo "Failed to compile MPI program. Ensure OpenMPI is installed."
    execution_times["MPI"]="Failed"
fi

# 3. CUDA
echo ""
echo "[3] Compiling and running CUDA implementation..."
if command -v nvcc &> /dev/null; then
    if nvcc cuda/vector_add_cuda.cu -o cuda/vector_add_cuda; then
        echo "Compilation successful. Running..."
        output=$(./cuda/vector_add_cuda)
        echo "$output"
        time_val=$(echo "$output" | grep "Execution time" | awk '{print $3}')
        execution_times["CUDA"]=$time_val
    else
        echo "Failed to compile CUDA program."
        execution_times["CUDA"]="Failed"
    fi
else
    echo "nvcc not found. Skipping CUDA compilation. Ensure CUDA Toolkit is installed and in your PATH."
    execution_times["CUDA"]="Skipped (nvcc not found)"
fi

echo ""
echo "======================================"
echo " Benchmark Summary"
echo "======================================"
printf "%-15s | %-15s\n" "Framework" "Time (seconds)"
echo "--------------------------------------"
printf "%-15s | %-15s\n" "OpenMP" "${execution_times[OpenMP]}"
printf "%-15s | %-15s\n" "MPI" "${execution_times[MPI]}"
printf "%-15s | %-15s\n" "CUDA" "${execution_times[CUDA]}"
echo "======================================"
