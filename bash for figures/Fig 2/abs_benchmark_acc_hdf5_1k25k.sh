#$ -pe local 5
#$ -l mem_free=5G,h_vmem=5G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/3.6.x

#need to keep the values same in line #1 and line #8 
cores=5

B=50
B_name="50"
mode="acc"
method="hdf5"
size="small"
nC=(500 2000 4000 5000 6000 8000 10000 25000)
nG=(1000)
abs_batch=(10 35 75 150 500 750 1000)
center=(3)
sim_center=3
initializer="kmeans++"

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${mode}_${method}_${nC}_${abs_batch}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${mode}_${method}_${nC}_${abs_batch}_${B_name}"

init=TRUE
Rscript --slave ../benchmark.R \
--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${abs_batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave ../benchmark.R \
				--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center
			done
		done
	done
done