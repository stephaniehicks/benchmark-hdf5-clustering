$ head ChunkTest_1m_d1.sh

#$ -l mem_free=50G,h_vmem=50G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/devel

init=true
CURRDATE="$(date +'%T')"
FILE="csv"
serial="12"
file_name="${CURRDATE}_${serial}.${FILE}"

data_name="/users/rliu/data/sim_data_1m_1.rds"

Rscript --slave ChunkTest.R --args $init $file_name

init=false

nC=(1000000)
nG=(1000)
batch=(0.001 0.005 0.01 0.05 0.2)
chunk="default"

for i in "${nC[@]}"; do 
	for j in "${nG[@]}"; do 
		for k in "${batch[@]}"; do 
			Rscript --slave ChunkTest.R --args $init $file_name $chunk $i $j $k $data_name
		done
	done
done
