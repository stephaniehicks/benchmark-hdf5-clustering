### Variables given by user
### HEADER will be file given by user with format *_header.sh
### Example usage: make HEADER=stephanie_cluster_header.sh
### If there are different headers for different datasets

### Variables defined in make file
### DATASETS will be all of the datanames
### TAG will be the * part of *_header.sh given in $HEADER (no white spaces allowed)
### SHELLSCRIPT is list of all *_template.sh files (i.e. existing files) in subdirectories of the bash directory
### NEWSCRIPTS is the name of the resulting file we will create that will have the header pasted on the top (and then run). Will be given ending '*_TAG.sh'
### FOUNDHEADERS will go through each data directory and find the data-specific header, if exists; otherwise will assume there is a top-level file.

DATASETS = tenx_pbmc68k TENxBrainData hca_cordblood hca_bonemarrow
### The first argument, condition, first has all preceding and trailing whitespace stripped, then is expanded. If it expands to any non-empty string, then the condition is considered to be true. If it expands to an empty string, the condition is considered to be false. 
# find_files = $(if("$(wildcard $(data)/$(data)_$(HEADER))", $(dir)/$(HEADER), $(HEADER)))
# $FOUNDHEADERS=$(foreach data,$(DATASETS), find_files)
TAG = $(strip $(patsubst %_header.sh, %, $(HEADER)))
MODES = mem time acc
METHODS = kmeans mbkmeans hdf5

DATAHEADERS=$(foreach data, $(DATASETS), $(data)/$(data)_$(HEADER))

#only put down acc/hdf combination, but the rule will loop through all.
FINALSHELLSCRIPTS=$(foreach data,$(DATASETS), $(data)/$(data)_step1_acc_hdf_$(TAG).sh)

# data_name="tenx_pbmc68k"
# mode="acc"
# method="kmeans"
# batch=(0.001 0.01)

all: check-header $(FINALSHELLSCRIPTS)

check-header:
ifndef HEADER
	$(error HEADER is undefined)
endif

check-tag:
	@echo $(FINALSHELLSCRIPTS)

.SECONDARY .PRECIOUS:

## Example file to create:
## dataset/dataset_step1_acc_hdf_stephanie_cluster.sh
## Example template step1_template.sh
## 
# 0) Copy single header to each dataset file if there is single header; i.e. <data>/<data>_davide_mac_header.sh

#creates files <data>/<data>_davide_mac_header.sh
%_$(HEADER): $(HEADER)
	cp $(HEADER) $@

# 1) add the dataset specific stuff to that header
# <data>/<data
# data_name="tenx_pbmc68k" concatenate to *bottom* of file
# batch=(0.001 0.01 0.05 0.1 0.2 0.25)
#
# #creates files <data>/<data>_template_davide_mac.sh
# #from file <data>/<data>_davide_mac_header.sh
# # Adds the data_name  and info in the *_data_template.sh to the existing header that's in the folder.
%_template_$(TAG).sh: %_$(HEADER)
	echo "data_name=$(@D)" > temp.txt
	cat temp.txt $*_data_template.sh > temp.txt
	cat $< temp.txt > $@
	rm temp.txt


# 2) make a template step1_acc_hdf_template.sh, which is the non-dataset specific template
# mode="time"
# method="hdf5"
# #creates files <data>/<data>_step1_acc_hdf_template_davide_mac.sh
# #from file <data>/<data>_template_davide_mac.sh
# Haven't checked this yet! And need to repeat for each combination...

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

method="mbkmeans"; mode= "mem", "time"

# for $mode in $(MODES) ; do \
# 	echo 'mode="$mode"\nmethod="$method"' > temp.txt; \
# done

# 
# 
# 	        echo $$number ; \done





