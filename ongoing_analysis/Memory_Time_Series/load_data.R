suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(pryr))
suppressPackageStartupMessages(library(SingleCellExperiment))

Rprof(filename = here("main/case_studies/output/Memory_output","500k_interactive_3.out"), append = FALSE, memory.profiling = TRUE)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData/TENxBrainData_500k/TENxBrainData_500k_preprocessed_best"), prefix="")
Rprof(NULL)