library(HDF5Array)
library(here)
library(mbkmeans)

hca_5000 <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full/hca_bonemarrow/hca_bonemarrow_5000x3000"), prefix="")
hca_50000 <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full/hca_bonemarrow/hca_bonemarrow_50000x3000"), prefix="")
hca_1e05 <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full/hca_bonemarrow/hca_bonemarrow_1e+05x3000"), prefix="")
hca_3e05 <- loadHDF5SummarizedExperiment(dir = here("main/case_studies/data/full/hca_bonemarrow/hca_bonemarrow_3e+05x3000"), prefix="")

time_list <- c()

i <- 1
repeat{
  print(paste0("5000_",i))
  time.start <- proc.time()
  invisible(mbkmeans(counts(hca_5000), clusters=15, batch_size = as.integer(dim(counts(hca_5000))[2]*.01)))
  time.end <- proc.time()
  time <- time.end - time.start
  time_list <- c(time_list, time[3])
  rm(time)
  rm(time.start)
  rm(time.end)
  invisible(gc())
  i <- i + 1
  if (i == 4){
    break
  }
}

i <- 1
repeat{
  print(paste0("50000_",i))
  time.start <- proc.time()
  invisible(mbkmeans(counts(hca_50000), clusters=15, batch_size = as.integer(dim(counts(hca_50000))[2]*.01)))
  time.end <- proc.time()
  time <- time.end - time.start
  time_list <- c(time_list, time[3])
  rm(time)
  rm(time.start)
  rm(time.end)
  invisible(gc())
  i <- i + 1
  if (i == 4){
    break
  }
}

i <- 1
repeat{
  print(paste0("100000_",i))
  time.start <- proc.time()
  invisible(mbkmeans(counts(hca_1e05), clusters=15, batch_size = as.integer(dim(counts(hca_1e05))[2]*.01)))
  time.end <- proc.time()
  time <- time.end - time.start
  time_list <- c(time_list, time[3])
  rm(time)
  rm(time.start)
  rm(time.end)
  invisible(gc())
  i <- i + 1
  if (i == 4){
    break
  }
}

i <- 1
repeat{
  print(paste0("300000_",i))
  time.start <- proc.time()
  invisible(mbkmeans(counts(hca_3e05), clusters=15, batch_size = as.integer(dim(counts(hca_3e05))[2]*.01)))
  time.end <- proc.time()
  time <- time.end - time.start
  time_list <- c(time_list, time[3])
  rm(time)
  rm(time.start)
  rm(time.end)
  invisible(gc())
  i <- i + 1
  if (i == 4){
    break
  }
}

print(sessionInfo())