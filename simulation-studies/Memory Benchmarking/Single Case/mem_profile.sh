$ head mem_profile.sh

#$ -cwd
#$ -m e

module load conda_R/devel 
R -e "rmarkdown::render('Memory_Benchmark.Rmd')"