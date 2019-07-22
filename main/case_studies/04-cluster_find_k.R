data_name <- commandArgs(trailingOnly=T)[2]
mode <- commandArgs(trailingOnly=T)[3]
B_name <- commandArgs(trailingOnly=T)[4]
batch <- 0.01

library(HDF5Array)
library(here)
library(mbkmeans)

sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca")), prefix="")
k_list <- c(5:20)
set.seed(1234)
time <- system.time(wcss <- lapply(k_list, function(k) {
                 mbkmeans(sce, reduceMethod = "PCA", clusters = k,
                 batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=10, max_iters=100,
                 calc_wcss = TRUE)
}))
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "04_find optimal k", "", B_name, time[1], time[2],time[3])
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)


wcss_list <- c()
for (i in seq_along(k_list)){
  wcss_list <- c(wcss_list, sum(wcss[[i]]$WCSS_per_cluster))
}
min_k <- which.min(wcss_list)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], min_k)
write.table(temp_table, file = here("main/case_studies/output/Optimal_k.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
