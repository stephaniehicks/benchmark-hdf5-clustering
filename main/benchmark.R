library(mbkmeans)
library(rhdf5)
library(mclust)
library(dplyr)
library(parallel)
library(HDF5Array)
library(benchmarkme)
library(here)

#Bash script will be submited in main/ and use the current working directory (main/ will be cwd)
#here() will return the top directory, which is benchmark_hdf5_clustering
source(here("scripts","bench_hdf5_mem.R"))

#loading in parameters
mode <- commandArgs(trailingOnly=T)[2]
method <- commandArgs(trailingOnly=T)[3]
size <- commandArgs(trailingOnly=T)[4]
B_name <- commandArgs(trailingOnly=T)[5]
file_name <- commandArgs(trailingOnly=T)[6]
dir_name <- commandArgs(trailingOnly=T)[7]
cores <- as.numeric(commandArgs(trailingOnly=T)[8])
nC <- as.numeric(commandArgs(trailingOnly=T)[9])
nG <- as.numeric(commandArgs(trailingOnly=T)[10])
batch <- as.numeric(commandArgs(trailingOnly=T)[11])
k <- as.numeric(commandArgs(trailingOnly=T)[12])
initializer <- commandArgs(trailingOnly=T)[13]
init <- as.logical(commandArgs(trailingOnly=T)[14])

if (init){
  if (mode == "mem"){
    if(!file.exists(here("output_files"))){
      dir.create(here("output_files"))
    }
    
    dir.create(here("output_files", dir_name))
    
    profile_table <- data.frame(matrix(vector(), 0, 8, 
                                dimnames=list(c(), c("B", "observations", "genes",
                                                     "batch_size","k",
                                                     "initializer", "method","memory"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables", file_name), 
                sep = ",", col.names = TRUE)
  }
}
  
if (!init){
  if (mode == "mem"){
    #simulate data and store the data, so that it could be read back in later (only necessary for small data)
    if (size == "small"){
      sim_data <- simulate_gauss_mix(n_cells=nC, n_genes=nG, k = k)
      
      if (method == "hdf5"){
        h5File <- here("output_files", dir_name,"sim_data.h5")
        h5createFile(h5File)
        h5createDataset(file = h5File, dataset = "obs", 
                        dims = dim(as.matrix(sim_data$obs_data)), chunk = c(1,nG),
                        level = 0)
        h5write(as.matrix(sim_data$obs_data), file = h5File, name = "obs" )
      }else{
        saveRDS(sim_data$obs_data, file = here("output_files", dir_name,"sim_data.rds"))
      }
      rm(sim_data)
      invisible(gc())
    }
    
    cluster_mem <- mclapply(1, bench_hdf5_mem, 
                            n_cells = nC, n_genes = nG, 
                            k_centers = k,
                            batch_size = nC*batch, num_init = 10, max_iters = 100,
                            init_fraction = 0.1, initializer = initializer, 
                            method = method, size = size, dir_name = dir_name, 
                            B_name = B_name, mc.cores=cores)
    
    max_mem <- cluster_mem[[1]]
    
    temp_table <- data.frame(B_name, nC, nG, batch, k, initializer, method, max_mem)
    write.table(temp_table, file = here("output_tables", file_name), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    
    rm(max_mem)
    rm(cluster_mem)
    rm(temp_table)
    if (size == "small"){
      if (method == "hdf5"){
        file.remove(here("output_files", dir_name,"sim_data.h5"))
      }else{
        file.remove(here("output_files", dir_name,"sim_data.rds"))
      }
    }
    invisible(gc())
  }
} 
