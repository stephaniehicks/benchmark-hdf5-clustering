#$-pe local 10
#$ -l mem_free=8G,h_vmem=8G
#$ -cwd
#$ -m e
#$ -M shicks19@jhu.edu
module load conda_R/3.6
module load pandoc/2.7.3

R -e "rmarkdown::render('hca_cordblood.Rmd')"
