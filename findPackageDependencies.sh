#!/bin/sh
grep -hor --include='*.Rmd' 'library([^)]*)' * | sort -u > installLibraries.txt
grep -hor --include='*.R' 'library([^)]*)' * | sort -u >> installLibraries.txt
grep -hor --include='*.Rmd' 'require([^)]*)' * | sort -u >> installLibraries.txt
grep -hor --include='*.R' 'require([^)]*)' * | sort -u >> installLibraries.txt
mv installLibraries.txt installLibraries.R
sed -i 's/library(/\"/' installLibraries.R
sed -i 's/)/\",/' installLibraries.R
sed -i '1s/^/BiocManager::install(c(/' installLibraries.R
sed -i '$ s/,$/),ask = FALSE)/' installLibraries.R
