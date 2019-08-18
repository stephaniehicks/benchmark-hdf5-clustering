#$-pe local 10
#$ -l mem_free=8G,h_vmem=8G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

R -e "rmarkdown::render('hca_bonemarrow.Rmd')"
