#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

mode="mem"
method="mbkmeans"
size="small"
B_name="2" #if needs to paralle across B, will set to 1, 2 or 3
cores=1
nC=(1000 5000 25000 75000)
nG=(1000)
batch=(0.005 0.01 0.05 0.1 0.2 0.5 0.8 1)
center=(3)
initializer="random"
B=1
sim_center=3

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}"

init=TRUE
Rscript --slave ../benchmark.R \
--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave ../benchmark.R \
				--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center
			done
		done
	done
done