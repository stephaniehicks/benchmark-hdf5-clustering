#' @title bench_hdf5_mem
#' Perform memory profiling for the specificed clustering method.
#' For kmeans and regular mbkmeans, data will be read into memory. For
#' hdf5, a pointer that points to the hdf5 file on disk will be created.
#' Then the memory of performming the method is logged and summarized. 
#' The maximum memory usage will be returned.
#' @param i monte carlo simulation iteration; keep this for mclapply
#' @param dir_name the name of directory to save the .out files

bench_hdf5_mem_k <- function(i, n_cells, 
                           n_genes, 
                           k_centers, 
                           batch_size = batch_size, 
                           num_init = num_init, 
                           max_iters = max_iters, 
                           initializer = initializer, 
                           method, size, dir_name, index) {
  
  now <- format(Sys.time(), "%b%d%H%M%S")
  out_name <- paste0(method,"_",n_cells,"_",batch,"_",k_centers,"k_" , now, ".out")
  invisible(gc())
  
  if (method == "kmeans"){
    Rprof(filename = here("output_files",dir_name,out_name), append = FALSE, memory.profiling = TRUE)
    mydata <- readRDS(file = paste0(data_path, "/", "obs_data_", n_cells, "_15_", index, ".rds"))
    stats::kmeans(mydata, centers=k_centers, iter.max = max_iters, nstart = num_init)
    Rprof(NULL)
    
    profile <- summaryRprof(filename = here("output_files",dir_name,out_name), chunksize = -1L, 
                            memory = "tseries", diff = FALSE)
    max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
  }
  
  if (method == "mbkmeans"){
    Rprof(filename = here("output_files",dir_name,out_name), append = FALSE, memory.profiling = TRUE)
    mydata <- readRDS(file = paste0(data_path, "/", "obs_data_", n_cells, "_15_", index, ".rds"))
    mbkmeans::mini_batch(mydata, clusters = k_centers, 
                         batch_size = batch_size, num_init = num_init, 
                         max_iters = max_iters, init_fraction = init_fraction,
                         initializer = initializer, calc_wcss = FALSE)
    
    Rprof(NULL)
    
    profile <- summaryRprof(filename = here("output_files",dir_name,out_name),chunksize = -1L, 
                            memory = "tseries", diff = FALSE)
    max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
  }
  
  if (method == "hdf5"){
    Rprof(filename = here("output_files",dir_name,out_name), append = FALSE, memory.profiling = TRUE)
    sim_data_hdf5 <- HDF5Array(file = paste0(data_path, "/", "obs_data_", n_cells, "_15_", index, ".h5"), name = "obs")
    mbkmeans::mini_batch(sim_data_hdf5, clusters = k_centers, 
                         batch_size = batch_size, num_init = num_init, 
                         max_iters = max_iters, init_fraction = init_fraction,
                         initializer = initializer, calc_wcss = FALSE)
    Rprof(NULL)
    
    profile <- summaryRprof(filename = here("output_files",dir_name,out_name), chunksize = -1L, 
                            memory = "tseries", diff = FALSE)
    max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
  }
  return(max_mem)
}