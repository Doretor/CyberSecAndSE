#!/bin/bash

FILE=""

count_error() {
	echo "ERROR: $(grep "ERROR" $FILE | wc -l)"
}
count_info() {
	echo "INFO: $(grep "INFO" $FILE | wc -l)"
}
count_warn() {
	echo "WARN: $(grep "WARN" $FILE | wc -l)"
}

for file in ../logs/*.log
do
	FILE=$file
	echo "$(basename $file | cut -d '/' -f3):"
	count_error
	count_info
	count_warn

done
