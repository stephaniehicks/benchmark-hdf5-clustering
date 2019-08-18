#$-pe local 10
#$ -l mem_free=4G,h_vmem=4G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

R -e "rmarkdown::render('hca_cordblood.Rmd')"
