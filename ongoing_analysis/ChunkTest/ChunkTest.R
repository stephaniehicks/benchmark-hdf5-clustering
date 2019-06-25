options(warn=-1)

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))

source(here("scripts","simulate_gauss_mix.R"))

init <- as.logical(commandArgs(trailingOnly=T)[2])
file_name <- commandArgs(trailingOnly=T)[3]

if (init){
  output_table <- data.frame(matrix(vector(), 0, 7,
                             dimnames=list(c(), c("observations", "genes","batch_size", "time", "dimension", "dimension_1", "dimension_2"))),
                             stringsAsFactors=F)
  write.table(output_table, file = file_name, sep = ",", col.names = TRUE)
}

if(!init){
  chunk <- commandArgs(trailingOnly=T)[4]
  nC <- as.numeric(commandArgs(trailingOnly=T)[5])
  nG <- as.numeric(commandArgs(trailingOnly=T)[6])
  batch <- as.numeric(commandArgs(trailingOnly=T)[7])
  data_name <- commandArgs(trailingOnly=T)[8] #for large dataset
  data_name_de <- commandArgs(trailingOnly=T)[9]
  
  #for small data
  #sim_data <- simulate_gauss_mix(n_cells = nC, n_genes = nG, k = 3)
  #sim_data <- readRDS(file = data_name)
  #data <- as.matrix(sim_data$obs_data)
  
  #for large data
  if(chunk == "default"){
    sim_data_hdf5 <- HDF5Array(file = here("data",data_name_de), name = "obs")
    #sim_data_hdf5 <- writeHDF5Array(data)
    #dim <- getHDF5DumpChunkDim(dim(data))
    dim <- sim_data_hdf5@seed@chunkdim
    cluster_time <- system.time(mbkmeans::mini_batch(
      sim_data_hdf5, clusters = 3, 
      batch_size = nC*batch, num_init = 10, 
      max_iters = 100, init_fraction = 0.1,
      initializer = "random", calc_wcss = FALSE))[3]
    
    temp_table <- data.frame(observations = nC, genes = nG, batch_size = batch,  
                             time = cluster_time, dimension = chunk, dimension_1 = dim[1], dimension_2 = dim[2])
    write.table(temp_table, file = file_name, sep = ",", append = TRUE, quote = FALSE,
                col.names = FALSE, row.names = FALSE)

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
}
