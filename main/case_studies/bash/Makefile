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
find_files = $(if("$(wildcard $(data)/$(data)_$(HEADER))", $(dir)/$(HEADER), $(HEADER)))
$FOUNDHEADERS=$(foreach data,$(DATASETS), find_files)
TAG = $(strip $(patsubst %_header.sh, %, $(HEADER)))
MODES = acc mem time
METHODS = kmeans hdf5 mbkmeans

SHELLSCRIPT = $(wildcard */*_template.sh) 
NEWSCRIPTS = $(SHELLSCRIPT:_template.sh=_$(TAG).sh)

# data_name="tenx_pbmc68k"
# mode="acc"
# method="kmeans"
# batch=(0.001 0.01)
DATAHEADERS=$(foreach data, $(DATASETS), $(data)/$(data)_$(HEADER))

all: check-header $(DATAHEADERS)

newscripts: $(NEWSCRIPTS)

check-header:
ifndef HEADER
	$(error HEADER is undefined)
endif

check-tag:
	@echo $(DATAHEADERS)

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
# # Adds the data_name 
%_template_$(TAG).sh: %_$(HEADER)
	echo "data_name=$(@D)" > temp.txt
	cat temp.txt $< > $@
	# rm temp.text


# 2) make a template step1_acc_hdf_template.sh, which is the non-dataset specific template
# mode="time"
# method="hdf5"
#
# 3) make dataset/step1_acc_hdf_<header>.sh
#
#
# %_$(TAG).sh: %_template.sh $(HEADER)
# 	cat $(HEADER) $< > $@
# 	cat $()
#
# clean:
# 	rm $(NEWSCRIPTS)


