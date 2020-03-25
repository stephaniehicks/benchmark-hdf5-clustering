suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(SingleCellExperiment))
suppressPackageStartupMessages(library(mbkmeans))

Rprof(filename = here("main/case_studies/output/Memory_output","500k_hdf5_500bs.out"), append = FALSE, memory.profiling = TRUE)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData/TENxBrainData_500k/TENxBrainData_500k_preprocessed_best"), prefix="")
invisible(mbkmeans(counts(sce), clusters=15, batch_size=500, num_init=1, max_iters=100,compute_labels=FALSE))
Rprof(NULL)
