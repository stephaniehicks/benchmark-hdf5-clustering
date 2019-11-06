###########
### Example usage
###########
### make HEADER=stephanie_cluster_header.sh
### make HEADER=davide_mac_header.sh
###
### To remove (most) automatically generated *.sh files, 
### make clean

###########
### SETUP: 
###########
### (I) system-specific information: There should be a file that gives the run_id for this system and any other variables needed (e.g. cluster information). At a minimum it must define "run_id". It should be in 1 of 2 locations: 
### 	1) If information is the same for all datasets, file should be in the parent directory (bash) and it will be copied to each data directory. The name of this file should be exactly that for the HEADER variable in the call to make, e.g. davide_mac_header.sh
### 	2) If header needs to be particular to each dataset, there should be a header file in each data folder with format <data>/<data>_$(HEADER), e.g. hca_bonemarrow/hca_bonemarrow_stephanie_cluster_header.sh
### (II) data-specific information (e.g. batch): should be in data directory in format <data>/<data>_data_template.sh . Currently defines the "batch" variable.
### (III) general template: in step1_template.sh defines the basic command that is run. Currently defines variable "B_name" as well.
### The remaining variables "method" and "mode" are defined during the run of make, by looping over variables $(MODE) and $(METHODS) that are defined in the make file below. 

###########
### Variables given by user
###########
### HEADER will be file given by user with format *_header.sh


###########
### Variables defined in make file
###########
### DATASETS will be all of the data set names; should match exactly the folder names
### TAG will be the * part of *_header.sh given in $HEADER by user (no white spaces allowed)
### DATAHEADERS is the list of headers inside of each data directory (in format <data>/<data>_$(HEADER)). If not already existing, will be created based on copying *_header.sh at the top level. These are the *.sh files that are not removed when running make clean because can't tell them apart from those that are manually made.
### MODES are the different things that are recorded (e.g. acc/mem/time)
### METHODS are the different methods (hdf, mbkmeans, kmeans)
### FINALSHELLSCRIPTS is list of the final shell scrips that should be created for the acc/hdf combination that will be the targets of make(other combinations are not explicitly used for the target). They are in the format of <data>/<data>_step1_acc_hdf_$(TAG).sh Only put down acc/hdf combination as target, but the rule to make this target will loop through all; (acc/hdf is the last of the combinations so will ensure all are made without errors). e.g. dataset/dataset_step1_acc_hdf_stephanie_cluster.sh
DATASETS = tenx_pbmc68k TENxBrainData hca_cordblood hca_bonemarrow
TAG = $(strip $(patsubst %_header.sh, %, $(HEADER)))
MODES = mem time acc
METHODS = kmeans mbkmeans hdf5
DATAHEADERS=$(foreach data, $(DATASETS), $(data)/$(data)_$(HEADER))
FINALSHELLSCRIPTS=$(foreach data,$(DATASETS), $(data)/$(data)_step1_acc_hdf_$(TAG).sh)

all: check-header $(FINALSHELLSCRIPTS)

check-header:
ifndef HEADER
	$(error HEADER is undefined)
endif

check-tag:
	@echo $(FINALSHELLSCRIPTS)

clean:
	rm */*_template_*.sh
	rm */*step1*.sh

.SECONDARY .PRECIOUS:

## 
# 0) Copy single header to each dataset file if there is single header; i.e. create <data>/<data>_davide_mac_header.sh

#creates files <data>/<data>_davide_mac_header.sh
%_$(HEADER): $(HEADER)
	cp $(HEADER) $@

# 1) Adds the "data_name" variable and info in the *_data_template.sh to the existing system-specific header that's in the folder (from step 0 if not already created.)
# e.g. data_name="tenx_pbmc68k"
# Concatenates to *bottom* of file
# Also concatenates <data>/<data>_data_template.sh to the *bottom* of the file.
# batch=(0.001 0.01 0.05 0.1 0.2 0.25)
#
# creates files e.g. <data>/<data>_template_davide_mac.sh
# input is file <data>/<data>_davide_mac_header.sh
# IMPORTANT: doesn't delete the file <data>/<data>_davide_mac_header.sh, because for the system specific (i.e. stephanie_cluster_header.sh) would delete that
%_template_$(TAG).sh: %_$(HEADER)
	echo '\ndata_name="$(@D)"' > temp.txt
	cat temp.txt $*_data_template.sh > temp2.txt
	cat $< temp2.txt > $@
	rm temp.txt
	rm temp2.txt


# 2) loop over method and mode to create .sh file for each legitimate combination (i.e. not mbkmeans/acc because not needed), along with step1_template.sh and the data-specific template from step 1
# creates files <data>/<data>_step1_acc_hdf_template_davide_mac.sh
# Relies on file <data>/<data>_template_davide_mac.sh and step1_template.sh
%_step1_acc_hdf_$(TAG).sh: %_template_$(TAG).sh step1_template.sh
	for method in $(METHODS); do \
		for mode in $(MODES) ; do \
			if [[ $$method != "mbkmeans" || $$mode != "acc" ]]; \
			then \
			echo 'mode="'$$mode'"\nmethod="'$$method'"' > temp.txt; \
			cat temp.txt step1_template.sh > temp_template.sh; \
			cat $< temp_template.sh > "$*_step1_$${mode}_$${method}_$(TAG).sh" ; \
			rm temp.txt; \
			rm temp_template.sh; \
			fi \
		done \
	done


