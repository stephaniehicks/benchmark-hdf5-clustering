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
calc_lab <- as.logical(commandArgs(trailingOnly=T)[6])
cent_file_name <- commandArgs(trailingOnly=T)[7]
choice <- commandArgs(trailingOnly=T)[8]
k <- 15

if (mode == "time"){
  if (choice == "full"){
    time.start1 <- proc.time()
    tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                              paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
    invisible(mbkmeans(counts(tenx), clusters=k, batch_size = as.integer(dim(counts(tenx))[2]*batch), 
                       num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=TRUE))
    time.end1 <- proc.time()
    time1 <- time.end1 - time.start1
    print(time1)
    
    temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch, 
                             abs_batch_size =  as.integer(dim(counts(tenx))[2]*batch), 
                             time1 = time1[3], time2 = NA, time3 = NA, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                             dimension_2 = seed(counts(tenx))@chunkdim[2], choice = "full")
    write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
                sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    
  }else{
    time.start1 <- proc.time()
    tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                              paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
    time.end1 <- proc.time()
    time1 <- time.end1 - time.start1
    
    time.start2 <- proc.time()
    output<- mbkmeans(counts(tenx), clusters=k, batch_size = as.integer(dim(counts(tenx))[2]*batch), 
                      num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=FALSE)
    time.end2 <- proc.time()
    time2 <- time.end2 - time.start2
  
    time.start3 <- proc.time()
    mbkmeans::predict_mini_batch(counts(tenx), output$centroids)
    time.end3 <- proc.time()
    time3 <- time.end3 - time.start3
    
    print(time1)
    print(time2)
    print(time3)
    temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch, 
                            abs_batch_size =  as.integer(dim(counts(tenx))[2]*batch), 
                            time1 = time1[3], time2 = time2[3], time3 = time3[3], geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                            dimension_2 = seed(counts(tenx))@chunkdim[2], choice = "two steps")
    write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
                sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
  }
}

if (mode == "mem"){
  now <- format(Sys.time(), "%b%d%H%M%OS3")
  out_name <- paste0("TENxBrain_", size, "_", chunk, "_", now, "_", batch,".out")
  
  if(!file.exists(here("main/case_studies/output/Memory_output/chunk_test"))) {
    dir.create(here("main/case_studies/output/Memory_output/chunk_test"), recursive = TRUE)}
  
  if (choice == "full"){
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
                             dimension_2 = seed(counts(tenx))@chunkdim[2], choice = "full")
    write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
                sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
  }else{
    if (!calc_lab){
      Rprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), append = FALSE, memory.profiling = TRUE)
      tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                                paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
      output <- mbkmeans(counts(tenx), clusters=k, batch_size = as.integer(dim(counts(tenx))[2]*batch), 
                         num_init=1, max_iters=100, calc_wcss = FALSE, compute_labels=FALSE)
      Rprof(NULL)
      
      saveRDS(output$centroids, file = cent_file_name)
      profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), chunksize = -1L, 
                              memory = "tseries", diff = FALSE)
      max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
      
      print(max_mem)
      temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch, 
                               abs_batch_size =  as.integer(dim(counts(tenx))[2]*batch), 
                               mem = max_mem, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                               dimension_2 = seed(counts(tenx))@chunkdim[2], calc_lab = "FALSE")
      write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
                  sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
   
    if (calc_lab){
      centroids <- readRDS(file = cent_file_name)
      Rprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), append = FALSE, memory.profiling = TRUE)
      tenx <- loadHDF5SummarizedExperiment(here(paste0("main/case_studies/data/subset/TENxBrainData/TENxBrainData_", size), 
                                                paste0("TENxBrainData_", size, "_preprocessed_", chunk)))
      mbkmeans::predict_mini_batch(counts(tenx),centroids)
      Rprof(NULL)
      
      profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output/chunk_test",out_name), chunksize = -1L, 
                              memory = "tseries", diff = FALSE)
      max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
      
      print(max_mem)
      temp_table <- data.frame(observations = dim(counts(tenx))[2], genes = dim(counts(tenx))[1], batch_size = batch, 
                               abs_batch_size =  as.integer(dim(counts(tenx))[2]*batch), 
                               mem = max_mem, geometry = chunk, dimension_1 = seed(counts(tenx))@chunkdim[1], 
                               dimension_2 = seed(counts(tenx))@chunkdim[2], calc_lab = "TRUE")
      write.table(temp_table, file = here("ongoing_analysis/ChunkTest/TENxBrainData/Output", paste0(mode, "_", chunk,".csv")), 
                  sep = ",", append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
    }
  }
}

