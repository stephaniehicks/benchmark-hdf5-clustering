#$ -l mem_free=80G,h_vmem=80G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_name="hca_bonemarrow"
mode="mem"
B_name="1"
method="kmeans"
batch=0.01

Rscript --slave ../01-cluster_full.R --args $data_name $mode $B_name $method $batch
