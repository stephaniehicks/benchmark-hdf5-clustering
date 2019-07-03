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
                            method, size, B_name, now) {
  invisible(gc())
  if (size == "small"){
    if (method == "kmeans"){
      time.start <- proc.time()
      mydata <- readRDS(file = here("output_files", paste0(now,"_sim_data.rds")))
      invisible(stats::kmeans(mydata, centers=k_centers, iter.max = max_iters, nstart = num_init))
      time.end <- proc.time()
      
      time <- time.end - time.start
      rm(mydata)
      invisible(gc())
    }
    
    if (method == "mbkmeans"){
      time.start <- proc.time()
      mydata <- readRDS(file = here("output_files", paste0(now,"_sim_data.rds")))
      invisible(mbkmeans::mini_batch(mydata, clusters = k_centers, 
                           batch_size = batch_size, num_init = num_init, 
                           max_iters = max_iters, init_fraction = init_fraction,
                           initializer = initializer, calc_wcss = FALSE))
      time.end <- proc.time()
      
      time <- time.end - time.start
      rm(mydata)
      invisible(gc())
    }
    
    if (method == "hdf5"){
      time.start <- proc.time()
      sim_data_hdf5 <- HDF5Array(file = here("output_files", paste0(now, "_sim_data.h5")), name = "obs")
      mbkmeans::mini_batch(sim_data_hdf5, clusters = k_centers, 
                           batch_size = batch_size, num_init = num_init, 
                           max_iters = max_iters, init_fraction = init_fraction,
                           initializer = initializer, calc_wcss = FALSE)
      time.end <- proc.time()
      
      time <- time.end - time.start
      rm(sim_data_hdf5)
      invisible(gc())
    }
  }
  
  if (size == "large"){
    if (method == "kmeans"){
      time.start <- proc.time()
      mydata <- readRDS(file = paste0("/fastscratch/myscratch/rliu/","obs_data_",as.character(n_cells),"_", B_name, ".rds"))
      invisible(stats::kmeans(mydata, centers=k_centers, iter.max = max_iters, nstart = num_init))
      time.end <- proc.time()
      
      time <- time.end - time.start
      rm(mydata)
      invisible(gc())
    }
    
    if (method == "mbkmeans"){
      time.start <- proc.time()
      mydata <- readRDS(file = paste0("/fastscratch/myscratch/rliu/","obs_data_",as.character(n_cells),"_", B_name, ".rds"))
      invisible(mbkmeans::mini_batch(mydata, clusters = k_centers, 
                                     batch_size = batch_size, num_init = num_init, 
                                     max_iters = max_iters, init_fraction = init_fraction,
                                     initializer = initializer, calc_wcss = FALSE))
      time.end <- proc.time()
      
      time <- time.end - time.start
      rm(mydata)
      invisible(gc())
    }
    
    if (method == "hdf5"){
      time.start <- proc.time()
      sim_data_hdf5 <- HDF5Array(file = paste0("/fastscratch/myscratch/rliu/","obs_data_",as.character(n_cells),"_", B_name, ".h5"),
                                  name = "obs")
      mbkmeans::mini_batch(sim_data_hdf5, clusters = k_centers, 
                           batch_size = batch_size, num_init = num_init, 
                           max_iters = max_iters, init_fraction = init_fraction,
                           initializer = initializer, calc_wcss = FALSE)
      time.end <- proc.time()
      
      time <- time.end - time.start
      rm(sim_data_hdf5)
      invisible(gc())
    }
  }
  return(time)
}