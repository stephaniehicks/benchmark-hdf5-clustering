# How to generate your own bash scripts for simulation benchmark

In the directory `/benchmark-hdf5-clustering/main/Make_BashScripts`, there are three sub-directories `Accuracy`, `Memory` and `Time`, which contain text files that will be used to compose bash scripts. There is also a main bash script called `Make_Bash.sh`. User only needs to run `Make_Bash.sh` to generate bash scripts. 

1. Open `Make_Bash.sh`. Change the path in the second line to where `/benchmark-hdf5-clustering` locates.
2. Change the `head_xxx.txt` files. There are 9 `head_xxx.txt` files in total that need to be taken care of. 