#!/bin/bash

dir="/mnt/nicshare/FromScanner/data/raw/*" 

echo "Number of dicoms in"

for file in $dir; do
    filename=$(basename $file)
    echo "${filename}: " 
    ls -1 $file | wc -l
done

