data_path="/fastscratch/myscratch/rliu/April_data_15k"

mode="mem"
method=("kmeans" "mbkmeans" "hdf5")
size="small"
B=1
B_name="1" #if needs to paralle across B, will set to 1, 2 or 3
cores=1
nC=(25000 100000)
nG=(1000)
batch=(75 500 1000)
center=(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
sim_center=15
initializer="kmeans++"
max_iters=100
num_init=10
data_number=10
id="ruoxi_cluster"

for i in "${method[@]}"; do
	CURRDATE="$(date +'%T')"
	FILE="csv"
	file_name="${CURRDATE}_${i}_${nC}_${batch}_${B_name}.${FILE}"
	dir_name="${CURRDATE}_${i}_${nC}_${batch}_${B_name}"

	init=TRUE
	Rscript --slave ../benchmark_varying_k.R \
	--args $init $mode $dir_name $file_name $i $size $B_name $cores $nC $nG $batch $center $initializer $B $sim_center $data_path $max_iters $num_init $data_number $id

	init=false
	for c in "${nC[@]}"; do 
		for ba in "${batch[@]}"; do 
			for k in "${center[@]}";do
				Rscript --slave ../benchmark_varying_k.R \
				--args $init $mode $dir_name $file_name $i $size $B_name $cores $c $nG $ba $k $initializer $B $sim_center $data_path $max_iters $num_init $data_number $id
			done
		done
	done
done