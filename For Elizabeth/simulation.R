invisible(library(HDF5Array))
invisible(library(rhdf5))
source(here::here("scripts","simulate_gauss_mix.R"))

nC <- as.numeric(commandArgs(trailingOnly=T)[2])
nG <- as.numeric(commandArgs(trailingOnly=T)[3])
sim_center <- as.numeric(commandArgs(trailingOnly=T)[4])
data_path <- commandArgs(trailingOnly=T)[5]
index <-  as.numeric(commandArgs(trailingOnly=T)[6])

sim_data <- simulate_gauss_mix(n_cells=nC, n_genes=nG, k = sim_center)
saveRDS(sim_data$obs_data, file = paste0(data_path, "/", "obs_data_", nC, "_", index, ".rds"))
#print(dim(sim_data$obs_data))

rhdf5::h5disableFileLocking()
h5File <- paste0(data_path, "/", "obs_data_", nC, "_", index, ".h5")
h5createFile(h5File)
h5createDataset(file = h5File, dataset = "obs", 
                dims = dim(sim_data$obs_data), chunk = c(1,1000),
                level = 0)
h5write(sim_data$obs_data, file = h5File, name = "obs" )
