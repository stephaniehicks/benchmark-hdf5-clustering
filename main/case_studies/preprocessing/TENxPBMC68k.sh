#$-pe local 10
#$ -l mem_free=4G,h_vmem=4G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

R -e "rmarkdown::render('TENxPBMC68k.Rmd')"
