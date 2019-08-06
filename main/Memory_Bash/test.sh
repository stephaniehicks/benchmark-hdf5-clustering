data_path="/fastscratch/myscratch/rliu/Aug_data"
B_name=1
mode="mem"
method="hdf5"
size="small"
B=1
cores=1
nC=(1000)
nG=(1000)
batch=(0.005 0.01)
center=(3)
sim_center=3
initializer="random"
CURRDATE="$(date +'%T')"
FILE="csv"
file_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}.${FILE}"
dir_name="${CURRDATE}_${method}_${nC}_${batch}_${B_name}"

init=false

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				/usr/bin/time --verbose Rscript --slave ../benchmark.R \
				--args $init $mode $dir_name $file_name $method $size $B_name $cores $c $g $ba $k $initializer $B $sim_center $data_path \
				&>>test.txt
			done
		done
	done
done