#!/bin/bash

max_count=-1
noisiest_sat=""

for file in ../logs/*.log; do
    filename=$(basename "$file")

    count=$(grep -E "WARN|ERROR" "$file" | wc -l)

    if [ "$count" -gt "$max_count" ]; then
        max_count=$count
        noisiest_sat=$filename
    fi
done

echo "The noisiest satellite is $noisiest_sat with $max_count non-INFO events."
