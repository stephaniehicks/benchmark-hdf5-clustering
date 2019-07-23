
# Notes: normalization is a crucial step in the preprocessing of the results. 
# Here, we use the `scran` package to compute size factors that we will 
# use to compute the normalized log-expression values.

# It has been shown that the scran method works best if the size factors
# are computed within roughly homogeneous cell populations; hence, it is 
# beneficial to run a quick clustering on the raw data to compute better
# size factors. This ensures that we do not pool cells that are very different. 
# Note taat this is not the final clustering to identify cell sub-populations.
data_name <- commandArgs(trailingOnly=T)[2]

time.start <- proc.time()
library(scran)
library(HDF5Array)
clusters <- readRDS(file = here("main/case_studies/data/full", data_name, paste0(data_name, "_cluster_full.rds")))
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")

# next comes calculating size factors
sce <- computeSumFactors(sce, min.mean=0.1, cluster=clusters$Clusters,
                                     BPPARAM=MulticoreParam(10))

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


#Save the new sce object? 
saveHDF5SummarizedExperiment(sce, 
                             dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_normalized")), 
                             prefix="", replace=FALSE, 
                             chunkdim=c(dim(counts(sce))[1],1), 
                             level=NULL, verbose=FALSE)
time.end <- proc.time()
time <- time.end - time.start
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "02_normalization", "", 1, time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
