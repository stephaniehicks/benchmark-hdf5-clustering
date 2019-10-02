### SHELLSCRIPT is list of all *_template.sh files (i.e. existing files) in subdirectories of the bash directory
### NEWSCRIPTS is the name of the resulting file we will create that will have the header pasted on the top (and then run)
### HEADER will be file given by user
SHELLSCRIPT = $(wildcard */*_template.sh) 
NEWSCRIPTS= $(patsubst %_template.sh, %.sh, $(SHELLSCRIPT))

all: check-header newscripts

newscripts: $(NEWSCRIPTS)

check-header:
ifndef HEADER
	$(error HEADER is undefined)
endif

.SECONDARY .PRECIOUS:

%.sh: %_template.sh $(HEADER)
	cat $(HEADER) $< > $@





