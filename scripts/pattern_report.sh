#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument: search pattern (e.g. INFO, WARN, ERROR)"
    exit 1
fi

PATT="$1"
REPORT_FILE="../reports/pattern_report.txt"

echo "PATTERN REPORT: $PATT" > "$REPORT_FILE"

for file in ../logs/*.log; do
    filename=$(basename "$file")
    count=$(grep "$PATT" "$file" | wc -l)
    echo "$filename: $count" >> "$REPORT_FILE"
done
