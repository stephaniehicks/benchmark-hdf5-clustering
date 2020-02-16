options(warn=-1)

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))

size <- commandArgs(trailingOnly=T)[2]
chunk <- commandArgs(trailingOnly=T)[3]
batch <- as.numeric(commandArgs(trailingOnly=T)[4])
k <- 30


if(chunk == "default"){
  time.start <- proc.time()
  tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                            paste0("TENxBrainData_", size, "_preprocessed_default")))
  invisible(mbkmeans(counts(tenx), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), 
                     num_init=10, max_iters=100, calc_wcss = FALSE))
  time.end <- proc.time()
  time <- time.end - time.start

  temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch,  
                           time = time, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                           dimension_2 = seed(counts(tenx))@chunkdim[2])
  write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData", paste0(chunk,".csv")), 
              sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
}

#if(chunk == "one"){
#  sim_data_hdf5 <- writeHDF5Array(data, chunkdim = c(nC,1))
#  cluster_time <- system.time(mbkmeans::mini_batch(
#    sim_data_hdf5, clusters = 3, 
#    batch_size = nC*batch, num_init = 10, 
#    max_iters = 100, init_fraction = 0.1,
#    initializer = "random", calc_wcss = FALSE))[3]
#  
#  temp_table <- data.frame(observations = nC, genes = nG, batch_size = batch,  
#                           time = cluster_time, dimension = chunk, dimension_1 = nC, dimension_2 = 1)
#  write.table(temp_table, file = file_name, sep = ",", append = TRUE, quote = FALSE,
#              col.names = FALSE, row.names = FALSE)
#}

if(chunk == "full"){
  sim_data_hdf5 <- HDF5Array(file = here("data",data_name), name = "obs")
  #sim_data_hdf5 <- writeHDF5Array(data, chunkdim = c(1, nG))
  cluster_time <- system.time(mbkmeans::mini_batch(
    sim_data_hdf5, clusters = 3, 
    batch_size = nC*batch, num_init = 10, 
    max_iters = 100, init_fraction = 0.1,
    initializer = "random", calc_wcss = FALSE))[3]
  
  temp_table <- data.frame(observations = nC, genes = nG, batch_size = batch,  
                           time = cluster_time, dimension = chunk, dimension_1 = 1, dimension_2 = nG)
  write.table(temp_table, file = file_name, sep = ",", append = TRUE, quote = FALSE,
              col.names = FALSE, row.names = FALSE)
}

