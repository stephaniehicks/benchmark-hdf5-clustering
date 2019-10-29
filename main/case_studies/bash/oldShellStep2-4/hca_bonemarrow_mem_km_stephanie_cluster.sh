#$ -l mem_free=120G,h_vmem=120G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1
run_id="stephanie_cluster"

data_name="hca_bonemarrow"
mode="mem"
B_name="1"
method="kmeans"
batch=0.01

Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $batch
