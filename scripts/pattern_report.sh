#!/bin/bash

if [ -z "$1" ]
then
        echo "Missing argument: search pattern"
        exit -1
fi

FILE=""
PATT=$1

count_patt() {
        echo "$PATT: $(grep $PATT $FILE | wc -l)" >> ../reports/pattern_report.txt
}

echo "Logs Analize" > ../reports/pattern_report.txt
for file in ../logs/*.log
do
        FILE=$file
        echo "$(basename $file | cut -d '/' -f3):" >> ../reports/pattern_report.txt
        count_patt

done
