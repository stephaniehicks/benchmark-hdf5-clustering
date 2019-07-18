#$ -pe local 10
#$ -l mem_free=4G,h_vmem=4G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

data_name="tenx_pbmc68k"
mode="time"
B_name="1"

Rscript --slave 01-cluster_full.R --args $data_name $mode $B_name

if if [ $B_name = "1" ]; then
	Rscript --slave 02-normalization.R --args $data_name
	Rscript --slave 03-dim-reduction.R --args $data_name $mode $B_name
fi

