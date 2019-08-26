#$ -pe local 10
#$ -l mem_free=15G,h_vmem=15G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_name="TENxBrainData"
mode="time"
B_name="1"
method="hdf5"

#Rscript --slave ../01-cluster_full.R --args $data_name $mode $B_name $method

#if [ $B_name = "1" ]; then
#	Rscript --slave ../02-normalization.R --args $data_name 
#	Rscript --slave ../03-dim-reduction.R --args $data_name $B_name
#	Rscript --slave ../04-cluster_find_k.R --args $data_name $B_name
#fi

Rscript --slave ../03-dim-reduction.R --args $data_name $B_name


