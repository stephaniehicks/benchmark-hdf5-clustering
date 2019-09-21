
# Notes: normalization is a crucial step in the preprocessing of the results. 
# Here, we use the `scran` package to compute size factors that we will 
# use to compute the normalized log-expression values.

# It has been shown that the scran method works best if the size factors
# are computed within roughly homogeneous cell populations; hence, it is 
# beneficial to run a quick clustering on the raw data to compute better
# size factors. This ensures that we do not pool cells that are very different. 
# Note taat this is not the final clustering to identify cell sub-populations.
data_name <- commandArgs(trailingOnly=T)[2]
B_name <- commandArgs(trailingOnly=T)[3]

suppressPackageStartupMessages(library(scran))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))
library(doParallel)
library(BiocParallel)

DelayedArray:::set_verbose_block_processing(TRUE)
DelayedArray:::set_verbose_block_processing(TRUE)

getAutoBlockSize()
block_size <- 10000
setAutoBlockSize(block_size)

now <- format(Sys.time(), "%b%d%H%M%S")
out_name <- paste0(data_name,"_02_", now, ".out")

Rprof(filename = here("main/case_studies/output/Memory_output", out_name), append = FALSE, memory.profiling = TRUE)
clusters <- readRDS(file = here("main/case_studies/data/full", data_name, paste0(data_name, "_cluster_full.rds")))
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")

# next comes calculating size factors
time.start <- proc.time()
sce <- computeSumFactors(sce, min.mean=0.1, cluster=clusters$Clusters, BPPARAM=MulticoreParam(10))
#sce <- computeSumFactors(sce[,1:1000], min.mean=0.1, cluster=clusters$Clusters[1:1000],
#                                   BPPARAM=MulticoreParam(10))

# It can be useful to check whether the size factors are 
# correlated with the total number of reads per cell.
#plot(sce$total_counts, sizeFactors(sce), log="xy", xlab="Total reads", ylab="scran size factors")

# Finally, we compute normalized log-expression values with 
# the `normalize()` function from the `scater` package.

sce <- scater::normalize(sce)

# Note that the log-normalized data are stored in the
# `logcounts` assay of the object. Since the `counts` assay 
# is a `DelayedMatrix` and we have only one set of size 
# factors in the object, also the normalized data are 
# stored as a `DelayedMatrix`.

#logcounts(sce)

# This allows us to store in memory only the `colData` 
# and `rowData`, resulting in a fairly small object.

#library(pryr)
#object_size(sce)
time.end <- proc.time()
Rprof(NULL)

time <- time.end - time.start
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "02_normalization", "other", "NA", 1, time[1], time[2],time[3], "10")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", out_name), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "02_normalization", "other", "NA", B_name, max_mem, "10")
write.table(temp_table, file = here("main/case_studies/output/Output_Memory.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)

#Save the new sce object
time.start2 <- proc.time()
saveHDF5SummarizedExperiment(sce, 
                             dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_normalized")), 
                             prefix="", replace=FALSE, 
                             chunkdim=c(dim(counts(sce))[1],1), 
                             level=NULL, verbose=FALSE)
time.end2 <- proc.time()
time2 <- time.end2 - time.start2
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "02_saving the normalized sce", "other", "NA", 1, time[1], time[2],time[3], "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
