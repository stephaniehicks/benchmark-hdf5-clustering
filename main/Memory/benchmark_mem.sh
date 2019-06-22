#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

mode="mem"
method="kmeans"
size="small"
B_name="1" #if needs to paralle across B, will set to 1, 2 or 3
cores=1
nC=(1000)
nG=(500)
batch=(0.001)
center=(3)
initializer="random"

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${method}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}"

init=TRUE
Rscript --slave /../benchmark.R \
--args $mode $method $size $B_name $file_name $dir_name $cores $c $g $ba $k $initializer $init

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave /../benchmark.R \
				--args $mode $method $size $B_name $file_name $dir_name $cores $c $g $ba $k $initializer $init
			done
		done
	done
done