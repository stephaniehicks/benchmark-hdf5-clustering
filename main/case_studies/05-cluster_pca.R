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
batch <- as.numeric(commandArgs(trailingOnly=T)[5])
k <- as.numeric(commandArgs(trailingOnly=T)[6])

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(here))

if (mode == "time"){
  invisible(gc())
  if (method == "mbkmeans"){
    time.start <- proc.time()
    data_pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.rds")))
    set.seed(1234)
    clusters <- mbkmeans:: mini_batch(data_pca, cluster = k, batch_size = as.integer(dim(data_pca)[1]*batch),
                                      num_init=1, max_iters=100, calc_wcss = FALSE)
    time.end <- proc.time()
    time <- time.end - time.start
    
    temp_table <- data.frame(data_name, dim(data_pca)[1], dim(data_pca)[2], "05_pca cluster", method, batch, B_name, time[1], time[2],time[3], "1", k)
    write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
    
  }
  
  if (method == "hdf5"){
    time.start <- proc.time()
    real_data_hdf5 <- HDF5Array(file = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.h5")), name = "obs")
    set.seed(1234)
    clusters <- mbkmeans::mini_batch(real_data_hdf5, clusters = k, 
                                     batch_size = as.integer(dim(real_data_hdf5)[1]*batch), num_init = 10, 
                                     max_iters = 100, calc_wcss = FALSE)
    time.end <- proc.time()
    time <- time.end - time.start
    
    temp_table <- data.frame(data_name, dim(real_data_hdf5)[1], dim(real_data_hdf5)[2], "05_pca cluster", method, batch, B_name, time[1], time[2],time[3], "1", k)
    write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
  
  if (method == "kmeans"){
    time.start <- proc.time()
    data_pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.rds")))
    set.seed(1234)
    clusters <- stats::kmeans(data_pca, centers=k, iter.max = 100, nstart = 1)
    time.end <- proc.time()
    time <- time.end - time.start
    
    temp_table <- data.frame(data_name, dim(data_pca)[1], dim(data_pca)[2], "05_pca cluster", method, batch, B_name, time[1], time[2],time[3], "1", k)
    write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
  if (B_name == "1"){
    saveRDS(clusters, file = here("main/case_studies/data/pca", data_name, paste0(data_name,"_",method, "_cluster_final.rds")))
  }
}

if (mode == "memory"){
  invisible(gc())
  now <- format(Sys.time(), "%b%d%H%M%OS3")
  out_name <- paste0(data_name, "_", now, ".out")
  
  if (method == "mbkmeans"){
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    data_pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.rds")))
    clusters <- mbkmeans:: mini_batch(data_pca, cluster = k, batch_size = as.integer(dim(data_pca)[1]*batch),
                                      num_init=1, max_iters=100, calc_wcss = FALSE)
    Rprof(NULL)
    
    profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), chunksize = -1L, 
                            memory = "tseries", diff = FALSE)
    max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
    
    temp_table <- data.frame(data_name, dim(data_pca)[1], dim(data_pca)[2], "05_pca cluster", method, batch, B_name, max_mem, "1",k)
    write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
  
  if (method == "hdf5"){
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    real_data_hdf5 <- HDF5Array(file = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.h5")), name = "obs")
    clusters <- mbkmeans::mini_batch(real_data_hdf5, clusters = k, 
                                     batch_size = as.integer(dim(real_data_hdf5)[1]*batch), num_init = 10, 
                                     max_iters = 100, calc_wcss = FALSE)
    Rprof(NULL)
    
    profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), chunksize = -1L, 
                            memory = "tseries", diff = FALSE)
    max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
    
    temp_table <- data.frame(data_name, dim(real_data_hdf5)[1], dim(real_data_hdf5)[2], "05_pca cluster", method, batch, B_name, max_mem, "1", k)
    write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
  
  if (method == "kmeans"){
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    data_pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.rds")))
    clusters <- stats::kmeans(data_pca, centers=k, iter.max = 100, nstart = 1)
    Rprof(NULL)
    
    profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), chunksize = -1L, 
                            memory = "tseries", diff = FALSE)
    max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
    
    temp_table <- data.frame(data_name, dim(data_pca)[1], dim(data_pca)[2], "05_pca cluster", method, batch, B_name, max_mem, "1", k)
    write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
}

if (mode == "acc"){
  if (method == "mbkmeans"){
    data_pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.rds")))
    set.seed(1234)
    clusters <- mbkmeans:: mini_batch(data_pca, cluster = k, batch_size = as.integer(dim(data_pca)[1]*batch),
                                      num_init=1, max_iters=100, calc_wcss = TRUE)
    temp_table2 <- data.frame(data_name, dim(data_pca)[1], dim(data_pca)[2], "05_pca cluster", method, batch, B_name, clusters$WCSS_per_cluster, "1",k)
    write.table(temp_table2, file = here("main/case_studies/output/Output_wcss.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
  
  if (method == "hdf5"){
    real_data_hdf5 <- HDF5Array(file = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.h5")), name = "obs")
    set.seed(1234)
    clusters <- mbkmeans::mini_batch(real_data_hdf5, clusters = k, 
                                     batch_size = as.integer(dim(real_data_hdf5)[1]*batch), num_init = 10, 
                                     max_iters = 100, calc_wcss = TRUE)
    temp_table2 <- data.frame(data_name, dim(real_data_hdf5)[1], dim(real_data_hdf5)[2], "05_pca cluster", method, batch, B_name, clusters$WCSS_per_cluster, "1",k)
    write.table(temp_table2, file = here("main/case_studies/output/Output_wcss.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
  
  if (method == "kmeans"){
    data_pca <- readRDS(here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca2.rds")))
    set.seed(1234)
    clusters <- stats::kmeans(data_pca, centers=k, iter.max = 100, nstart = 1)
    
    temp_table2 <- data.frame(data_name, dim(data_pca)[1], dim(data_pca)[2], "05_pca cluster", method, batch, B_name, clusters$withinss, "1",k)
    write.table(temp_table2, file = here("main/case_studies/output/Output_wcss.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
}