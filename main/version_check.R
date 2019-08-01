library(mbkmeans)
library(rhdf5)
library(mclust)
library(dplyr)
library(parallel)
library(HDF5Array)
library(benchmarkme)
library(here)

BiocManager::install()

if(!(packageVersion("rhdf5") == "2.29.2")){
  devtools::install_github("grimbough/rhdf5")
}

if(!(packageVersion("mclust") == "5.4.5")){
  install.packages("mclust")
}

if(!(packageVersion("BiocGenerics") == "0.31.5")){
  devtools::install_github("Bioconductor/BiocGenerics")
}

if(!(packageVersion("S4Vectors") == "0.23.17")){
  devtools::install_github("Bioconductor/S4Vectors")
}

if(!(packageVersion("IRanges") == "2.19.10")){
  devtools::install_github("Bioconductor/IRanges")
}

if(!(packageVersion("HDF5Array") == "1.13.4")){
  devtools::install_github("Bioconductor/HDF5Array")
}

if(!(packageVersion("BiocParallel") == "1.19.0")){
  devtools::install_github("Bioconductor/BiocParallel")
}

if(!(packageVersion("DelayedArray") == "0.11.4")){
  devtools::install_github("Bioconductor/DelayedArray")
}

if(!(packageVersion("ClusterR") == "1.2.0")){
  devtools::install_github("mlampros/ClusterR")
}

if(!(packageVersion("benchmarkme") == "1.0.0")){
  install.packages("benchmarkme")
}

if(!(packageVersion("GenomicRanges") == "1.37.14")){
  devtools::install_github("Bioconductor/GenomicRanges")
}

if(!(packageVersion("SummarizedExperiment") == "1.15.6")){
  devtools::install_github("Bioconductor/SummarizedExperiment")
}

if(!(packageVersion("SingleCellExperiment") == "1.7.2")){
  devtools::install_github("drisso/SingleCellExperiment")
}

if(!(packageVersion("beachmat") == "2.1.2")){
  devtools::install_github("LTLA/beachmat")
}

if(!(packageVersion("mbkmeans") == "1.1.1")){
  devtools::install_github("drisso/mbkmeans")
}

if(!(packageVersion("dplyr") == "0.8.3")){
  install.packages("dplyr")
}

sessionInfo()