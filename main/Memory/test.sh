#!/bin/bash

#init=false
#a=10
#b=20

#Rscript /Users/April30/Desktop/Untitled.R --args $init $a $b

#for i in 0 1 2 3 4 5 6 7 8 9; do for j in 0 1 2 3 4 5 6 7 8 9; do echo "$i$j"; done; done

#array=( "Vietnam" "Germany" "Argentina" )
#array2=( "Asia" "Europe" "America" )

#for ((i=0;i<${#array[@]};++i)); do
#    printf "%s is in %s\n" "${array[i]}" "${array2[i]}"
#done

#chunk="one"
#Rscript /Users/April30/Desktop/Untitled.R --args $chunk
init=true

Rscript /../test.R --args $init