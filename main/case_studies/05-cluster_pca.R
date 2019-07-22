# Cluster with mbkmeans on the PCs

# regular mbkmeans and kmeans
# load in pca.rds for kmeans
# benchmark both memory and time

# batch size 1% and 5%
# record the cluster labels 
data_name <- commandArgs(trailingOnly=T)[2]
mode <- commandArgs(trailingOnly=T)[3]
B_name <- commandArgs(trailingOnly=T)[4]
method <- commandArgs(trailingOnly=T)[5]
batch <- 0.01

if (mode == "time"){
  invisible(gc())
  if (method == "mbkmeans"){
    
  }
}

pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca.rds")))



mbkmeans_time <- function(data_name, k, batch){
  time.start <- proc.time()
  sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca")), prefix="")
  set.seed(1234)
  clusters <- mbkmeans(sce, reduceMethod = "PCA", clusters=k, 
                       batch_size = as.integer(dim(counts(sce))[2]*batch),
                       num_init=10, max_iters=100, calc_wcss  )
}

set.seed(1234)
system.time(mbkmeans(sce, reduceMethod = "PCA", clusters = 10,
                     batch_size = 3000, num_init=10, max_iters=100,
                     calc_wcss = TRUE)
)