suppressPackageStartupMessages(library(mbkmeans))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(HDF5Array))
suppressPackageStartupMessages(library(here))

print(sessionInfo())

source(here("scripts","simulate_gauss_mix.R"))

sim_data <- simulate_gauss_mix(n_cells=1000000, n_genes=1000, k=3)
sim_data_hdf5 <- as(sim_data$obs_data, "HDF5Array")
rm(sim_data)

mbkmeans::mini_batch(sim_data_hdf5, clusters = 3, 
                     batch_size = 0.8*1000000, num_init = 10, 
                     max_iters = 100, init_fraction = 0.1,
                     initializer = "random", calc_wcss = FALSE)