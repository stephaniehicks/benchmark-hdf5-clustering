# Dimensionality reduction

library(BiocSingular)
library(BiocParallel)
library(DelayedMatrixStats)

# **Ruoxi**: load the sce object
library(HDF5Array)
library(here)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full/hca_bonemarrow", 
                                               "hca_bonemarrow_normalized_final"),  prefix="")
## need to do this otherwise it takes forever -- ask Herve about this
setRealizationBackend("HDF5Array")
time <- system.time(logcounts(sce) <- realize(logcounts(sce)))
temp_table <- data.frame("hca_bonemarrow", dim(counts(sce))[2], dim(counts(sce))[1], "03_realize logcounts", "", time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

## find most variable genes
time <- system.time(vars <- DelayedMatrixStats::rowVars(logcounts(sce)))
temp_table <- data.frame("hca_bonemarrow", dim(counts(sce))[2], dim(counts(sce))[1], "03_find var", "", time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

names(vars) <- rownames(sce)
vars <- sort(vars, decreasing = TRUE)

for_pca <- t(logcounts(sce)[names(vars)[1:1000],])

time <- system.time(pca <- BiocSingular::runPCA(for_pca, rank = 30,
                                        scale = TRUE,
                                        BSPARAM = RandomParam(deferred = FALSE),
                                        BPPARAM = MulticoreParam(10)))

temp_table <- data.frame("hca_bonemarrow", dim(counts(sce))[2], dim(counts(sce))[1], "03_pca", "", time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

reducedDim(sce, "PCA") <- pca$x

# **Ruxoi**: save the PCs somewhere e.g. 
saveRDS(pca, file=here("main/case_studies/data/pca/hca_bonemarrow/hca_bonemarrow_pca.rds"))
saveHDF5SummarizedExperiment(sce, 
                             dir = here("main/case_studies/data/full/hca_bonemarrow", "hca_bonemarrow_pca"), 
                             prefix="", replace=FALSE, 
                             chunkdim=c(dim(counts(sce))[1],1), 
                             level=NULL, verbose=FALSE)
        
