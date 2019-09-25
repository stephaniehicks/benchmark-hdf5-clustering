# Change the path to where "benchmark-hdf5-clustering" locates
# If you open this file with a .Rproject file, the PWD points to where the .Rproj is
benchmark_path="/Users/April30"
cd ${benchmark_path}/benchmark-hdf5-clustering/main/

mkdir Accuracy_Local
mkdir Memory_Local
mkdir Time_Local

cd ../reproduce_simulation/Make_BashScripts/Accuracy
for filename in benchmark_*.txt; do
	cat head_acc.txt $filename >> ../../../main/Accuracy_Local/${filename%.txt}.sh
done

cd ../Time
for dirname in */ ; do
	for filename in ${dirname}benchmark_*.txt; do
		name=${filename##*/}
		cat ${dirname}head_time.txt ${filename} >> ../../../main/Time_Local/${name%.txt}.sh
	done
done

cd ../Memory
for dirname in */ ; do
	for filename in ${dirname}benchmark_*.txt; do
		for B in {1..6}; do
			name=${filename##*/}
			cat ${dirname}head_mem.txt >> ../../../main/Memory_Local/${name%.txt}_${B}.sh
			(echo ""; echo "B_name="${B}) >> ../../../main/Memory_Local/${name%.txt}_${B}.sh
			cat ${filename} >> ../../../main/Memory_Local/${name%.txt}_${B}.sh
		done
	done
done

for B in {4..6}; do
	rm ${benchmark_path}/benchmark-hdf5-clustering/main/Memory_Local/*_300k_${B}.sh
	rm ${benchmark_path}/benchmark-hdf5-clustering/main/Memory_Local/*_350k_${B}.sh
	rm ${benchmark_path}/benchmark-hdf5-clustering/main/Memory_Local/*_500k_${B}.sh
	rm ${benchmark_path}/benchmark-hdf5-clustering/main/Memory_Local/*_1m_${B}.sh
done



