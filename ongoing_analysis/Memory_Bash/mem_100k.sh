#$ -q shared.q@compute-06[0-9],shared.q@compute-07[2-6]
#$ -l mem_free=10G,h_vmem=10G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_path="/fastscratch/myscratch/rliu/Aug_data"
method="hdf5"
nC=(100000)
nG=(1000)
batch=(0.005 0.01 0.05 0.1 0.2 0.5 0.8 1)
initializer="random"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			/usr/bin/time --verbose Rscript --slave memory.R \
			--args $method $c $g $ba $initializer $data_path \
			&>>mem_hdf5_100k.txt
		done
	done
done
