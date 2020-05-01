#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu
module load conda_R/3.6.x

size=("75k" "150k" "300k" "500k" "750k" "1000k")

for i in "${size[@]}"; do 
	Rscript --slave Save_in_three_ways.R --args $i
done