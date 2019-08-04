#$ -l mem_free=15G,h_vmem=15G
#$ -cwd
#$ -m e
#$ -M rliu38@jhu.edu

nC=450000
init_per=0.1

Rscript --slave 0.5per_mem.R --args $nC $init_per