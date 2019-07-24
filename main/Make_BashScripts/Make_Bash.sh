#Change the path to where "benchmark-hdf5-clustering" locates
benchmark_path="/Users/April30"
cd $benchmark_path/benchmark-hdf5-clustering/main/

mkdir Accuracy_Local
mkdir Memory_Local
mkdir Time_Local

cd Make_BashScripts/Accuracy
for filename in benchmark_*.txt; do
	cat head_acc.txt $filename >> ../../Accuracy_Local/${filename%.txt}.sh
done

cd ../Time
for dirname in */ ; do
	for filename in ${dirname}benchmark_*.txt; do
		name=${filename##*/}
		cat ${dirname}head_mem.txt ${filename} >> ../../Time_Local/${name%.txt}.sh
	done
done

cd ../Memory

