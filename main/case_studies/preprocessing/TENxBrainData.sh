#$ -pe local 5
#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M shicks19@jhu.edu
module load conda_R/4.0.x
module load pandoc/2.7.3

R -e "rmarkdown::render('TENxBrainData.Rmd')"
