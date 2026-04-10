#!/bin/bash

echo "Logs without ERROR entries:"

for file in ../logs/*.log; do
    filename=$(basename "$file")
    error_count=$(grep -c "ERROR" "$file")
    
    if [ "$error_count" -eq 0 ]; then
        echo "$filename"
    fi
done
