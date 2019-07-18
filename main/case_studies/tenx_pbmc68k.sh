#$ -l mem_free=20G,h_vmem=20G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

data_name="tenx_pbmc68k"
mode="time"
B_name="1"