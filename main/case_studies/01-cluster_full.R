
# Notes: normalization is a crucial step in the preprocessing of the results. 
# Here, we use the `scran` package to compute size factors that we will 
# use to compute the normalized log-expression values.

# It has been shown that the scran method works best if the size factors
# are computed within roughly homogeneous cell populations; hence, it is 
# beneficial to run a quick clustering on the raw data to compute better
# size factors. This ensures that we do not pool cells that are very different. 
# Note taat this is not the final clustering to identify cell sub-populations.
args <- commandArgs(trailingOnly = TRUE)
data_name <- args[2]
mode <- args[3]
B_name <- args[4]
method <- args[5] # Here method mbkmeans means mbkmeans with hdf5
batch <- as.numeric(args[6])
run_id <- args[7]

if (data_name == "TENxBrainData"){
  k <- 30
}else{
  k <- 15
}

suppressPackageStartupMessages({
  library(here)
  library(HDF5Array)
  library(mbkmeans)
  library(ClusterR)
  })

invisible(gc())

if (mode == "time"){
  if (method == "hdf5"){
    time.start <- proc.time()
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    invisible(mbkmeans(counts(sce), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100))
    time.end <- proc.time()
    time <- time.end - time.start
  }
  
  if (method == "kmeans"){
    time.start <- proc.time()
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    invisible(stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1)) #iter.max and nstart set to the default values of mbkmeans()
    time.end <- proc.time()
    time <- time.end - time.start
  }
  
  if (method == "ClusterR") {
    time.start <- proc.time()
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    sce_km <- as.array(DelayedArray::t(counts(sce)))
    km_mb <- ClusterR::MiniBatchKmeans(data=sce_km, clusters=k, batch_size=as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100)
    invisible(ClusterR::predict_MBatchKMeans(sce_km, km_mb$centroids))
    time.end <- proc.time()
    time <- time.end - time.start
  }
  
  if (method == "mbkmeans"){
    time.start <- proc.time()
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    sce_km <- realize(counts(sce))
    invisible(mbkmeans(sce_km, clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100))
    time.end <- proc.time()
    time <- time.end - time.start
  }
  
  temp_table <- data.frame(dataset = data_name,
                           run = run_id, 
                           ncells = ncol(sce),
                           ngenes = nrow(sce),
                           step = "01_full_cluster",
                           method = method, 
                           batch_prop = batch,
                           B = B_name, 
                           user_time = time[1],
                           system_time = time[2],
                           elapsed_time = time[3])
  
  write.table(temp_table, file = here(paste0("main/case_studies/output/Output_time_",
                                           data_name, "_", run_id, ".csv")), sep=",",
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
}

if (mode == "mem"){
  now <- format(Sys.time(), "%b%d%H%M%OS3")
  out_name <- paste0(data_name, "_", run_id, "_step1_", now, "_", batch,".out")
  
  if (method == "hdf5"){
    if(!file.exists(here("main/case_studies/output/Memory_output"))) {
      dir.create(here("main/case_studies/output/Memory_output"), recursive = TRUE)
    }
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    invisible(mbkmeans(counts(sce), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100))
    Rprof(NULL)
  }
  
  if (method == "kmeans"){
    if(!file.exists(here("main/case_studies/output/Memory_output"))) {
      dir.create(here("main/case_studies/output/Memory_output"), recursive = TRUE)
    }
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    invisible(stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1)) #iter.max and nstart set to the default values of mbkmeans()
    Rprof(NULL)
  }
  
  if (method == "ClusterR") {
    if(!file.exists(here("main/case_studies/output/Memory_output"))) {
      dir.create(here("main/case_studies/output/Memory_output"), recursive = TRUE)
    }
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    sce_km <- as.array(DelayedArray::t(counts(sce)))
    km_mb <- ClusterR::MiniBatchKmeans(data=sce_km, clusters=k, batch_size=as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100)
    invisible(ClusterR::predict_MBatchKMeans(sce_km, km_mb$centroids))
    Rprof(NULL)
  }
  
  if (method == "mbkmeans"){
    if(!file.exists(here("main/case_studies/output/Memory_output"))) {
      dir.create(here("main/case_studies/output/Memory_output"), recursive = TRUE)
    }
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
    sce_km <- realize(counts(sce))
    invisible(mbkmeans(sce_km, clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100))
    Rprof(NULL)
  }
  
  profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), chunksize = -1L, 
                          memory = "tseries", diff = FALSE)
  max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
  
  temp_table <- data.frame(dataset = data_name,
                            run = run_id, 
                            ncells = ncol(sce),
                            ngenes = nrow(sce),
                            step = "01_full_cluster",
                            method = method, 
                            batch_prop = batch,
                            B = B_name, 
                            max_mem = max_mem)
  write.table(temp_table, file = here(paste0("main/case_studies/output/Output_memory_",
                                           data_name, "_", run_id, ".csv")), sep=",",
              append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
}

if (mode == "acc"){
  if (method == "hdf5"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    set.seed(1234)
    clusters <- mbkmeans(counts(sce), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100, calc_wcss = TRUE)
    
    wcss <- sum(clusters$WCSS_per_cluster)
    
    if (B_name == "1" & batch == 0.01){
      saveRDS(clusters, file = here("main/case_studies/data/full", data_name, paste0(data_name, "_", run_id, "_cluster_full.rds")))
    }
  }
  
  if (method == "kmeans"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    set.seed(1234)
    clusters <- stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1) #iter.max and nstart set to the default values of mbkmeans()
    
    wcss <- sum(clusters$withinss)
  }

  temp_table2 <- data.frame(dataset = data_name,
                            run = run_id, 
                            ncells = ncol(sce),
                            ngenes = nrow(sce),
                            step = "01_full_cluster",
                            method = method, 
                            batch_prop = batch,
                            B = B_name, 
                            WCSS = wcss)
  
  write.table(temp_table2, 
            file = here(paste0("main/case_studies/output/Output_wcss_",
                               data_name, "_", run_id, ".csv")), sep=",",
            append = TRUE, quote = FALSE, col.names = FALSE, 
            row.names = FALSE, eol = "\n")
}



