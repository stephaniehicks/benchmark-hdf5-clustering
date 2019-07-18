# Cluster with mbkmeans on the PCs

# regular mbkmeans and kmeans
# load in pca.rds for kmeans
# benchmark both memory and time
data_name <- commandArgs(trailingOnly=T)[2]
mode <- commandArgs(trailingOnly=T)[3]
B_name <- commandArgs(trailingOnly=T)[4]
batch <- 0.001

library(HDF5Array)
library(here)
library(mbkmeans)

mbkmeans_time <- function(data_name, k, batch){
  time.start <- proc.time()
  sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
  set.seed(1234)
  clusters <- mbkmeans(sce, reduceMethod = "PCA", clusters=k, 
                       batch_size = as.integer(dim(counts(sce))[2]*batch),
                       num_init=10, max_iters=100, calc_wcss  )
}

if (mode == "time"){
  invisible(gc())
}

set.seed(1234)
system.time(wcss <- lapply(5:10, function(k) {
  cl <- mbkmeans(counts(sce), clusters = k,
                 batch_size = 10, num_init=10, max_iters=100,
                 calc_wcss = TRUE)
  
  #cl <- mbkmeans(sce, reduceMethod = "PCA", clusters = k,
  #               batch_size = 3000, num_init=10, max_iters=100,
  #               calc_wcss = TRUE)
}))

set.seed(1234)
system.time(mbkmeans(sce, reduceMethod = "PCA", clusters = 10,
                 batch_size = 3000, num_init=10, max_iters=100,
                 calc_wcss = TRUE)
            )