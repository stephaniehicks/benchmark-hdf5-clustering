#$ -l mem_free=120G,h_vmem=120G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1
run_id="stephanie_cluster"

data_name="TENxBrainData"
B_name="1"

Rscript --slave ../../02-normalization.R --args $data_name $B_name
Rscript --slave ../../03_1-feature_selection.R --args $data_name $B_name
Rscript --slave ../../03_2-pca.R --args $data_name $B_name
Rscript --slave ../../04-cluster_find_k.R --args $data_name $B_name