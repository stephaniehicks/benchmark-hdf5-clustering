#$ -l mem_free=4G,h_vmem=4G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

data_name="tenx_pbmc68k"
mode="time"
B_name="1"
method="mbkmeans"
batch_size=(0.01 0.05)
k=20

for batch in "${batch_size[@]}"; do 
	Rscript --slave 05-cluster_pca.R --args $data_name $mode $B_name $method $batch $k
done

