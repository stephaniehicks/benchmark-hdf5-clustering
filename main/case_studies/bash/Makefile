### HEADER will be file given by user with format *_header.sh
### TAG will be the * part of *_header.txt (nowhite spaces allowed)
### SHELLSCRIPT is list of all *_template.sh files (i.e. existing files) in subdirectories of the bash directory
### NEWSCRIPTS is the name of the resulting file we will create that will have the header pasted on the top (and then run). Will be given ending '*_TAG.sh'
### Example usage: make HEADER=stephanie_cluster_header.sh
TAG = $(strip $(patsubst %_header.sh, %, $(HEADER)))
SHELLSCRIPT = $(wildcard */*_template.sh) 
NEWSCRIPTS = $(SHELLSCRIPT:_template.sh=.sh)
NEWSCRIPTS = $(TAG)/$(NEWSCRIPTS)

all: check-header newscripts

newscripts: $(NEWSCRIPTS)

check-header:
ifndef HEADER
	$(error HEADER is undefined)
endif

check-tag:
	@echo $(NEWSCRIPTS)

.SECONDARY .PRECIOUS:

%_$(TAG).sh: %_template.sh $(HEADER)
	cat $(HEADER) $< > $@





