suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(mclust))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))

source(here("scripts","simulate_gauss_mix_k.R"))
source(here("scripts","calculate_acc.R"))
source(here("scripts","bench_hdf5_acc_k.R"))
source(here("scripts","bench_hdf5_mem.R"))
source(here("scripts","bench_hdf5_time.R"))

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
sim_center <- commandArgs(trailingOnly=T)[16]

if (mode == "mem"){
  if (size == "large"){
    rhdf5::h5disableFileLocking()
  }
}

if (init){
  if (mode == "mem"){
    if(!file.exists(here("output_files"))){
      dir.create(here("output_files"))
    }
    
    if(!file.exists(here("output_tables","Varying_k"))){
      dir.create(here("output_tables","Varying_k"))
      dir.create(here("output_tables","Varying_k","mem"))
      dir.create(here("output_tables","Varying_k","time"))
      dir.create(here("output_tables","Varying_k", "acc"))
    }
    
    dir.create(here("output_files", dir_name))
    
    profile_table <- data.frame(matrix(vector(), 0, 8, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","memory"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables","Varying_k", mode, file_name), 
                sep = ",", col.names = TRUE)
    
    sink(file = here("output_files", dir_name, "info.txt"))
    cat("RAM Info:\n")
    print(get_ram())
    cat("CPU Info: \n")
    print(get_cpu())
    cat("Session Info:\n")
    print(sessionInfo())
    sink()
  }
  
  if (mode == "acc"){
    profile_table <- data.frame(matrix(vector(), 0, 9, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","ARI","WCSS"))),
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
  set.seed(1234)
  x_mus <- runif(sim_center, min = -10, max = 10)
  set.seed(1234)
  x_sds <- sample(1:10, sim_center, replace = TRUE)/10
  set.seed(12)
  y_mus <- runif(sim_center, min = -10, max = 10)
  set.seed(123)
  y_sds <- sample(1:10, sim_center, replace = TRUE)/10
  prop1 <- rep(1/sim_center, sim_center)

  if (mode == "mem"){
    if (size == "small"){
      sim_data <- simulate_gauss_mix_k(n_cells = nC, n_genes = nG, k = sim_center, 
                                       x_mus = x_mus, x_sds = x_sds, y_mus = y_mus, y_sds = y_sds, prop1=prop1)
      
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
                            init_fraction = min(0.1, batch), initializer = initializer, 
                            method = method, size = size, dir_name = dir_name, 
                            B_name = B_name, mc.cores=cores)
    
    max_mem <- cluster_mem[[1]]
    
    temp_table <- data.frame(B_name, nC, nG, batch, k, initializer, method, max_mem)
    write.table(temp_table, file = here("output_tables","Varying_k", mode, file_name), sep = ",", 
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
  
  if (mode == "acc"){
    cluster_output <- mclapply(seq_len(B), bench_hdf5_acc_k, 
                               n_cells = nC, n_genes = nG, 
                               k_centers = k,
                               batch_size = nC*batch, num_init = 10, max_iters = 100,
                               init_fraction = 0.1, initializer = initializer, 
                               method = method, size = size, sim_center = sim_center, mc.cores=cores)
    
    cluster_acc <- mclapply(seq_len(B), calculate_acc, cluster_output, mc.cores=cores)
    
    for (i in seq_len(B)){
      temp_table <- data.frame(i, nC, nG, batch, k, initializer, 
                               method, cluster_acc[[i]]$ari, cluster_acc[[i]]$wcss)
      write.table(temp_table, file = here("output_tables","Varying_k", mode, file_name), sep = ",", 
                  append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
  }
  
  if (mode == "time"){
    if (size == "small"){
      now <- format(Sys.time(), "%b%d%H%M%OS3")
      sim_data <- simulate_gauss_mix_k(n_cells = nC, n_genes = nG, k = sim_center, 
                                       x_mus = x_mus, x_sds = x_sds, y_mus = y_mus, y_sds = y_sds, prop1=prop1)
      
      if (method == "hdf5"){
        h5File <- here("output_files", paste0(now, "_sim_data.h5"))
        h5createFile(h5File)
        h5createDataset(file = h5File, dataset = "obs", 
                        dims = dim(as.matrix(sim_data$obs_data)), chunk = c(1,nG),
                        level = 0)
        h5write(as.matrix(sim_data$obs_data), file = h5File, name = "obs" )
      }else{
        saveRDS(sim_data$obs_data, file = here("output_files", paste0(now,"_sim_data.rds")))
      }
      rm(sim_data)
      invisible(gc())
    }
    
    cluster_time <- mclapply(seq_len(B), bench_hdf5_time, 
                             n_cells = nC, n_genes = nG, 
                             k_centers = k,
                             batch_size = nC*batch, num_init = 10, max_iters = 100,
                             init_fraction = 0.1, initializer = initializer, 
                             method = method, size = size,  
                             B_name = B_name, now = now, mc.cores=cores)
    
    for (i in seq_len(B)){ 
      time <- cluster_time[[i]]
      temp_table <- data.frame(i, nC, nG, batch, k, initializer, method, time[1], time[2], time[3])
      write.table(temp_table, file = here("output_tables","Varying_k", mode, file_name), sep = ",", 
                  append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
    
    rm(cluster_time)
    rm(time)
    rm(temp_table)
    if (size == "small"){
      if (method == "hdf5"){
        file.remove(here("output_files", paste0(now, "_sim_data.h5")))
      }else{
        file.remove(here("output_files", paste0(now,"_sim_data.rds")))
      }
    }
    rm(now)
    invisible(gc())
  }
} 