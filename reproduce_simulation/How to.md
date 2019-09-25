# How to run simulation benchmark

## Step1: Run `version_check.R`

## Step2: Simulate the data needed for simulation benchmark (may take up to 7 hours to complete)
1. There are 6 bash scripts for running the R script to simulate the data. The bash scripts are named in the format `simulation_size.sh`. 
2. Need to mannually change the headers in each of the six bash scripts (line #1 to #4)
3. Need to mannually change the parameter `data_path` (in line #9) in each of the six bash scripts. The path should be a directory where you want to save the simulated data. Please note that the simulated data are large: need around 650G storage space.

## Step3: Generate your own bash scripts for simulation benchmark
In the directory `/benchmark-hdf5-clustering/reproduce_simulation/Make_BashScripts`, there are three sub-directories `Accuracy`, `Memory` and `Time`, which contain text files that will be used to compose bash scripts. There is also a main bash script called `Make_Bash.sh`. You only need to run `Make_Bash.sh` to generate bash scripts. But before running `Make_Bash.sh`, some changes need to be done to customize the scripts and make it work for your computing platform.

1. Open `Make_Bash.sh`. Change the path in line #2 to where `/benchmark-hdf5-clustering` locates.
2. Change the `head_xxx.txt` files. There are 9 `head_xxx.txt` files in total that need to be taken care of. 
	- In `/Make_BashScripts/Accuracy`, click on `head_acc.txt`. Change line #1 - #5 to the corresponding commands of your computing platform/system. Make sure line #8 has the same number as line #1. (For Stephanie: you only need to change line #5 to your own email address, and keep everything else the same)

	- In `/Make_BashScripts/Memory`, there are five sub-folders. In each one of them, there's a `head_mem.txt` file. Please click on each `head_mem.txt` and change them to the corresponding commands of your computing platform/system. (For Stephanie: you only need to change line #5 to your own email address, and keep everything else the same)

	- In `/Make_BashScripts/Time`, there are four sub-folders. In each one of them, there's a `head_time.txt` file. Please click on each `head_mem.txt` and change them to the corresponding commands of your computing platform/system. Make sure line #9 has the same number as line #1. (For Stephanie: you only need to change line #6 to your own email address, and keep everything else the same)
3. Run `Make_Bash.sh` 
	- `cd benchmark-hdf5-clustering/reproduce_simulation/Make_BashScripts/`
	- Submit `Make_Bash.sh`. For Mac OS, the command is `sh Make_Bash.sh`. 
	- Then in `/benchmark-hdf5-clustering/main`, three sub-folders will appear: `Accuracy_Local`, `Memory_Local` and `Time_Local`, which will contain all the bash scripts you need for the benchmark. 
	- Please note that the three sub-folders are customized according to your computing platform. They have been added in `.gitignore` and you may need to mannually upload them to your computing platform. When upload, please make sure to upload them to `/benchmark-hdf5-clustering/main/`.

## Step4: Run the bash scripts generated above, in `Accuracy_Local`, `Memory_Local` and `Time_Local`. 
1. To run the bash scripts, recommend to change directory to the folder where the bash scripts locate.
	- For example, to submit bash scripts in `Accuracy_Local`, firstly `cd /benchmark-hdf5-clustering/main/Accuracy_Local`. Then submit the the bash scripts (in JHPCE, the command is `qsub xxxx.sh`).
2. The results will be automatically put into `/benchmark-hdf5-clustering/main/output_tables`, and the `.out` files generated from the memory benchmark will be put into `/benchmark-hdf5-clustering/main/output_files`. 
3. Time required to run the bash scripts: 
	- Accuracy (small data): ~ 2 hours
	- Time & Memory: up to ~ 14 hours for 1-million-data
4. Push your changes to https://github.com/stephaniehicks/benchmark-hdf5-clustering. Please note the `.out` files in `/benchmark-hdf5-clustering/main/output_files` will not be pushed as it has been added to `.gitignore`. 
