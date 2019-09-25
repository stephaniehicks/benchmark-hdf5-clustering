#$ -pe local 10
#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

Rscript --slave testHCA_500genes.R

