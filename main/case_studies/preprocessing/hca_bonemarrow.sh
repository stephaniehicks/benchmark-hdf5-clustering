#$-pe local 10
#$ -l mem_free=15G,h_vmem=15G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

R -e "rmarkdown::render('hca_bonemarrow.Rmd')"
