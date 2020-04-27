invisible(library(HDF5Array))
invisible(library(rhdf5))
source(here::here("scripts","simulate_gauss_mix_k.R"))

nC <- as.numeric(commandArgs(trailingOnly=T)[2])
nG <- as.numeric(commandArgs(trailingOnly=T)[3])
sim_center <- as.numeric(commandArgs(trailingOnly=T)[4])
data_path <- commandArgs(trailingOnly=T)[5]
data_number <- as.numeric(commandArgs(trailingOnly=T)[6])

set.seed(1234)
x_mus <- runif(sim_center, min = -10, max = 10)
set.seed(1234)
x_sds <- sample(1:10, sim_center, replace = TRUE)/10
set.seed(12)
y_mus <- runif(sim_center, min = -10, max = 10)
set.seed(123)
y_sds <- sample(1:10, sim_center, replace = TRUE)/10
prop1 <- rep(1/sim_center, sim_center)

for (i in 1:data_number){
  sim_data <- simulate_gauss_mix_k(n_cells = nC, n_genes = nG, k = sim_center, 
                                   x_mus = x_mus, x_sds = x_sds, y_mus = y_mus, y_sds = y_sds, prop1=prop1)
  
  saveRDS(sim_data$obs_data, file = paste0(data_path, "/", "obs_data_", nC, "_", sim_center, "_", i, ".rds"))
  
  rhdf5::h5disableFileLocking()
  h5File <- paste0(data_path, "/", "obs_data_", nC, "_", sim_center, "_", i, ".h5")
  h5createFile(h5File)
  h5createDataset(file = h5File, dataset = "obs", 
                  dims = dim(sim_data$obs_data), chunk = c(1,nG),
                  level = 0)
  h5write(sim_data$obs_data, file = h5File, name = "obs" )
}


