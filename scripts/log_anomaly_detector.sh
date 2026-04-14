#!/bin/bash

max_errors=-1
worst_log=""

for file in ../logs/*.log; do
	filename=$(basename "$file")
	errors=$(grep -c "ERROR" "$file")

	echo "$filename: $errors ERORR entries"

	if [ "$errors" -gt "$1" ]; then
		echo "ALERT: log anomaly detected in $filename"
	fi

	if [ "$errors" -gt "$max_errors" ]; then
		max_errors="$errors"
		worst_log="$filename"
	fi
done
if [ "$max_errors" -ge 0 ]; then
	echo "Most unstable log file: $worst_log  ($max_errors ERROR entries)"
fi
