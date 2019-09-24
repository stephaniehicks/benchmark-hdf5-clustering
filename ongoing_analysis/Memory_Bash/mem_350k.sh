#$ -q shared.q@compute-06[0-9],shared.q@compute-07[2-6]
#$ -l mem_free=15G,h_vmem=15G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_path="/fastscratch/myscratch/rliu/Aug_data"
method="hdf5"
nC=(350000)
nG=(1000)
batch=(0.005 0.01 0.05 0.1 0.2 0.5)
initializer="random"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			/usr/bin/time --verbose Rscript --slave memory.R \
			--args $method $c $g $ba $initializer $data_path \
			&>>mem_hdf5_350k.txt
		done
	done
done
