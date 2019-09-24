library(mbkmeans)
library(rhdf5)
library(mclust)
library(dplyr)
library(parallel)
library(HDF5Array)
library(benchmarkme)
library(here)

if(!(R.Version()$version.string == "R version 3.6.1 (2019-07-05)")){
  print("Please update R to 3.6.1")
}

if(!(packageVersion("rhdf5") == "2.29.2")){
  devtools::install_github("grimbough/rhdf5")
}

if(!(packageVersion("BiocGenerics") == "0.31.5")){
  devtools::install_github("Bioconductor/BiocGenerics")
}

if(!(packageVersion("S4Vectors") == "0.23.17")){
  devtools::install_github("Bioconductor/S4Vectors", ref="ce71c2c784cfe5ab2d9f8c29d780e7d2f18aea0e")
}

if(!(packageVersion("IRanges") == "2.19.10")){
  devtools::install_github("Bioconductor/IRanges", ref = "72dc0ecbe3e7783995aba5bec4771d665c40ded9")
}

if(!(packageVersion("DelayedArray") == "0.11.4")){
  devtools::install_github("Bioconductor/DelayedArray")
}

if(!(packageVersion("HDF5Array") == "1.13.4")){
  devtools::install_github("Bioconductor/HDF5Array", ref = "8a2f3798c092970e861599bea34f43c1d57124ce")
}

if(!(packageVersion("BiocParallel") == "1.19.0")){
  devtools::install_github("Bioconductor/BiocParallel", ref = "593b26b6031f0c28a3163fc6a9972e0f1c9b84b0")
}

if(!(packageVersion("ClusterR") == "1.2.0")){
  devtools::install_github("mlampros/ClusterR", ref = "63538bd880120f06c6f41e7fecd9b2398251e1c5")
}

if(!(packageVersion("benchmarkme") == "1.0.2")){
  install.packages("benchmarkme")
}

if(!(packageVersion("GenomicRanges") == "1.37.14")){
  #withr::with_libpaths(new = "/users/rliu/packages/R/3.6/lib64/R/library", install_github("Bioconductor/GenomicRanges", ref = "a0657e29ba80c9fadfa8a7c5b6606697dfac8073"))
  devtools::install_github("Bioconductor/GenomicRanges", ref = "a0657e29ba80c9fadfa8a7c5b6606697dfac8073")
}

if(!(packageVersion("SummarizedExperiment") == "1.15.6")){
  devtools::install_github("Bioconductor/SummarizedExperiment", ref = "4a62d754b67a13656c1851f62fc46d0ae075395c")
}

if(!(packageVersion("SingleCellExperiment") == "1.7.2")){
  devtools::install_github("drisso/SingleCellExperiment", ref = "1125fa310530bd85ae191a7fd2c7fd1fd0088022")
}

if(!(packageVersion("mclust") == "5.4.5")){
  install.packages("mclust")
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