options(warn=-1)

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))

size <- commandArgs(trailingOnly=T)[2]
chunk <- commandArgs(trailingOnly=T)[3]
batch <- as.numeric(commandArgs(trailingOnly=T)[4])
mode <- commandArgs(trailingOnly=T)[5]
k <- 15

if (mode == "time"){
  time.start <- proc.time()
  tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                            paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
  invisible(mbkmeans(counts(tenx), clusters=k, batch_size = as.integer(dim(counts(tenx))[2]*batch), 
                    num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=TRUE))
  time.end <- proc.time()
  time <- time.end - time.start

  print(time)
  temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch, 
                          abs_batch_size =  as.integer(dim(counts(tenx))[2]*batch), 
                          time = time[3], geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                          dimension_2 = seed(counts(tenx))@chunkdim[2])
  write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
              sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
}

if (mode == "mem"){
  now <- format(Sys.time(), "%b%d%H%M%OS3")
  out_name <- paste0("TENxBrain_", size, "_", chunk, "_", now, "_", batch,".out")
  
  if(!file.exists(here("main/case_studies/output/Memory_output/chunk_test"))) {
    dir.create(here("main/case_studies/output/Memory_output/chunk_test"), recursive = TRUE)}
  
  Rprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), append = FALSE, memory.profiling = TRUE)
  tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                            paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
  invisible(mbkmeans(counts(tenx), clusters=k, batch_size = as.integer(dim(counts(tenx))[2]*batch), 
                     num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=TRUE))
  Rprof(NULL)
  
  profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), chunksize = -1L, 
                          memory = "tseries", diff = FALSE)
  max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
  
  print(max_mem)
  temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch, 
                           abs_batch_size =  as.integer(dim(counts(tenx))[2]*batch), 
                           time = max_mem, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                           dimension_2 = seed(counts(tenx))@chunkdim[2])
  write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
              sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
}

