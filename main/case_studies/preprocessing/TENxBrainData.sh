#$-pe local 10
#$ -l mem_free=20G,h_vmem=20G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

R -e "rmarkdown::render('TENxBrainData.Rmd')"