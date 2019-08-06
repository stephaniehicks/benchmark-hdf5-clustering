#$ -l mem_free=20G,h_vmem=20G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_path="/fastscratch/myscratch/rliu/Aug_data"
method="hdf5"
nC=(500000)
nG=(1000)
batch=(0.005 0.01 0.05 0.1 0.2 0.5)
initializer="random"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			/usr/bin/time --verbose Rscript --slave memory.R \
			--args $method $c $g $ba $initializer $data_path \
			&>>mem_hdf5_500k.txt
		done
	done
done
