#$ -l mem_free=2G,h_vmem=2G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

run_id="davide_mac"
data_name="tenx_pbmc68k"
mode="acc"
B_name="1"
method="hdf5"
batch=(0.001 0.01)
k=(10 23)

for ba in "${batch[@]}"; do
	Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $ba $run_id
done
