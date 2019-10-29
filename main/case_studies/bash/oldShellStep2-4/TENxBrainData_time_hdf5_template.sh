data_name="TENxBrainData"
mode="time"
B_name="1"
method="hdf5"
batch=(0.001 0.01)

for ba in "${batch[@]}"; do
	Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $ba
done


