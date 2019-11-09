#$-pe local 6
#$ -l mem_free=7G,h_vmem=7G
#$ -cwd
#$ -m e
#$ -M shicks19@jhu.edu
module load conda_R/3.6
module load pandoc/2.7.3

R -e "rmarkdown::render('TENxPBMC68k.Rmd')"
