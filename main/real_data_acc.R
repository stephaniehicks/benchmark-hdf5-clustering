suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(mclust))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))
rhdf5::h5disableFileLocking()

init <- as.logical(commandArgs(trailingOnly=T)[2])
mode <- commandArgs(trailingOnly=T)[3]
file_name <- commandArgs(trailingOnly=T)[4]
method <- commandArgs(trailingOnly=T)[5]
cores <- as.numeric(commandArgs(trailingOnly=T)[6])
batch <- as.numeric(commandArgs(trailingOnly=T)[7])
k <- as.numeric(commandArgs(trailingOnly=T)[8]) 
B <- commandArgs(trailingOnly=T)[9]


if(init){
  profile_table <- data.frame(matrix(vector(), 0, 11, 
                                     dimnames=list(c(), c("B", "observations", "genes",
                                                          "abs_batch","k",
                                                          "method","WCSS", "iterations", "fault"))),
                              stringsAsFactors=F)
  write.table(profile_table, file = here("output_tables/abs_batch", mode, file_name), 
              sep = ",", col.names = TRUE)
}
  
  
calculate_acc <- function(i, sim_object, method){
  if (method == "kmeans"){
    wcss <- sum(sim_object[[i]]$cluster_wcss)
    iters <- sim_object[[i]]$iteration
    ifault <- sim_object[[i]]$ifault
  }else{
    wcss <- sum(sim_object[[i]]$cluster_wcss)
    iters <- sim_object[[i]]$iters[best_iter]
    ifault <- "NA"
  }
  output_list <- list(wcss=wcss, iters = iters, fault = ifault)
  return(output_list)
}

bench_hdf5_acc <- function(i, k, batch, method){
  if (method == "hdf5"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData/TENxBrainData_10k/TENxBrainData_10k_preprocessed"), prefix="")
    cluster_output <- mbkmeans(counts(sce), clusters=k, batch_size = batch, num_init=1, max_iters=100, calc_wcss = TRUE)
    
    output <- list(cluster_output = cluster_output$Clusters, 
                   cluster_wcss = cluster_output$WCSS_per_cluster)
  }
  
  if (method == "mbkmeans"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData/TENxBrainData_10k/TENxBrainData_10k_preprocessed"), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    
    cluster_output <- mbkmeans:: mini_batch(sce_km, cluster = k, batch_size = batch,
                                            num_init=1, max_iters=100, calc_wcss = TRUE)
    
    output <- list(cluster_output = cluster_output$Clusters, 
                   cluster_wcss = cluster_output$WCSS_per_cluster)
  }
  
  if (method == "kmeans"){
    sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/subset/TENxBrainData/TENxBrainData_10k/TENxBrainData_10k_preprocessed"), prefix="")
    sce_km <- realize(DelayedArray::t(counts(sce)))
    
    cluster_output <- stats::kmeans(sce_km, centers=k, iter.max = 100, nstart = 1) #iter.max and nstart set to the default values of mbkmeans()
    output <- list(cluster_output = cluster_output$cluster, 
                   cluster_wcss = cluster_output$withinss)
  }
  return(output)
}


cluster_output <- mclapply(seq_len(B), bench_hdf5_acc, k = k, batch = batch, method = method,
                           mc.cores=cores)
cluster_acc <- mclapply(seq_len(B), calculate_acc, cluster_output, method = method, mcr.cores=cores)

for (i in seq_len(B)){
  temp_table <- data.frame(i, 10000, 5000, batch, k,
                           method, cluster_acc[[i]]$wcss, cluster_acc[[i]]$iters, cluster_acc[[i]]$fault)
  write.table(temp_table, file = here("output_tables/abs_batch", mode, file_name), sep = ",", 
              append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE)
}
