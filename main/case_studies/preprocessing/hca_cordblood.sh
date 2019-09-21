#$-pe local 10
#$ -l mem_free=8G,h_vmem=8G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

R -e "rmarkdown::render('hca_cordblood.Rmd')"
