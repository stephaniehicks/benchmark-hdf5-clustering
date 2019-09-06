# Dimensionality reduction
data_name <- commandArgs(trailingOnly=T)[2]
B_name <- commandArgs(trailingOnly=T)[3]


suppressPackageStartupMessages(library(BiocSingular))
suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(DelayedMatrixStats))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))

now <- format(Sys.time(), "%b%d%H%M%S")
out_name <- paste0(data_name,"_03_", now, ".out")

invisible(gc())

## Realize into memory
Rprof(filename = here("main/case_studies/output/Memory_output", out_name), append = FALSE, memory.profiling = TRUE)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_normalized")),  prefix="")
setRealizationBackend("HDF5Array")
time <- system.time(logcounts(sce) <- realize(logcounts(sce)))
Rprof(NULL)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_realize logcounts", "other", B_name, time[1], time[2],time[3], "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", out_name), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_realize logcounts", "other", B_name, max_mem, "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(profile)
rm(max_mem)
rm(temp_table)
invisible(gc())

## find most variable genes
Rprof(filename = here("main/case_studies/output/Memory_output", paste0(out_name, "_2")), append = FALSE, memory.profiling = TRUE)
time <- system.time(vars <- DelayedMatrixStats::rowVars(logcounts(sce)))
Rprof(NULL)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_find var", "other", B_name, time[1], time[2],time[3], "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", paste0(out_name, "_2")), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_find var", "other", B_name, max_mem, "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(profile)
rm(max_mem)
invisible(gc())

#save out var temporarily for debugging purpose
#var_name <- paste0(data_name,"_03_var","_", now, ".rds")
#saveRDS(vars, file = here("main/case_studies/output", var_name))

names(vars) <- rownames(sce)
vars <- sort(vars, decreasing = TRUE)
#keep top 50% most variable genes
for_pca <- t(logcounts(sce)[names(vars)[1:as.integer(length(names(vars))*0.5)],])
#perform pca
Rprof(filename = here("main/case_studies/output/Memory_output", paste0(out_name, "_3")), append = FALSE, memory.profiling = TRUE)
time <- system.time(pca <- BiocSingular::runPCA(for_pca, rank = 30,
                                        scale = TRUE,
                                        BSPARAM = RandomParam(deferred = FALSE),
                                        BPPARAM = MulticoreParam(10)))
Rprof(NULL)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_pca", "other", B_name, time[1], time[2],time[3], "10")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", paste0(out_name, "_3")), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_pca", "other", B_name, max_mem, "10")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")

# save the pca data to a seperate h5 file
saveHDF5SummarizedExperiment(pca$x, 
                             dir = here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca")),
                             prefix="", replace=FALSE, 
                             chunkdim=c(30,1), 
                             level=NULL, verbose=FALSE)
#reducedDim(sce, "PCA") <- 
saveRDS(pca$x, file=here("main/case_studies/data/pca", data_name, paste0(data_name, "_pca.rds")))
