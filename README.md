# Parallel Computing: Environment Setup and Optimization

Welcome to the Parallel Computing assignment! This guide is designed to serve as a beginner-friendly tutorial for 3rd-year IT students. It will walk you through setting up your environment, writing basic parallel programs using OpenMP, MPI, and CUDA, and comparing their performance.

## 1. Environment Setup (Ubuntu)

To get started, you will need to install the necessary compilers and libraries for OpenMP, MPI, and CUDA. Run the following commands in your Ubuntu terminal.

### 1.1. GCC and OpenMP
OpenMP is typically bundled with the GNU Compiler Collection (GCC). Install GCC using:
```bash
sudo apt update
sudo apt install build-essential
```
To verify the installation:
```bash
gcc --version
```

### 1.2. OpenMPI
OpenMPI is an open-source implementation of the Message Passing Interface (MPI) standard.
```bash
sudo apt install openmpi-bin libopenmpi-dev
```
To verify the installation:
```bash
mpicc --version
mpirun --version
```

### 1.3. CUDA Toolkit
If your system has an NVIDIA GPU, you can install the CUDA toolkit. 
```bash
sudo apt install nvidia-cuda-toolkit
```
To verify the installation:
```bash
nvcc --version
```

---

## 2. Compilation and Execution

The repository contains a `vector_add` example for each framework. Here is how to compile and run each one manually. 

Alternatively, you can use the provided `benchmark.sh` script to run all of them at once!

### 2.1. OpenMP
**Compile:**
```bash
gcc -fopenmp openmp/vector_add_openmp.c -o openmp/vector_add_openmp
```
*The `-fopenmp` flag tells the compiler to recognize OpenMP directives (like `#pragma omp`).*

**Execute:**
```bash
./openmp/vector_add_openmp
```

### 2.2. MPI
**Compile:**
```bash
mpicc mpi/vector_add_mpi.c -o mpi/vector_add_mpi
```

**Execute:**
```bash
mpirun -np 4 ./mpi/vector_add_mpi
```
*The `-np 4` argument specifies that the program should be run using 4 separate processes.*

### 2.3. CUDA
**Compile:**
```bash
nvcc cuda/vector_add_cuda.cu -o cuda/vector_add_cuda
```

**Execute:**
```bash
./cuda/vector_add_cuda
```

---

## 3. Hardware Optimization (Placeholder)

*Note: This section will be expanded in your final report based on your specific hardware and benchmark results.*

When evaluating parallel performance, simply writing parallel code isn't enough; you must tune it to your hardware's specifications.

*   **OpenMP (Thread Count):** Performance generally improves as you increase the number of threads up to the number of physical CPU cores. Exceeding this can lead to context-switching overhead. You can control this via the `OMP_NUM_THREADS` environment variable.
*   **MPI (Process Distribution):** Distributing processes across multiple physical nodes over a network introduces communication overhead. Optimization involves minimizing data transfer (e.g., in `MPI_Scatter` and `MPI_Gather`) and maximizing computation.
*   **CUDA (Memory Coalescing & Cores):** GPUs possess thousands of CUDA cores designed for massive throughput. To fully utilize them, memory accesses must be "coalesced" (threads in a warp accessing contiguous memory blocks). Additionally, the Grid and Block dimensions (e.g., threads per block) should be tuned according to the GPU's streaming multiprocessor (SM) architecture.
*   **L3 Cache:** The size of your CPU's L3 cache dictates how much data can be kept close to the processing cores. If your array size far exceeds the L3 cache, you will incur significant main memory latency penalties, often bottlenecking performance before CPU compute limits are reached.

---

## 4. Troubleshooting

If you run into issues, check the following common pitfalls:

*   **"command not found: nvcc"**: 
    *   *Cause:* The CUDA toolkit is either not installed or its `bin` directory is not in your system's `PATH`.
    *   *Fix:* Add `export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}` to your `~/.bashrc` file and run `source ~/.bashrc`.
*   **"MPI_ERR_OTHER: known error not in list" or Network Issues with mpirun**:
    *   *Cause:* OpenMPI can sometimes get confused by loopback interfaces or multiple network adapters.
    *   *Fix:* Try running with `mpirun --mca btl_tcp_if_include lo -np 4 ...` to restrict it to the local loopback interface.
*   **NVIDIA Driver Conflicts**:
    *   *Cause:* You may have upgraded your kernel, causing a mismatch with the loaded NVIDIA driver (e.g., `nvidia-smi` fails).
    *   *Fix:* Reboot your machine or reinstall the specific driver version: `sudo apt install --reinstall nvidia-driver-<version>`.
*   **Array Size Not Divisible by Processes (MPI)**:
    *   *Cause:* Our basic MPI implementation requires the total array size to be evenly divisible by the number of processes (the `-np` argument).
    *   *Fix:* Ensure `N % num_processes == 0` or modify the MPI code to handle remainders using `MPI_Scatterv`.
