#$-pe local 10
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

Rscript --slave 03-dim-reduction.R