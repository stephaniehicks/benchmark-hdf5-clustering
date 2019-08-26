#$ -l mem_free=4G,h_vmem=4G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_name="tenx_pbmc68k"
mode="mem"
B_name="1"
method="hdf5"

Rscript --slave ../01-cluster_full.R --args $data_name $mode $B_name $method