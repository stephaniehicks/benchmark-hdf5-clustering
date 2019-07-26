#$ -l mem_free=10G,h_vmem=10G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

R -e "rmarkdown::render('/users/rliu/benchmark-hdf5-clustering/ongoing_analysis/Test-wcss.Rmd')"
