#!/bin/bash

FILE=""

count_error() {
        echo "ERROR: $(grep "ERROR" $FILE | wc -l)" >> ../reports/report.txt
}
count_info() {
        echo "INFO: $(grep "INFO" $FILE | wc -l)" >> ../reports/report.txt
}
count_warn() {
        echo "WARN: $(grep "WARN" $FILE | wc -l)" >> ../reports/report.txt
}

echo "Logs Analize" > ../reports/report.txt
for file in ../logs/*.log
do
        FILE=$file
        echo "$(basename $file | cut -d '/' -f3):" >> ../reports/report.txt
        echo "All lines: $(wc -l < "$file")" >> ../reports/report.txt
	count_info
        count_warn
	count_error

done
