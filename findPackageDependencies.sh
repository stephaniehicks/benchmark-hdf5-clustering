#!/bin/sh
grep -hor --include='*.Rmd' 'library([^)]*)' * | sort -u > installLibraries.txt
grep -hor --include='*.R' 'library([^)]*)' * | sort -u >> installLibraries.txt
grep -hor --include='*.Rmd' 'require([^)]*)' * | sort -u >> installLibraries.txt
grep -hor --include='*.R' 'require([^)]*)' * | sort -u >> installLibraries.txt
sed -i 's/library(/\"/' installLibraries.txt
sed -i 's/)/\",/' installLibraries.txt
sed -i '1s/^/BiocManager::install(c(/' installLibraries.txt
sed -i '$ s/,$/),ask = FALSE)/' installLibraries.txt
