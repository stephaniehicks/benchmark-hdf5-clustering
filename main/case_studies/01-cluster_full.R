
# Notes: normalization is a crucial step in the preprocessing of the results. 
# Here, we use the `scran` package to compute size factors that we will 
# use to compute the normalized log-expression values.

# It has been shown that the scran method works best if the size factors
# are computed within roughly homogeneous cell populations; hence, it is 
# beneficial to run a quick clustering on the raw data to compute better
# size factors. This ensures that we do not pool cells that are very different. 
# Note taat this is not the final clustering to identify cell sub-populations.
data_name <- commandArgs(trailingOnly=T)[2]
mode <- commandArgs(trailingOnly=T)[3]
B_name <- commandArgs(trailingOnly=T)[4]
method <- commandArgs(trailingOnly=T)[5] #Here method mbkmeans means mbkmeans with hdf5
batch <- as.numeric(commandArgs(trailingOnly=T)[6])

if (data_name == "TENxBrainData"){
  k <- 30
}else{
  k <- 15
}

suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(mbkmeans))

if (mode == "time"){
  if (method == "hdf5"){
    invisible(gc())
    time.start <- proc.time()
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    invisible(mbkmeans(counts(sce), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100))
    time.end <- proc.time()
    time <- time.end - time.start
  }
  
  if (method == "kmeans"){
    invisible(gc())
    time.start <- proc.time()
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    invisible(stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1)) #iter.max and nstart set to the default values of mbkmeans()
    time.end <- proc.time()
    time <- time.end - time.start
  }
  
  temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "01_full cluster", method, batch, B_name, time[1], time[2],time[3], "1")
  write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
              append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  
}

if (mode == "mem"){
  invisible(gc())
  now <- format(Sys.time(), "%b%d%H%M%OS3")
  out_name <- paste0(data_name, "_step1_", now, "_", batch,".out")
  if (method == "hdf5"){
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    invisible(mbkmeans(counts(sce), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100))
    Rprof(NULL)
  }
  
  if (method == "kmeans"){
    Rprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), append = FALSE, memory.profiling = TRUE)
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    invisible(stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1)) #iter.max and nstart set to the default values of mbkmeans()
    Rprof(NULL)
  }
  
  profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output",paste0(method, out_name)), chunksize = -1L, 
                          memory = "tseries", diff = FALSE)
  max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
  
  temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "01_full cluster", method, batch, B_name, max_mem, "1")
  write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
              append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
}

if (mode == "acc"){
  if (method == "hdf5"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    set.seed(1234)
    clusters <- mbkmeans(counts(sce), clusters=k, batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=1, max_iters=100, calc_wcss = TRUE)
    
    temp_table2 <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "01_full cluster", method, batch, B_name, sum(clusters$WCSS_per_cluster))
    write.table(temp_table2, file = here("main/case_studies/output/Output_wcss.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
    
    if (B_name == "1" & batch == 0.01){
      saveRDS(clusters, file = here("main/case_studies/data/full", data_name, paste0(data_name, "_cluster_full.rds")))
    }
  }
  
  if (method == "kmeans"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_preprocessed")), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    set.seed(1234)
    clusters <- stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1) #iter.max and nstart set to the default values of mbkmeans()
    
    temp_table2 <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "01_full cluster", method, batch, B_name, sum(clusters$withinss))
    write.table(temp_table2, file = here("main/case_studies/output/Output_wcss.csv"), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
  }
}



