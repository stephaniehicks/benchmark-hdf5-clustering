suppressPackageStartupMessages({
  library(here)
  library(rhdf5)
  library(HDF5Array)
  library(mbkmeans)
  library(ClusterR)
  library(benchmarkme)
  library(parallel)
  library(mclust)
  library(dplyr)
})

rhdf5::h5disableFileLocking()

init <- as.logical(commandArgs(trailingOnly=T)[2])
mode <- commandArgs(trailingOnly=T)[3]
file_name <- commandArgs(trailingOnly=T)[4]
method <- commandArgs(trailingOnly=T)[5]
cores <- as.numeric(commandArgs(trailingOnly=T)[6])
batch <- as.numeric(commandArgs(trailingOnly=T)[7])
k <- as.numeric(commandArgs(trailingOnly=T)[8]) 
B <- as.numeric(commandArgs(trailingOnly=T)[9])
data_name <- commandArgs(trailingOnly=T)[10]
id <- commandArgs(trailingOnly=T)[11]

if (data_name == "TENxBrainData_25k"){
  nC = 25000
}else if (data_name == "TENxBrainData_10k"){
  nC = 10000
}else if (data_name == "TENxBrainData_5k"){
  nC = 5000
}

if(init){
  profile_table <- data.frame(matrix(vector(), 0, 7, 
                                     dimnames=list(c(), c("B", "observations", "genes",
                                                          "abs_batch","k",
                                                          "method","WCSS"))), stringsAsFactors=F)
  write.table(profile_table, file = here("output_tables/abs_batch", mode, "real_data", file_name), 
              sep = ",", col.names = TRUE)
}
  
if(!init){
  # helper function
  calculate_acc <- function(i, sim_object, method){
    if (method == "kmeans"){
      wcss <- sum(sim_object[[i]]$cluster_wcss)
    }else{
      wcss <- sum(sim_object[[i]]$cluster_wcss)
    }
    output_list <- list(wcss=wcss)
    return(output_list)
  }
  
  # helper function
  bench_hdf5_acc <- function(i, k, batch, method, data_name){
    if(method == "ClusterR"){
      sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
      # sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", "TENxBrainData_5k", paste0("TENxBrainData_5k", "_preprocessed_best")), prefix="")
      sce_km <- as.array(DelayedArray::t(counts(sce)))
      km_mb <- ClusterR::MiniBatchKmeans(data=sce_km, clusters=k, batch_size=batch, 
                                         init_fraction=(batch/dim(counts(sce))[2]), num_init=1, max_iters=100, 
                                         seed = sample(seq_len(1e6), 1))
      cluster_output <- ClusterR::predict_MBatchKMeans(sce_km, km_mb$centroids)
      wcss_output <- mbkmeans::compute_wcss(clusters = as.numeric(cluster_output), cent = km_mb$centroids, data = sce_km)
      
      output <- list(cluster_output = as.numeric(cluster_output), 
                     cluster_wcss = wcss_output)
    }
    
    if (method == "hdf5"){
      sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
      cluster_output <- mbkmeans(counts(sce), clusters=k, batch_size = batch, max_iters=100, calc_wcss = TRUE)
      
      output <- list(cluster_output = cluster_output$Clusters, 
                     cluster_wcss = cluster_output$WCSS_per_cluster)
    }
    
    if (method == "mbkmeans"){
      sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
      sce_km <- realize(counts(sce))
      
      cluster_output <- mbkmeans(sce_km, cluster = k, batch_size = batch, max_iters=100, calc_wcss = TRUE)
      
      output <- list(cluster_output = cluster_output$Clusters, 
                     cluster_wcss = cluster_output$WCSS_per_cluster)
    }
    
    if (method == "kmeans"){
      sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData", data_name, paste0(data_name, "_preprocessed_best")), prefix="")
      sce_km <- realize(DelayedArray::t(counts(sce)))
      
      cluster_output <- stats::kmeans(sce_km, centers=k, iter.max = 100) #iter.max and nstart set to the default values of mbkmeans()
      output <- list(cluster_output = cluster_output$cluster, 
                     cluster_wcss = cluster_output$withinss)
    }
    return(output)
  }
  
  # run profiler
  cluster_output <- mclapply(seq_len(B), bench_hdf5_acc, k = k, batch = batch, method = method, data_name = data_name,
                             mc.cores=cores)
  cluster_acc <- mclapply(seq_len(B), calculate_acc, cluster_output, method = method, mc.cores=cores)
  
  for (i in seq_len(B)){
    temp_table <- data.frame(i, nC, 1000, batch, k,
                             method, cluster_acc[[i]]$wcss)
    write.table(temp_table, file = here("output_tables/abs_batch", mode, "real_data", file_name), sep = ",", 
                append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
  }
}
