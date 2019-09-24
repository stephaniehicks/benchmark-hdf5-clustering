#$-pe local 10
#$ -l mem_free=20G,h_vmem=20G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

R -e "rmarkdown::render('TENxBrainData.Rmd')"
