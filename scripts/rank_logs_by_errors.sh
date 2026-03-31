#!/bin/bash
touch temp.txt

for file in ../logs/*.log
do
	
        echo "$(grep "ERROR" $file | wc -l) $(basename $file | cut -d '/' -f3)" >> temp.txt
done

sort -nr temp.txt | awk '{print $2 ": " $1}'


rm temp.txt
