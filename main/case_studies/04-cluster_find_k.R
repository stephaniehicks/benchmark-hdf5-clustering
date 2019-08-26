data_name <- commandArgs(trailingOnly=T)[2]
B_name <- commandArgs(trailingOnly=T)[3]
batch <- 0.01

suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(mbkmeans))

now <- format(Sys.time(), "%b%d%H%M%S")
out_name <- paste0(data_name,"_04_", now, ".out")

invisible(gc())
Rprof(filename = here("main/case_studies/output/Memory_output", out_name), append = FALSE, memory.profiling = TRUE)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca")), prefix="")
k_list <- c(5:30)
set.seed(1234)
time <- system.time(wcss <- lapply(k_list, function(k) {
                 mbkmeans(sce, reduceMethod = "PCA", clusters = k,
                 batch_size = as.integer(dim(counts(sce))[2]*batch), num_init=10, max_iters=100,
                 calc_wcss = TRUE)$WCSS_per_cluster
}))
Rprof(NULL)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "04_find optimal k", "", B_name, time[1], time[2],time[3], "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", out_name), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "04_find optimal k", "", B_name, max_mem, "1")
write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")

wcss_list <- c()
for (i in seq_along(k_list)){
  wcss_list <- c(wcss_list, sum(wcss[[i]]))
}
print(wcss_list)

pdf(paste0(data_name, "_", "plots.pdf"))
plot(seq_along(k_list), wcss_list, xlab="Number of centers", ylab="WCSS", xlim = c(5,30))
dev.off()

