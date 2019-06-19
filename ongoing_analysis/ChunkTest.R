options(warn=-1)

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
#library(mclust)
#library(dplyr)
#library(cowplot)
#library(parallel)
suppressPackageStartupMessages(library(HDF5Array))
#library(profvis)
suppressPackageStartupMessages(library(benchmarkme))

#funciton to simulate data
simulate_gauss_mix <- function(n_cells, n_genes,
                               k = 3, x_mus = c(0,5,5), 
                               x_sds = c(1,0.1,1), 
                               y_mus = c(5,5,0), 
                               y_sds = c(1,0.1,1), 
                               prop1 = c(0.3,0.5,0.2))
{ 
  
  if(k != length(x_mus)){stop("k is not same as length of x_mus")} 
  if(k != length(x_sds)){stop("k is not same as length of x_sds")} 
  if(k != length(y_mus)){stop("k is not same as length of y_mus")} 
  if(k != length(y_sds)){stop("k is not same as length of y_sds")} 
  if(k != length(prop1)){stop("k is not same as length of prop1")} 
  
  comp1 <- sample(seq_len(k), prob=prop1, size=n_cells, replace=TRUE)
  
  # Sampling locations for cells in each component
  samples1 <- cbind(rnorm(n=n_cells, mean=x_mus[comp1],sd=x_sds[comp1]),
                    rnorm(n=n_cells, mean=y_mus[comp1],sd=y_sds[comp1]))
  
  # Random projection to D dimensional space, to mimic high-dimensional expression data.
  proj <- matrix(rnorm(n_genes*n_cells), nrow=n_genes, ncol=2)
  A1 <- samples1 %*% t(proj)
  
  # Add normally distributed noise.
  A1 <- A1 + rnorm(n_genes*n_cells)
  rownames(A1) <- paste0("Cell", seq_len(n_cells), "-1")
  colnames(A1) <- paste0("Gene", seq_len(n_genes))
  
  list("true_center" = cbind("x" = x_mus, "y" = y_mus),
       "true_cluster_id" = comp1,
       "true_data" = samples1, 
       "obs_data" = A1)
}


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
  
  #sim_data <- simulate_gauss_mix(n_cells = nC, n_genes = nG, k = 3)
  sim_data <- readRDS(file = data_name)
  data <- as.matrix(sim_data$obs_data)
  
  if(chunk == "default"){
    sim_data_hdf5 <- writeHDF5Array(data)
    dim <- getHDF5DumpChunkDim(dim(data))
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
  
  if(chunk == "one"){
    sim_data_hdf5 <- writeHDF5Array(data, chunkdim = c(nC,1))
    cluster_time <- system.time(mbkmeans::mini_batch(
      sim_data_hdf5, clusters = 3, 
      batch_size = nC*batch, num_init = 10, 
      max_iters = 100, init_fraction = 0.1,
      initializer = "random", calc_wcss = FALSE))[3]
    
    temp_table <- data.frame(observations = nC, genes = nG, batch_size = batch,  
                             time = cluster_time, dimension = chunk, dimension_1 = nC, dimension_2 = 1)
    write.table(temp_table, file = file_name, sep = ",", append = TRUE, quote = FALSE,
                col.names = FALSE, row.names = FALSE)
  }
  
  if(chunk == "full"){
    sim_data_hdf5 <- writeHDF5Array(data, chunkdim = c(1, nG))
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
