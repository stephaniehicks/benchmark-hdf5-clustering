#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
#$ -q shared.q@compute-06[0-9],shared.q@compute-07[2-6]
module load conda_R/3.6.x

size=("75k" "150k" "300k" "500k" "750k" "1000k")
chunk=("best" "worst" "default")
batch=500
mode="mem"
FILE="rds"
method="hdf5"
id="ruoxi_cluster"

for i in "${size[@]}"; do
	for j in "${chunk[@]}"; do
        CURRDATE="$(date +"%T-%6N")"
        file_name="${CURRDATE}_${size}_${chunk}_${k}.${FILE}"
        choice="full"
        calc_lab=TRUE
        Rscript --slave TENxBrain_chunktest.R --args $i $j $batch $mode $calc_lab $file_name $choice $method $id
done