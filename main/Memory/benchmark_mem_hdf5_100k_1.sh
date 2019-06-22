#$ -l mem_free=20G,h_vmem=20G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

mode="mem"
method="hdf5"
size="small"
B_name="1" #if needs to paralle across B, will set to 1, 2 or 3
cores=1
nC=(100000)
nG=(1000)
batch=(0.005 0.01 0.2 0.5 0.8 1)
center=(3)
initializer="random"

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}"

init=TRUE
Rscript --slave ../benchmark.R \
--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer 

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave ../benchmark.R \
				--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer
			done
		done
	done
done