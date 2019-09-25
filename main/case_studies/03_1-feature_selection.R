# Dimensionality reduction
data_name <- commandArgs(trailingOnly=T)[2]
B_name <- commandArgs(trailingOnly=T)[3]


suppressPackageStartupMessages(library(BiocSingular))
suppressPackageStartupMessages(library(BiocParallel))
suppressPackageStartupMessages(library(DelayedMatrixStats))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))

DelayedArray:::set_verbose_block_processing(TRUE)
DelayedArray:::set_verbose_block_processing(TRUE)

getAutoBlockSize()
block_size <- 50000
setAutoBlockSize(block_size)

now <- format(Sys.time(), "%b%d%H%M%S")
out_name <- paste0(data_name,"_step3_vars_", now, ".out")

invisible(gc())

## Realize into memory
Rprof(filename = here("main/case_studies/output/Memory_output", out_name), append = FALSE, memory.profiling = TRUE)
sce <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full", data_name, paste0(data_name, "_normalized")),  prefix="")
setRealizationBackend("HDF5Array")
time <- system.time(logcounts(sce) <- realize(logcounts(sce)))
Rprof(NULL)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_realize logcounts", "other", "NA", B_name, time[1], time[2],time[3], "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", out_name), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_realize logcounts", "other", "NA", B_name, max_mem, "1")
write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(profile)
rm(max_mem)
rm(temp_table)
invisible(gc())

## find most variable genes
Rprof(filename = here("main/case_studies/output/Memory_output", paste0(out_name, "_2")), append = FALSE, memory.profiling = TRUE)
time <- system.time(vars <- DelayedMatrixStats::rowVars(logcounts(sce)))
Rprof(NULL)

temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_find var", "other","NA", B_name, time[1], time[2],time[3], "1")
write.table(temp_table, file = here("main/case_studies/output/Output_time.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(temp_table)
rm(time)

profile <- summaryRprof(filename = here("main/case_studies/output/Memory_output", paste0(out_name, "_2")), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432
temp_table <- data.frame(data_name, dim(counts(sce))[2], dim(counts(sce))[1], "03_find var", "other","NA", B_name, max_mem, "1")
write.table(temp_table, file = here("main/case_studies/output/Output_memory.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")
rm(profile)
rm(max_mem)
invisible(gc())

names(vars) <- rownames(sce)
vars <- sort(vars, decreasing = TRUE)
saveRDS(vars, here("main/case_studies/data/pca", data_name, paste0(data_name, "_var.rds")))
