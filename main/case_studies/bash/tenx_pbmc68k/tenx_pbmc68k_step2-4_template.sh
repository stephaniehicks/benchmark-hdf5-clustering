data_name="tenx_pbmc68k"
B_name="1"

Rscript --slave ../../02-normalization.R --args $data_name $B_name
Rscript --slave ../../03_1-feature_selection.R --args $data_name $B_name
Rscript --slave ../../03_2-pca.R --args $data_name $B_name
Rscript --slave ../../04-cluster_find_k.R --args $data_name $B_name