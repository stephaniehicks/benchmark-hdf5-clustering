library(here)
library(HDF5Array)
library(SingleCellExperiment)

size <- commandArgs(trailingOnly=T)[2]
# load in the data saved in "best" way
tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_",size), paste0("TENxBrainData_", size, "_preprocessed_best")))

# save in default way: "By default (i.e. when chunkdim is set to NULL), getHDF5DumpChunkDim(dim(x)) will be used."
saveHDF5SummarizedExperiment(tenx, 
                             dir = here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_",size), paste0("TENxBrainData_", size, "_preprocessed_default")), 
                             prefix="", replace=TRUE, 
                             level=NULL, verbose=FALSE)

# save in "worst" way
saveHDF5SummarizedExperiment(tenx, 
                             dir = here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_",size), paste0("TENxBrainData_", size, "_preprocessed_worst")),
                             prefix="", replace=TRUE, 
                             chunkdim=c(1, dim(counts(tenx))[2]), 
                             level=NULL, verbose=FALSE)

# save in single chunk
saveHDF5SummarizedExperiment(tenx, 
                             dir = here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_",size), paste0("TENxBrainData_", size, "_preprocessed_singleChunk")),
                             prefix="", replace=TRUE, 
                             chunkdim=c(dim(counts(tenx))[1], dim(counts(tenx))[2]), 
                             level=NULL, verbose=FALSE)
