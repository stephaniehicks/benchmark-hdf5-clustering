#$ -l mem_free=10G,h_vmem=10G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

data_path="/fastscratch/myscratch/rliu/Aug_data"
method="hdf5"
nC=(1000)
nG=(1000)
batch=(0.005 0.01)
initializer="random"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for ba in "${batch[@]}"; do 
			/usr/bin/time --verbose Rscript --slave memory.R \
			--args $method $c $g $ba $initializer $data_path \
			&>>test.txt
		done
	done
done
