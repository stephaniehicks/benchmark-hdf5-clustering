#$ -pe local 6
#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M shicks19@jhu.edu
module load conda_R/4.0.x
module load pandoc/2.7.3

run_id="stephanie_cluster"
data_name=("TENxBrainData_5k" "TENxBrainData_10k" "TENxBrainData_25k")
cores=6

B=50
B_name="50"
mode="acc"
method="ClusterR"
abs_batch=(10 35 75 150 500 750 1000)
center=15


for i in "${data_name[@]}"; do 
	CURRDATE="$(date +'%T')"
	FILE="csv"
	file_name="${CURRDATE}_${mode}_${method}_${i}_${B_name}_${run_id}.${FILE}"
	init=TRUE
	Rscript --slave ../../main/real_data_acc.R \
	--args $init $mode $file_name $method $cores $abs_batch $center $B $i $run_id
	init=false
	for ba in "${abs_batch[@]}"; do
		Rscript --slave ../../main/real_data_acc.R \
		--args $init $mode $file_name $method $cores $ba $center $B $i $run_id
	done
done

