#$ -l mem_free=15G,h_vmem=15G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load R/3.6.1

nC=(350000)
nG=(1000)
sim_center=3
data_path="/fastscratch/myscratch/rliu/Aug_data"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do 
		for i in {1..3}; do
			Rscript simulation.R --args $c $g $sim_center $data_path $i
		done
	done
done
