# Benchmarking Analysis for clustering methods with HDF5 files

This repository contains code for reproducing the benchmark of the 
clustering algorithms presented in Hicks et al. (2020).

## Installing necessary packages

We assume that Bioconductor is already installed on your R session. To get a list of all R packages used, run the bash script `findPackageDependencies.sh`. This script searches our files and finds all of the libraries called by our code, and will create a file `installPackages.R` which looks like:

```
BiocManager::install(c("benchmarkme",
"BiocParallel",
"cowplot",
...
```
You can use the code in the file `installPackages.R` to install the necessary packages, for example by running

```
R CMD BATCH installPackages.R
```
or by cutting and pasting the code into a R session. It can take some time to install all packages.

## Data

In this section, we describe the files that need to be run to create the data used in our analysis. 

### Preprocess the `TENxBrainData` dataset 

First, we importing the `TENxBrainData` [dataset available on ExperimentHub](https://bioconductor.org/packages/TENxBrainData) with 1.3 million cells. 
In the following script, we remove low-quality cells, and remove lowly expressed genes. 
Finally, we save the preprocessed object using `saveHDF5SummarizedExperiment()`. 

- Code: `main/case_studies/preprocessing/TENxBrainData.Rmd`
- Bash: `main/case_studies/preprocessing/TENxBrainData.sh` (only for running the `.Rmd` on JHPCE cluster)
- Output: 
    - `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed` (column chunk size)
    - `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed_default` (default chunk size)

These data are used in Figure 5. 

### Downsample the preprocessed `TENxBrainData` dataset

Next, we create downsampled sizes of datasets (sizes 75k, 150k, 300k, 500k, 750k, 1M) from the preprocessed object described in the section above. 

- Input data: `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed` (column chunk size)
- Code: `main/case_studies/preprocessing/TENxSubset.Rmd`
- Bash: `main/case_studies/preprocessing/TENxSubset.sh` (only for running the `.Rmd` on JHPCE cluster)
- Output data: 
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_75k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_150k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_300k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_500k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_750k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_1000k`    

These downsampled datasets are used in Figures 1, 3, and 4.

- Output data: 
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_5k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_10k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_25k`    

These downsampled datasets are used in Figure 2. 

### Varying K analysis

First generate 10 datasets to be used later with `/main/simulation_k.R`

- Code: `/main/benchmark_varying_k.R`
- Bash: `/bash for figures/Varying_k/` 
- Output: `/output_tables/Varying_k`

Thes datasets are used in a supplemental figure. 

## Code used for each analysis

In this section, we describe the code used for each analysis and the location of the output files. 

### Figure 1 and Figure 3 

- Input data: 
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_75k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_150k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_300k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_500k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_750k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_1000k`    
- Code: `/main/case_studies/01-cluster_full.R`
- Bash: `/main/case_studies/bash/Makefile`
- Output files: `/main/case_studies/output`

### Figure 2: Accuracy 

#### Simulation

The data used in this section is simulated using the arguments defined in the `.sh` file which is used as input in the `/main/benchmark.R` script. 
The `/main/benchmark.R` script is the main workhorse here calling relevant helper files in the `scripts/` folder e.g. `scripts/bench_hdf5_time.R` to benchmark computational time using HDF5 files. 

- Bash: (only for running `.R` script on JHPCE cluster)
    - `/bash for figures/Fig 2/abs_benchmark_acc_km_1k25k.sh`
    - `/bash for figures/Fig 2/abs_benchmark_acc_mbkm_1k25k.sh`
    - `/bash for figures/Fig 2/abs_benchmark_acc_hdf5_1k25k.sh`
- Code: `/main/benchmark.R`
- Output files: `/output_tables/abs_batch/acc`

Each `.sh` file uses the the `/main/benchmark.R` script 

**Note**: In the script `/main/benchmark.R`, _absolute batch sizes_ are used for assessing accuracy, but at the moment _relative batch sizes_ are used for assessing time and memory. This reflects our original plan of using relative batch sizes and not updating the code (for time and memory) in this file as it is no longer used in the manuscript. 

**Note**: We actually have kept the output in the repository from the simulations using _relative batch sizes_, even though we ultimately did not include these results in the manuscript. If you are curious, the output results for simulation memory, time and accuracy with relative batch sizes can be found here: 
  -`/output_tables/acc`
  -`/output_tables/mem`
  -`/output_tables/time`


#### Real Data

The `/main/real_data_acc.R` script is the main workhorse here calling relevant helper files in the `scripts/` folder. 

- Input data: 
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_5k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_10k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_25k`    
- Bash: (only for running `.R` script on JHPCE cluster)
    - `/bash for figures/Fig 2/real_data_acc_hdf5.sh`
- Code: `/main/real_data_acc.R`
- Output files: `/output_tables/abs_batch/acc`

**Note**: Almost all scripts related to evaluations using the `TENxBrainData` are found in the `/main/case_studies` folder, except one: `/main/real_data_acc.R` script used to evaluate accuracy using the downsampled datasets (sizes 5k, 10k, 25k). The difference between `/main/real_data_acc.R` and  `/main/case_studies/01-cluster_full.R` is that the former only benchmarks accuracy, and it uses `mclapply` to quickly run multiple times.

### Figure 4: HDF5 Geometry

In this analysis, we take each downsampled datasets, save them in multiple ways (default chunk size, row chunk size, column chunk size, or entirely in 1 chunk) using the `/bash for figures/Fig 4/Save_in_three_ways.sh` bash script, which uses the `/ongoing_analysis/ChunkTest/TENxBrainData/Save_in_three_ways.R` R script.
Next, we assess both time and memory with `mbkmeans()` using these HDF5 datasets saved with different chunk size geometries. 

- Input data: 
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_75k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_150k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_300k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_500k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_750k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_1000k`
- Bash: (only for running `.R` script on JHPCE cluster)
    - `/bash for figures/Fig 4/Save_in_three_ways.sh`
    - `/bash for figures/Fig 4/TENxBrain_chunktest_time.sh`
    - `/bash for figures/Fig 4/TENxBrain_chunktest_mem.sh`    
- Code: 
    - `/ongoing_analysis/ChunkTest/TENxBrainData/Save_in_three_ways.R`
    - `/ongoing_analysis/ChunkTest/TENxBrainData/TENxBrain_chunktest.R`
- Output files: `/ongoing_analysis/ChunkTest/TENxBrainData/Output`


### Figure 5: Full analysis of `TENxBrainData`

In this section, we use the full 1.3 million dataset that was preprocessed (removed low quality cells and lowly expressed genes). 

The main analysis consists of normalization, PCA, clustering, and visualization (tSNE/UMAP). 

- Input data: `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed`
- Code: `main/case_studies/full_analysis.Rmd`
- Output files: `main/case_studies/data/full/TENxBrainData`


### Supplemental figures 

#### Varying K analysis

First generate 10 datasets to be used later with `/main/simulation_k.R`

- Code: `/main/benchmark_varying_k.R`
- Bash: `/bash for figures/Varying_k/`
- Output: `/output_tables/Varying_k`

These datasets are used in a supplemental figure. 


## Code to create figures

In the section above, a set of output files are created at the end of each analysis. 
These output files are combined in the following `.Rmd` and used to create the figures in the manuscript.

- Code: `main/summary_manuscript_figures.Rmd`


## Performance evaluation

### Accuracy

To assess the accuracy, we used two performance metrics: 

- Adjusted Rand Index (ARI)  is a measure of similarity between the estimated cluster labels and the true cluster labels (or a "gold standard"). The range of ARI is between 0 and 1, where 0 refers to no similarity between the cluster labels and 1 means the clusters labels are the same. We used the `adjustedRandIndex()` function in *mclust*
- Within-Clusters Sums-of-Squares (WCSS) is defined as the sum of the squared distance between each member of the cluster and its centroid. It does not depend on having true cluster labels. 

### Memory

We used the `Rprof` function in the *utils* package as part of base R with the arguments `append=FALSE` and `memory.profiling=TRUE` to record the memory usage every 0.02 seconds (the default for the argument `interval` in the `Rprof()` function is 0.02). The recorded profiles will be saved in an `.out` output file. To summarize and interpret the output files, we used the `summaryRprof()` function in the `utils` package with the arguments `memory = "tseries"` and `diff = FALSE` to generate a time series table of the memory consumption in R. The first three columns of the table are `vsize.small`, `vsize.large` and `nodes` respectively. By the documentation of the function `summaryRprof()`: `vsize.small` is the vector memory in small blocks on the R heap; `vsize.large` is the vector memory in large blocks; `"Nodes"` is the memory in nodes on the R heap. And the sum of these three is the total memory. So we extracted the max memory by finding the max of the sum of the three columns, and use this max memory to benchmark the memory efficiency of the algorithm.


### Time

We used the function `proc.time()` in base R to record the 'user time' (the CPU time charged for the execution of user instructions of the calling process), the 'system time' (the CPU time charged for execution by the system on behalf of the calling process), and the 'elapsed time' (the real time to run the process). The function `proc.time()` returned time in seconds and we converted to appropriate units (e.g. minutes or hours). 


