#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

data_name="tenx_pbmc68k"
mode="time"
B_name="1"
method="hdf5"
batch=(0.001 0.01 0.05 0.1 0.2 0.25)
cluster=(10 23)

for ba in "${batch[@]}"; do
	for k in "${cluster[@]}"; do
		Rscript --slave ../../../05-cluster_pca.R --args $data_name $mode $B_name $method $ba $k
	done
done
