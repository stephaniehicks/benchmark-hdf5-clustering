#$-pe local 10
#$ -l mem_free=7G,h_vmem=7G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

R -e "rmarkdown::render('TENxPBMC68k.Rmd')"
