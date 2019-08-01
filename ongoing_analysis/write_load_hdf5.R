library(rhdf5)

sim_data<-simulate_gauss_mix(n_cells=1000000, 
                             n_genes=1000, k=3)

saveRDS(sim_data$obs_data, file = "/fastscratch/myscratch/rliu/obs_data_1e+06_1.rds")

#Save and load as HDF5 object with the follwoing code 
sim_data <- readRDS("/fastscratch/myscratch/rliu/obs_data_5e+05_3.rds")
#sim_data <- as.matrix(data$obs_data)

rhdf5::h5disableFileLocking()
h5File <- '/fastscratch/myscratch/rliu/obs_data_5e+05_3.h5'
h5createFile(h5File)
h5createDataset(file = h5File, dataset = "obs", 
                dims = dim(sim_data), chunk = c(1,1000),
                level = 0)
h5write(sim_data, file = h5File, name = "obs" )

h5.uncmp <- HDF5Array(file = h5File, 
                         name = "obs")

rm(sim_data)
rm(h5.uncmp)

#sim_hdf5 <- as(sim_data,"HDF5Matrix")


###############h5write doesn't create hdf5 object##############
#Write with "h5write" and read with "h5read" 
library(rhdf5)
B = array(seq(0.1,2.0,by=0.1),dim=c(5,2,2))

B1 <- writeHDF5Array(B)

h5write(B, "ex_hdf5file.h5","B")
E = h5read("ex_hdf5file.h5","B") #Note that E is not a HDF5 Object. "h5read" reads in all the contents of the hdf5 file (in memory)
object.size(E)
object.size(B)

#as(,"HDF5Matrix") and writeHDF5Array() will convert the data to HDF5 object.
sim_data_hdf5 <- as(data,"HDF5Matrix")
typeof(sim_data_hdf5)
object.size(sim_data_hdf5)

sim_data_hdf5_2 <- writeHDF5Array(data)
getHDF5DumpChunkDim(dim(data))
typeof(sim_data_hdf5_2)
object.size(sim_data_hdf5_2)
#the read function in HDF5Array package is "expirenmental"



