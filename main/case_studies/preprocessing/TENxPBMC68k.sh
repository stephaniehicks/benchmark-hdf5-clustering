#$-pe local 10
#$ -l mem_free=7G,h_vmem=7G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

R -e "rmarkdown::render('TENxPBMC68k.Rmd')"
