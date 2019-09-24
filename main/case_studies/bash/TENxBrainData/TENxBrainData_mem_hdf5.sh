#$ -l mem_free=120G,h_vmem=120G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

data_name="TENxBrainData"
mode="mem"
B_name="1"
method="hdf5"
batch=(0.001 0.01)

for ba in "${batch[@]}"; do
	Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $ba
done
