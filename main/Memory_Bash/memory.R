suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(mclust))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))
rhdf5::h5disableFileLocking()

#loading in parameters
method <- commandArgs(trailingOnly=T)[2]
nC <- as.numeric(commandArgs(trailingOnly=T)[3])
nG <- as.numeric(commandArgs(trailingOnly=T)[4])
batch <- as.numeric(commandArgs(trailingOnly=T)[5])
initializer <- commandArgs(trailingOnly=T)[6]
data_path <- commandArgs(trailingOnly=T)[7]
index <- 14

if (method == "kmeans"){
  mydata <- readRDS(file = paste0(data_path, "/", "obs_data_", nC, "_", index, ".rds"))
  invisible(stats::kmeans(mydata, centers=3, iter.max = 100, nstart = 10))
}

if (method == "mbkmeans"){
  mydata <- readRDS(file = paste0(data_path, "/", "obs_data_", nC, "_", index, ".rds"))
  invisible( mbkmeans::mini_batch(mydata, clusters = 3, 
                       batch_size = nC*batch, num_init = 10, 
                       max_iters = 100, init_fraction = min(batch, 0.1),
                       initializer = initializer, calc_wcss = FALSE))
}

if (method == "hdf5"){
  sim_data_hdf5 <- HDF5Array(file = paste0(data_path, "/", "obs_data_", nC, "_", index, ".h5"), name = "obs")
  invisible(mbkmeans::mini_batch(sim_data_hdf5, clusters = 3, 
                       batch_size = nC*batch, num_init = 10, 
                       max_iters = 100, init_fraction = min(batch, 0.1),
                       initializer = initializer, calc_wcss = FALSE))
}

