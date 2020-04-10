suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(mclust))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))
rhdf5::h5disableFileLocking()

#Bash script will be submited in main/ and use the current working directory (main/ will be cwd)
#here() will return the top directory, which is benchmark_hdf5_clustering
source(here("scripts","simulate_gauss_mix_k.R"))
source(here("scripts","calculate_acc.R"))
source(here("scripts","bench_hdf5_acc_k.R"))
source(here("scripts","bench_hdf5_mem_k.R"))
source(here("scripts","bench_hdf5_time_k.R"))

#loading in parameters
init <- as.logical(commandArgs(trailingOnly=T)[2])
mode <- commandArgs(trailingOnly=T)[3]
dir_name <- commandArgs(trailingOnly=T)[4]
file_name <- commandArgs(trailingOnly=T)[5]
method <- commandArgs(trailingOnly=T)[6]
size <- commandArgs(trailingOnly=T)[7]
B_name <- commandArgs(trailingOnly=T)[8]
cores <- as.numeric(commandArgs(trailingOnly=T)[9])
nC <- as.numeric(commandArgs(trailingOnly=T)[10])
nG <- as.numeric(commandArgs(trailingOnly=T)[11])
batch <- as.numeric(commandArgs(trailingOnly=T)[12])
k <- as.numeric(commandArgs(trailingOnly=T)[13])
initializer <- commandArgs(trailingOnly=T)[14]
B <- commandArgs(trailingOnly=T)[15]
sim_center <- as.numeric(commandArgs(trailingOnly=T)[16])
data_path <- commandArgs(trailingOnly=T)[17]
max_iters <- as.numeric(commandArgs(trailingOnly=T)[18])
num_init <- as.numeric(commandArgs(trailingOnly=T)[19])

if (init){
  if(!file.exists(here("output_files"))){
    dir.create(here("output_files"))
  }
  
  if(!file.exists(here("output_tables","Varying_k"))){
    dir.create(here("output_tables","Varying_k"))
    dir.create(here("output_tables","Varying_k","mem"))
    dir.create(here("output_tables","Varying_k","time"))
    dir.create(here("output_tables","Varying_k", "acc"))
  }
  
  if (mode == "mem"){
    dir.create(here("output_files", dir_name))
    
    profile_table <- data.frame(matrix(vector(), 0, 8, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","memory"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables","Varying_k", mode, file_name), 
                sep = ",", col.names = TRUE)
    
    #sink(file = here("output_files", dir_name, "info.txt"))
    #cat("RAM Info:\n")
    #print(get_ram())
    #cat("CPU Info: \n")
    #print(get_cpu())
    #cat("Session Info:\n")
    #print(sessionInfo())
    #sink()
  }
  
  if (mode == "acc"){
    profile_table <- data.frame(matrix(vector(), 0, 11, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","ARI","WCSS", "iterations", "fault"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables","Varying_k", mode, file_name), 
                sep = ",", col.names = TRUE)
  }
  
  if (mode == "time"){
    profile_table <- data.frame(matrix(vector(), 0, 10, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","user_time", "system_time", "elapsed_time"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables","Varying_k", mode, file_name), 
                sep = ",", col.names = TRUE)
    
    sink(file = here("output_tables","Varying_k", mode, paste0(dir_name, "_info.txt"))) #dir_name is same as file_name, except dir_name doesn't have ".csv"
    cat("RAM Info:\n")
    print(get_ram())
    cat("CPU Info: \n")
    print(get_cpu())
    cat("Session Info:\n")
    print(sessionInfo())
    sink()
  }
}

if (!init){
  if (size == "small"){
    index <- sample(c(1:50), 1)
  }
  if(size == "large"){
    index <- sample(c(1:10), 1)
  }
  
  if (mode == "mem"){
    cluster_mem <- mclapply(1, bench_hdf5_mem_k, 
                            n_cells = nC, n_genes = nG, 
                            k_centers = k,
                            batch_size = batch, num_init = num_init, max_iters = max_iters,
                            #init_fraction = min(0.1, batch), 
                            initializer = initializer, 
                            method = method, size = size, dir_name = dir_name, 
                            index = index, mc.cores=cores)
    
    max_mem <- cluster_mem[[1]]
    
    temp_table <- data.frame(B_name, nC, nG, batch, k, initializer, method, max_mem)
    write.table(temp_table, file = here("output_tables","Varying_k", mode, file_name), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
  }
  
  if (mode == "acc"){
    cluster_output <- mclapply(seq_len(B), bench_hdf5_acc_k, 
                               n_cells = nC, n_genes = nG, 
                               k_centers = k,
                               batch_size = batch, num_init = num_init, max_iters = max_iters,
                               init_fraction = 0.1, initializer = initializer, 
                               method = method, size = size, sim_center = sim_center, mc.cores=cores)
    
    cluster_acc <- mclapply(seq_len(B), calculate_acc, cluster_output, method, mc.cores=cores)
  
    for (i in seq_len(B)){
      temp_table <- data.frame(i, nC, nG, batch, k, initializer, 
                               method, cluster_acc[[i]]$ari, cluster_acc[[i]]$wcss, cluster_acc[[i]]$iters, cluster_acc[[i]]$fault, num_init, max_iters)
      write.table(temp_table, file = here("output_tables", "Varying_k", mode, file_name), sep = ",", 
                  append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
  }
  
  if (mode == "time"){
    cluster_time <- mclapply(seq_len(B), bench_hdf5_time_k, 
                             n_cells = nC, n_genes = nG, 
                             k_centers = k,
                             batch_size = batch, num_init = num_init, max_iters = max_iters,
                             initializer = initializer, 
                             method = method, size = size,  
                             index = index, mc.cores=cores)
    
    for (i in seq_len(B)){ 
      time <- cluster_time[[i]]
      temp_table <- data.frame(i, nC, nG, batch, k, initializer, method, time[1], time[2], time[3])
      write.table(temp_table, file = here("output_tables","Varying_k", mode, file_name), sep = ",", 
                  append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
  }
} 