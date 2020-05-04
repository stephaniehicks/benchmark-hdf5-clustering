if [ $method = "kmeans" ]
then
    batch=(0.01)
fi

for ba in "${batch[@]}"; do
    for B_name in {1..9}; do
	Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $ba $run_id
    done
done


