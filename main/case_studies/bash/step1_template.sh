if [ $method = "kmeans" ]
then
    batch=(0.01)
fi

if [ $mode = "mem" ]
then
    MAX=1
else
    MAX=9
fi

for ba in "${batch[@]}"; do
    for B_name in $(seq 1 $MAX); do
    	Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $ba $run_id
    done
done


