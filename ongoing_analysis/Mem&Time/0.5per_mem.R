rhdf5::h5disableFileLocking()

suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(mclust))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(parallel))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(benchmarkme))
suppressPackageStartupMessages(library(here))

source(here("scripts","simulate_gauss_mix.R"))

nC <- as.numeric(commandArgs(trailingOnly=T)[2])
init_per <- as.numeric(commandArgs(trailingOnly=T)[3])
nG <- 1000
sim_center <- 3
now <- format(Sys.time(), "%b%d%H%M%OS3")


sim_data <- simulate_gauss_mix(n_cells=nC, n_genes=nG, k = sim_center)
h5File <- here("ongoing_analysis/Mem&Time/data", paste0(now, "_", nC, "_sim_data.h5"))
h5createFile(h5File)
h5createDataset(file = h5File, dataset = "obs", 
                dims = dim(as.matrix(sim_data$obs_data)), chunk = c(1,nG),
                level = 0)
h5write(as.matrix(sim_data$obs_data), file = h5File, name = "obs" )

Rprof(filename = here("ongoing_analysis/Mem&Time/data", paste0(now, "_", nC, ".out")), append = FALSE, memory.profiling = TRUE)
sim_data_hdf5 <- HDF5Array(file = here("ongoing_analysis/Mem&Time/data", paste0(now, "_", nC, "_sim_data.h5")), name = "obs")
invisible(mbkmeans::mini_batch(sim_data_hdf5, clusters = 3, 
                     batch_size = nC*0.005, num_init = 10, 
                     max_iters = 100, init_fraction = init_per,
                     initializer = "random", calc_wcss = FALSE))
Rprof(NULL)

profile <- summaryRprof(filename = here("ongoing_analysis/Mem&Time/data", paste0(now, "_", nC, ".out")), chunksize = -1L, 
                        memory = "tseries", diff = FALSE)
max_mem <- max(rowSums(profile[,1:3]))*0.00000095367432

temp_table <- data.frame(nC, nG, init_per, max_mem)
write.table(temp_table, file = here("ongoing_analysis/Mem&Time/Output.csv"), sep = ",", 
            append = TRUE, quote = FALSE, col.names = FALSE, row.names = FALSE, eol = "\n")

