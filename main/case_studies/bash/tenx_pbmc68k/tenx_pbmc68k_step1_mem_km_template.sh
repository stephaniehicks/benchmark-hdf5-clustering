data_name="tenx_pbmc68k"
mode="mem"
B_name="1"
method="kmeans"
batch=0.01

Rscript --slave ../../01-cluster_full.R --args $data_name $mode $B_name $method $batch $run_id


