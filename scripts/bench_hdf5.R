#' @title bench_hdf5
#' @param i monte carlo simulation iteration
#' @param method  three values: "kmenas", "mbkmeans", "hdf5"; default method is "kmeans"
#' @param mode three values: "acc", "mem", "time"; default is "acc"

bench_hdf5 <- function(i, n_cells, 
                       n_genes, 
                       k_centers, 
                       batch_size = batch_size, 
                       num_init = num_init, 
                       max_iters = max_iters, 
                       init_fraction = init_fraction, 
                       initializer = initializer, 
                       method, mode) {
  # simulated data 
  sim_data <- simulate_gauss_mix(n_cells=n_cells, 
                                 n_genes=n_genes,
                                 k = 3)
  
  # save the hdf5 matrix into a file on-disk
  if (method == "hdf5"){
    sim_data_hdf5 <- writeHDF5Array(as.matrix(sim_data$obs_data))
  }
  
  # If benchmark memory: save the simulated data
  if(mode == "mem"){
    if (method == "hdf5"){
      rm(sim_data)
      invisible(gc())
    }else{
      saveRDS(sim_data, file = "sim_data.rds")
      rm(sim_data)
      invisible(gc())
    }
  }
  
  # Benchmark accuracy
  if (mode == "acc"){
    if(method == "kmeans"){
      cluster_output <- stats::kmeans(sim_data$obs_data, centers=k_centers, 
                                      iter.max = max_iters, nstart = num_init)
      output <- list(sim_data = sim_data, cluster_output = cluster_output)
      
      ari <- calculate_ari(output)
      wcss <- calculate_wcss(output)
      outputlist <- list(ari = ari, wcss = wcss)
    }
    
    if(method == "mbkmeans"){
      cluster_output <- mbkmeans::mini_batch(
        sim_data$obs_data, clusters = k_centers, 
        batch_size = batch_size, num_init = num_init, 
        max_iters = max_iters, init_fraction = init_fraction,
        initializer = initializer, calc_wcss = TRUE)
      output <- list(sim_data = sim_data, cluster_output = cluster_output)
      
      ari <- calculate_ari(output)
      wcss <- calculate_wcss(output)
      outputlist <- list(ari, wcss)
      
    }
    
    if(method == "hdf5"){
      cluster_output <- mbkmeans::mini_batch(
        sim_data_hdf5, clusters = k_centers, 
        batch_size = batch_size, num_init = num_init, 
        max_iters = max_iters, init_fraction = init_fraction,
        initializer = initializer, calc_wcss = TRUE)
      
      output <- list(sim_data = sim_data, cluster_output = cluster_output)
      
      ari <- calculate_ari(output)
      wcss <- calculate_wcss(output)
      outputlist <- list(ari, wcss) 
    }
  }
  
  # Benchmark Time
  if (mode == "time"){
    if (method == "kmeans"){
      cluster_time <- system.time(stats::kmeans(sim_data$obs_data, centers=k_centers,
                                                iter.max = max_iters, nstart = num_init))[3]
      outputlist <- cluster_time
    }
    
    if(method == "mbkmeans"){
      cluster_time <- system.time(mbkmeans::mini_batch(
        sim_data$obs_data, clusters = k_centers, 
        batch_size = batch_size, num_init = num_init, 
        max_iters = max_iters, init_fraction = init_fraction,
        initializer = initializer, calc_wcss = FALSE))[3]
      outputlist <- cluster_time
    }
    
    if(method == "hdf5"){
      cluster_time <- system.time(mbkmeans::mini_batch(
        sim_data_hdf5, clusters = k_centers, 
        batch_size = batch_size, num_init = num_init, 
        max_iters = max_iters, init_fraction = init_fraction,
        initializer = initializer, calc_wcss = FALSE))[3]
      outputlist <- cluster_time
    }
    
  }
  
  # Benchmark memory
  if (mode == "mem"){
    if(method == "kmeans"){
      now <- format(Sys.time(), "%b%d%H%M%S")
      out_name <- paste0("kmeans", now, ".out")
      invisible(gc())
      
      Rprof(out_name, append = FALSE, memory.profiling = TRUE)
      mydata <- readRDS(file = "sim_data.rds")
      stats::kmeans(mydata$obs_data, centers=k_centers, iter.max = max_iters, nstart = num_init)
      Rprof(NULL)
      
      kmeans_profile <- summaryRprof(out_name, chunksize = 100000, memory = "tseries", diff = FALSE)
      outputlist <- list(max_mem = max(rowSums(kmeans_profile[,1:3]))*0.00000095367432)
      
      rm(kmeans_profile)
    }
    
    if(method == "mbkmeans"){
      now <- format(Sys.time(), "%b%d%H%M%S")
      out_name <- paste0("mbkmeans", now, ".out")
      invisible(gc())
      
      Rprof(out_name, append = FALSE, memory.profiling = TRUE)
      mydata <- readRDS(file = "sim_data.rds")
      mbkmeans::mini_batch(mydata$obs_data, clusters = k_centers, 
                           batch_size = batch_size, num_init = num_init, 
                           max_iters = max_iters, init_fraction = init_fraction,
                           initializer = initializer, calc_wcss = FALSE)
      
      Rprof(NULL)
      
      mbkmeans_profile <- summaryRprof(out_name,chunksize = 100000, memory = "tseries", diff = FALSE)
      outputlist <- list(max_mem = max(rowSums(mbkmeans_profile[,1:3]))*0.00000095367432)
      rm(mbkmeans_profile)
    }
    
    if(method == "hdf5"){
      now <- format(Sys.time(), "%b%d%H%M%S")
      out_name <- paste0("hdf5", now, ".out")
      invisible(gc())
      
      Rprof(out_name, append = FALSE, memory.profiling = TRUE)
      mbkmeans::mini_batch(sim_data_hdf5, clusters = k_centers, 
                           batch_size = batch_size, num_init = num_init, 
                           max_iters = max_iters, init_fraction = init_fraction,
                           initializer = initializer, calc_wcss = FALSE)
      Rprof(NULL)
      
      hdf5_profile <- summaryRprof(out_name, chunksize = 100000, memory = "tseries", diff = FALSE)
      outputlist <- list(max_mem = max(rowSums(hdf5_profile[,1:3]))*0.00000095367432)
      rm(hdf5_profile)
    }
  }    
  outputlist
}