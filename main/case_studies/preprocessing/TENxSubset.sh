#$ -l mem_free=50G,h_vmem=50G
#$ -cwd
#$ -m e
#$ -M shicks19@jhu.edu
module load conda_R/4.0.x
module load pandoc/2.7.3

R -e "rmarkdown::render('TENxSubset.Rmd')"
