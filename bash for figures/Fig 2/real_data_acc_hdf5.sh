run_id="ruoxi_cluster"
data_name=("TENxBrainData_5k" "TENxBrainData_10k" "TENxBrainData_25k")
cores=6

B=50
B_name="50"
mode="acc"
method="hdf5"
abs_batch=(10 35 75 150 500 750 1000)
center=15


for i in "${data_name[@]}"; do 
	CURRDATE="$(date +'%T')"
	FILE="csv"
	file_name="${CURRDATE}_${mode}_${method}_${i}_${B_name}_${run_id}.${FILE}"
	init=TRUE
	Rscript --slave real_data_acc.R \
	--args $init $mode $file_name $method $cores $abs_batch $center $B $i $run_id
	init=false
	for ba in "${abs_batch[@]}"; do
		Rscript --slave real_data_acc.R \
		--args $init $mode $file_name $method $cores $ba $center $B $i $run_id
	done
done

