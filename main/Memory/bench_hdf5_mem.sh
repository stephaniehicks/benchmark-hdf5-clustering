#$ -l mem_free=15G,h_vmem=15G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

mode="mem"
method="kmeans"
size="small"
serial="1" #if needs to paralle across B, will set to 1, 2 or 3
cores=1
nC=(1000)
nG=(500)
batch=(0.001)
center=(3)
initializer="random"

CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${method}_${serial}.${FILE}"
dir_name="${CURRDATE}_${method}_${nC}_${batch}_${serial}"
#mkdir /Users/April3/benchmark-hdf5-clustering/output_files/$dir_name
mkdir /users/rliu/benchmark-hdf5-clustering/output_files/$dir_name

cores=1
nC=(1000)
nG=(500)
batch=(0.001)
center=(3)
initializer="random"

init=TRUE
R --slave -e "rmarkdown::render('../benchmark.Rmd', output_dir = '../../output_files/${dir_name}')" \
--args $mode $method $size $serial $file_name $dir_name $cores $c $g $ba $k $initializer $init

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				R --slave -e "rmarkdown::render('../benchmark.Rmd', output_dir = '../../output_files/${dir_name}')" \
				--args $mode $method $size $serial $file_name $dir_name $cores $c $g $ba $k $initializer $init
			done
		done
	done
done