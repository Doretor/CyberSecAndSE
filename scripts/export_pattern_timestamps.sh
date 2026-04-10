#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument: search pattern"
    exit 1
fi

PATT="$1"
REPORT_FILE="../reports/pattern_timestamps.txt"

> "$REPORT_FILE"

for file in ../logs/*.log; do
    grep "$PATT" "$file" | awk '{print $1, $2}' >> "$REPORT_FILE"
done
