data_name <- "hca_bonemarrow"
suppressPackageStartupMessages(library(BiocSingular))
suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(DelayedMatrixStats))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))

DelayedArray:::set_verbose_block_processing(TRUE)
DelayedArray:::set_verbose_block_processing(TRUE)

getAutoBlockSize()
block_size <- 50000
setAutoBlockSize(block_size)

sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_normalized_0822")),  prefix="")
sce <- sce[,1:150000]
setRealizationBackend("HDF5Array")
print("start realize")
logcounts(sce) <- realize(logcounts(sce))
print("start finding vars")
vars <- DelayedMatrixStats::rowVars(logcounts(sce))
names(vars) <- rownames(sce)
vars <- sort(vars, decreasing = TRUE)
for_pca <- t(logcounts(sce)[names(vars)[1:1000],])
dim(for_pca)
start("pca")
pca <- BiocSingular::runPCA(for_pca, rank = 2,
                            scale = TRUE,
                            BSPARAM = RandomParam(deferred = TRUE),
                            #BSPARAM = FastAutoParam(),
                            BPPARAM = MulticoreParam(10))
