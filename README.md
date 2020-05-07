# Benchmarking Analysis for clustering methods with HDF5 files

This repository contains code for reproducing the benchmark of the 
clustering algorithms presented in Hicks et al. (2020).

## Code to reproduce the figures

### Figure 1 and Figure 3 

Code: `/main/case_studies/01-cluster_full.R`
Bash: `/main/case_studies/bash/Makefile`
Output: `/main/case_studies/output`

### Figure 2: Accuracy 

#### Simulation

Code: `/main/benchmark.R`
Bash: `/bash for figures/Fig 2`
Output: `/output_tables/abs_batch/acc`

#### Real Data

Code: `/main/real_data_acc.R`
Bash: `/bash for figures/Fig 2/`
Output: `/output_tables/abs_batch/acc`

### Figure 4: HDF5 Geometry

Code: 

- `/ongoing_analysis/ChunkTest/TENxBrainData/Save_in_three_ways.R`
- `/ongoing_analysis/ChunkTest/TENxBrainData/TENxBrain_chunktest.R`

Bash: `/bash for figures/Fig 4`
Output: `/ongoing_analysis/ChunkTest/TENxBrainData/Output`

### Supp Figure -  Varying K analysis

First generate 10 datasets to be used later with `/main/simulation_k.R`

Code: `/main/benchmark_varying_k.R`
Bash: `/bash for figures/Varying_k/`
Output: `/output_tables/Varying_k`

### Others:

`/output_tables/acc`; `/output_tables/mem`; `/output_tables/time`: these are results for simulation memory, time and accuracy with percentage batch sizes.

## How to

If want to:

- Benchmark simulation data

Code: `/main/benchmark.R`
Note: In `benchmark.R`, only accuracy uses absolute batch sizes. Time and memory use percentage batch sizes.

- Benchmark real data

Everything is in `/main/case_studies`, except one script written to benchmark real data accuracy is in `/main/real_data_acc.R`. The difference between `/main/real_data_acc.R` and  `/main/case_studies/01-cluster_full.R` is that the former only benchmarks accuracy, and it uses `mclapply` to quickly run multiple times.
