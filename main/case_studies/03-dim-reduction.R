# Dimensionality reduction
data_name <- commandArgs(trailingOnly=T)[2]
B_name <- commandArgs(trailingOnly=T)[3]


library(BiocSingular)
library(BiocParallel)
library(DelayedMatrixStats)

library(HDF5Array)
library(here)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_normalized")),  prefix="")
## need to do this otherwise it takes forever -- ask Herve about this

setRealizationBackend("HDF5Array")
time <- system.time(logcounts(sce) <- realize(logcounts(sce)))
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_realize logcounts", "", B_name, time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)
invisible(gc())

## find most variable genes
time <- system.time(vars <- DelayedMatrixStats::rowVars(logcounts(sce)))
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_find var", "", B_name, time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)
invisible(gc())

names(vars) <- rownames(sce)
vars <- sort(vars, decreasing = TRUE)

for_pca <- t(logcounts(sce)[names(vars)[1:1000],])

time <- system.time(pca <- BiocSingular::runPCA(for_pca, rank = 30,
                                        scale = TRUE,
                                        BSPARAM = RandomParam(deferred = FALSE),
                                        BPPARAM = MulticoreParam(10)))

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_pca", "", B_name, time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

reducedDim(sce, "PCA") <- pca$x

saveRDS(pca, file=here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca.rds")))
saveHDF5SummarizedExperiment(sce, 
                             dir = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca")), 
                             prefix="", replace=FALSE, 
                             chunkdim=c(dim(counts(sce))[1],1), 
                             level=NULL, verbose=FALSE)