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
- Output: `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed`

These data are used in Figure 5. 

### Downsample `TENxBrainData` data 

Next, we create downsampled sizes of datasets (sizes 75k, 150k, 300k, 500k, 750k, 1M) from the preprocessed object described in the section above. 

- Input data: `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed`
- Code: `main/case_studies/preprocessing/TENxBrainData.Rmd`
- Output data: 
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_75k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_150k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_300k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_500k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_750k`
    - `main/case_studies/data/subset/TENxBrainData/TENxBrainData_1000k`    

These downsampled datasets are used in Figures 1, 3.


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

- Input data: 
- Code: `/main/benchmark.R`
- Bash: `/bash for figures/Fig 2`
- Output files: `/output_tables/abs_batch/acc`

#### Real Data

- Input data: 
- Code: `/main/real_data_acc.R`
- Bash: `/bash for figures/Fig 2/`
- Output files: `/output_tables/abs_batch/acc`

### Figure 4: HDF5 Geometry

- Code: 
    - `/ongoing_analysis/ChunkTest/TENxBrainData/Save_in_three_ways.R`
    - `/ongoing_analysis/ChunkTest/TENxBrainData/TENxBrain_chunktest.R`
- Bash: `/bash for figures/Fig 4`
- Output files: `/ongoing_analysis/ChunkTest/TENxBrainData/Output`

### Figure 5: Full analysis of `TENxBrainData`

In this section, we use the full 1.3 million dataset that was preprocessed to remove low quality cells and lowly expressed genes. 

#### Main Analysis: Normalization, PCA, Clustering, Visualization (tSNE/UMAP)

- Input data: `main/case_studies/data/full/TENxBrainData/TENxBrainData_preprocessed`
- Code: `main/case_studies/full_analysis.Rmd`
- Output files: `main/case_studies/data/full/TENxBrainData`


### Supplemental figures 

#### Varying K analysis

First generate 10 datasets to be used later with `/main/simulation_k.R`

- Code: `/main/benchmark_varying_k.R`
- Bash: `/bash for figures/Varying_k/`
- Output: `/output_tables/Varying_k`

Thes datasets are used in a supplemental figure. 

#### Others:

`/output_tables/acc`; `/output_tables/mem`; `/output_tables/time`: these are results for simulation memory, time and accuracy with percentage batch sizes.


## Code to create figures

In the section above, a set of output files are created at the end of each analysis. 
These output files are combined in the following `.Rmd` and used to create the figures in the manuscript.

- Code: `main/summary_manuscript_figures.Rmd`


## How to

If want to:

- Benchmark simulation data

Code is in `/main/benchmark.R`.
Note: In `benchmark.R`, only accuracy uses absolute batch sizes. Time and memory use percentage batch sizes.

- Benchmark real data

Everything is in `/main/case_studies`, except one script written to benchmark real data accuracy is in `/main/real_data_acc.R`. The difference between `/main/real_data_acc.R` and  `/main/case_studies/01-cluster_full.R` is that the former only benchmarks accuracy, and it uses `mclapply` to quickly run multiple times.

## Performance evaluation

### Accuracy
To assess the accuracy, we used two performance metrics: 

* Adjusted Rand Index (ARI)  is a measure of similarity between the estimated cluster labels and the true cluster labels (or a "gold standard"). The range of ARI is between 0 and 1, where 0 refers to no similarity between the cluster labels and 1 means the clusters labels are the same. We used the `adjustedRandIndex` function in *mclust*
* Within-Clusters Sums-of-Squares (WCSS) is defined as the sum of the squared distance between each member of the cluster and its centroid. It does not depend on having true cluster labels. 

### Memory

We used the `Rprof` function in the *utils* package as part of base R with the arguments `append=FALSE` and `memory.profiling=TRUE` to record the memory usage every 0.02 seconds (the default for the argument `interval` in the `Rprof` function is 0.02). The recorded profiles will be saved in an `.out` output file. To summarize and interpret the output files, we used the `summaryRprof` function in the `utils` package with the arguments `memory = "tseries"` and `diff = FALSE` to generate a time series table of the memory consumption in R. The first three columns of the table are `vsize.small`, `vsize.large` and `nodes` respectively. By the documentation of the function `summaryRprof`: `vsize.small` is the vector memory in small blocks on the R heap; `vsize.large` is the vector memory in large blocks; `"Nodes"` is the memory in nodes on the R heap. And the sum of these three is the total memory. So we extracted the max memory by finding the max of the sum of the three columns, and use this max memory to benchmark the memory efficiency of the algorithm.


### Time

We used the function `proc.time` in base R to record the 'user time' (the CPU time charged for the execution of user instructions of the calling process), the 'system time' (the CPU time charged for execution by the system on behalf of the calling process), and the 'elapsed time' (the real time to run the process). The function `proc.time` returned time in seconds and we converted to appropriate units (e.g. minutes or hours). 


