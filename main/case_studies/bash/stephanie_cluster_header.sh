#$ -l mem_free=30G,h_vmem=30G
#$ -cwd
#$ -m e
#$ -M shicks19@jhu.edu
module load conda_R/4.0.x
module load pandoc/2.7.3

run_id="stephanie_cluster"