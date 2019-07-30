# How to generate your own bash scripts for simulation benchmark

In the directory `/benchmark-hdf5-clustering/main/Make_BashScripts`, there are three sub-directories `Accuracy`, `Memory` and `Time`, which contain text files that will be used to compose bash scripts. There is also a main bash script called `Make_Bash.sh`. User only needs to run `Make_Bash.sh` to generate bash scripts. 

1. Open `Make_Bash.sh`. Change the path in the second line to where `/benchmark-hdf5-clustering` locates.
2. Change the `head_xxx.txt` files. There are 9 `head_xxx.txt` files in total that need to be taken care of. 
	- In `/Make_BashScripts/Accuracy`, click on `head_acc.txt`. Change line #1 - #5 to the corresponding commands of your computing platform/system. Make sure line #8 has the same number as line #1. (For Stephanie: you only need to change line #5 to your own email address, and keep everything else the same)

	- In `/Make_BashScripts/Memory`, there are five sub-folders. In each one of them, there's a `head_mem.txt` file. Please click on each `head_mem.txt` and change them to the corresponding commands of your computing platform/system. (For Stephanie: you only need to change line #5 to your own email address, and keep everything else the same)

	- In `/Make_BashScripts/Time`, there are five sub-folders. In each one of them, there's a `head_time.txt` file. Please click on each `head_mem.txt` and change them to the corresponding commands of your computing platform/system. Make sure line #9 has the same number as line #1. (For Stephanie: you only need to change line #6 to your own email address, and keep everything else the same)
3. Run `Make_Bash.sh`. Then in `/benchmark-hdf5-clustering/main`, three sub-folders will appear: `Accuracy_Local`, `Memory_Local` and `Time_Local`, which will contain all the bash scripts you need for the benchmark.