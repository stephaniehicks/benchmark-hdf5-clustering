#$ -l mem_free=6G,h_vmem=6G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/3.6.x

nC=(25000 100000)
nG=(1000)
sim_center=15
data_path="/fastscratch/myscratch/rliu/April_data_15k"

for c in "${nC[@]}"; do 
	for g in "${nG[@]}"; do
		Rscript simulation_k.R --args $c $g $sim_center $data_path
	done
done
