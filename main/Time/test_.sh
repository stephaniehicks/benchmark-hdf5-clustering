#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

R -e "rmarkdown::render('test_.Rmd')"
