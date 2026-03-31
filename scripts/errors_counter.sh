#!/bin/bash

for file in ../logs/*.log
do
	echo "$(basename $file | cut -d '/' -f3): $(grep "ERROR" $file | wc -l)"
done
