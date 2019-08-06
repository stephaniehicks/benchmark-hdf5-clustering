source(here("scripts","simulate_gauss_mix.R"))

init <- as.logical(commandArgs(trailingOnly=T)[2])
mode <- commandArgs(trailingOnly=T)[3]
dir_name <- commandArgs(trailingOnly=T)[4]
file_name <- commandArgs(trailingOnly=T)[5]
method <- commandArgs(trailingOnly=T)[6]
size <- commandArgs(trailingOnly=T)[7]
nC <- as.numeric(commandArgs(trailingOnly=T)[10])
nG <- as.numeric(commandArgs(trailingOnly=T)[11])
sim_center <- commandArgs(trailingOnly=T)[16]
data_path <- commandArgs(trailingOnly=T)[16]

B_name <- commandArgs(trailingOnly=T)[8]
cores <- as.numeric(commandArgs(trailingOnly=T)[9])


batch <- as.numeric(commandArgs(trailingOnly=T)[12])
k <- as.numeric(commandArgs(trailingOnly=T)[13])
initializer <- commandArgs(trailingOnly=T)[14]
B <- commandArgs(trailingOnly=T)[15]


rhdf5::h5disableFileLocking()

if (init){
  if (mode == "mem"){
    if(!file.exists(here("output_files"))){
      dir.create(here("output_files"))
    }
    
    dir.create(here("output_files", dir_name))
    
    profile_table <- data.frame(matrix(vector(), 0, 8, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","memory"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables", mode, file_name), 
                sep = ",", col.names = TRUE)
    
    sink(file = here("output_files", dir_name, "info.txt"))
    cat("RAM Info:\n")
    print(get_ram())
    cat("CPU Info: \n")
    print(get_cpu())
    cat("Session Info:\n")
    print(sessionInfo())
    sink()
  }
  
  if (mode == "acc"){
    profile_table <- data.frame(matrix(vector(), 0, 9, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","ARI","WCSS"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables", mode, file_name), 
                sep = ",", col.names = TRUE)
  }
  
  if (mode == "time"){
    profile_table <- data.frame(matrix(vector(), 0, 10, 
                                       dimnames=list(c(), c("B", "observations", "genes",
                                                            "batch_size","k",
                                                            "initializer", "method","user_time", "system_time", "elapsed_time"))),
                                stringsAsFactors=F)
    write.table(profile_table, file = here("output_tables", mode, file_name), 
                sep = ",", col.names = TRUE)
    
    sink(file = here("output_tables", mode, paste0(dir_name, "_info.txt"))) #dir_name is same as file_name, except dir_name doesn't have ".csv"
    cat("RAM Info:\n")
    print(get_ram())
    cat("CPU Info: \n")
    print(get_cpu())
    cat("Session Info:\n")
    print(sessionInfo())
    sink()
  }
}

if (!init){
  if (mode == "mem"){
    if (size == "small"){
      sim_data <- simulate_gauss_mix(n_cells=nC, n_genes=nG, k = sim_center)
      
      if (method == "hdf5"){
        h5File <- paste0(data_path, dir_name, "/", "sim_data.h5")
        h5createFile(h5File)
        h5createDataset(file = h5File, dataset = "obs", 
                        dims = dim(as.matrix(sim_data$obs_data)), chunk = c(1,nG),
                        level = 0)
        h5write(as.matrix(sim_data$obs_data), file = h5File, name = "obs" )
      }else{
        saveRDS(sim_data$obs_data, file = here("output_files", dir_name,"sim_data.rds"))
      }
      rm(sim_data)
      invisible(gc())
    }