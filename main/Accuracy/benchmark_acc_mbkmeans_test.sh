#$-pe local 5
#$ -l mem_free=4G,h_vmem=4G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

mode="acc"
method="mbkmeans"
size="small"
B=5
B_name="5" #if needs to paralle across B, will set to 1, 2 or 3
cores=5
nC=(1000 5000)
nG=(1000)
batch=(0.005 0.01 0.05 0.1 0.2 0.5 0.8 1)
center=(3)
initializer="random"

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${mode}_${method}_${nC}_${batch}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${mode}_${method}_${nC}_${batch}_${B_name}"

init=TRUE
Rscript --slave ../benchmark.R \
--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave ../benchmark.R \
				--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B
			done
		done
	done
done