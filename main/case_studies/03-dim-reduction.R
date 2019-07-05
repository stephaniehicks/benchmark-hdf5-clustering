# Dimensionality reduction

library(BiocSingular)
library(BiocParallel)
library(DelayedMatrixStats)

# **Ruoxi**: load the sce object

## need to do this otherwise it takes forever -- ask Herve about this
setRealizationBackend("HDF5Array")
system.time(logcounts(sce) <- realize(logcounts(sce)))

## find most variable genes
system.time(vars <- DelayedMatrixStats::rowVars(logcounts(sce)))
names(vars) <- rownames(sce)
vars <- sort(vars, decreasing = TRUE)

for_pca <- t(logcounts(sce)[names(vars)[1:1000],])

system.time(pca <- BiocSingular::runPCA(for_pca, rank = 30,
                                        scale = TRUE,
                                        BSPARAM = RandomParam(deferred = FALSE),
                                        BPPARAM = MulticoreParam(6)))

reducedDim(sce, "PCA") <- pca$x

# **Ruxoi**: save the PCs somewhere e.g. 
# saveRDS(pca, file="pca.rds")
