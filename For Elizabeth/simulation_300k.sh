#$ -l mem_free=12G,h_vmem=12G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

nC=(300000)
nG=(1000)
sim_center=3
data_path="/fastscratch/myscratch/rliu/Aug_data"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for i in {1..10}; do
			Rscript simulation.R --args $c $g $sim_center $data_path $i
		done
	done
done