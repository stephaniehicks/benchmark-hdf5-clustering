$ head test.sh

#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu


CURRDATE="$(date +'%Y_%m_%d_%R')"
FILE="simulate_hdf5_accuracy"
BASEFILE="${FILE}_${CURRDATE}"
MEMORYFILE="${BASEFILE}_memoryLogger.txt"
MEMORYSUMMARY="${BASEFILE}_memorySummary.txt"
#RFILE="${FILE}.R"
#ROUT="${BASEFILE}.Rout"

while true; do free -g >> $MEMORYFILE; sleep 15; done &
module load conda_R/devel 
R -e "rmarkdown::render('/users/rliu/mbkmeans/simulate_hdf5_accuracy.Rmd')"

Rscript /users/rliu/mbkmeans/readMemoryLog.R $MEMORYFILE > $MEMORYSUMMARY
