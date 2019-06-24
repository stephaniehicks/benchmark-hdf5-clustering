#$ -l mem_free=10G,h_vmem=10G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

R -e "rmarkdown::render('Memory_Benchmark.Rmd')"