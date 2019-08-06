#' @title bench_hdf5_time
#' @param i monte carlo simulation iteration; keep this for mclapply
#' 
bench_hdf5_time <- function(i,n_cells, 
                            n_genes,
                            k_centers, 
                            batch_size = batch_size, 
                            num_init = num_init, 
                            max_iters = max_iters, 
                            init_fraction = init_fraction, 
                            initializer = initializer, 
                            method, size, index) {
  invisible(gc())
  
  if (method == "kmeans"){
    time.start <- proc.time()
    mydata <- readRDS(file = paste0(data_path, "/", "obs_data_", n_cells, "_", index, ".rds"))
    invisible(stats::kmeans(mydata, centers=k_centers, iter.max = max_iters, nstart = num_init))
    time.end <- proc.time()
    time <- time.end - time.start
  }
    
  if (method == "mbkmeans"){
    time.start <- proc.time()
    mydata <- readRDS(file = paste0(data_path, "/", "obs_data_", n_cells, "_", index, ".rds"))
    invisible(mbkmeans::mini_batch(mydata, clusters = k_centers, 
                         batch_size = batch_size, num_init = num_init, 
                         max_iters = max_iters, init_fraction = init_fraction,
                         initializer = initializer, calc_wcss = FALSE))
    time.end <- proc.time()
    time <- time.end - time.start
  }
    
  if (method == "hdf5"){
    time.start <- proc.time()
    sim_data_hdf5 <- HDF5Array(file = paste0(data_path, "/", "obs_data_", nC, "_", index, ".h5"), name = "obs")
    invisible(mbkmeans::mini_batch(sim_data_hdf5, clusters = k_centers, 
                         batch_size = batch_size, num_init = num_init, 
                         max_iters = max_iters, init_fraction = init_fraction,
                         initializer = initializer, calc_wcss = FALSE))
    time.end <- proc.time()
    time <- time.end - time.start
  }
 return(time)
}