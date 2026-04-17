#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <ERROR_THRESHOLD>"
    exit 1
fi

threshold="$1"
max_errors=-1
worst_log=""

for file in ../logs/*.log; do
    filename=$(basename "$file")
    errors=$(grep -c "ERROR" "$file")

    echo "$filename: $errors ERROR entries"

    if [ "$errors" -gt "$threshold" ]; then
        echo "ALERT: log anomaly detected in $filename"
    fi
 
    if [ "$errors" -gt "$max_errors" ]; then
        max_errors=$errors
        worst_log=$filename
    fi
done

echo "Most unstable log file: $worst_log ($max_errors ERROR entries)"
