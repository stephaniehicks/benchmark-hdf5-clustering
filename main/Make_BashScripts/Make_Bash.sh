# Change the path to where "benchmark-hdf5-clustering" locates
# If you open this file with a .Rproject file, the PWD points to where the .Rproj is
benchmark_path=$PWD
cd ${benchmark_path}/main/

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
		cat ${dirname}head_time.txt ${filename} >> ../../Time_Local/${name%.txt}.sh
	done
done

cd ../Memory
for dirname in */ ; do
	for filename in ${dirname}benchmark_*.txt; do
		for B in {1..6}; do
			name=${filename##*/}
			cat ${dirname}head_mem.txt >> ../../Memory_Local/${name%.txt}_${B}.sh
			(echo ""; echo "B_name="${B}) >> ../../Memory_Local/${name%.txt}_${B}.sh
			cat ${filename} >> ../../Memory_Local/${name%.txt}_${B}.sh
		done
	done
done

for B in {4..6}; do
	rm ${benchmark_path}/benchmark-hdf5-clustering/main/Memory_Local/*_500k_${B}.sh
	rm ${benchmark_path}/benchmark-hdf5-clustering/main/Memory_Local/*_1m_${B}.sh
done


