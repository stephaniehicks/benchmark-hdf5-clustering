#$ -l mem_free=30G,h_vmem=30G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

data_name="tenx_pbmc68k"
mode="time"
B_name="1"
method="kmeans"
batch=(0.001 0.01)

for ba in "${batch[@]}"; do
	Rscript --slave ../01-cluster_full.R --args $data_name $mode $B_name $method $ba
done