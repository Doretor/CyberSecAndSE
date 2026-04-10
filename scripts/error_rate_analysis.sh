#!/bin/bash

export LC_NUMERIC=C

highest_rate=0
worst_sat=""

for file in ../logs/*.log; do
    filename=$(basename "$file")
    total=$(wc -l < "$file")
    errors=$(grep -c "ERROR" "$file")
    if [ "$total" -gt 0 ]; then
        rate=$(awk -v e="$errors" -v t="$total" 'BEGIN {print e / t}')
        is_higher=$(awk -v r="$rate" -v h="$highest_rate" 'BEGIN {if (r > h) print 1; else print 0}')
        if [ "$is_higher" -eq 1 ]; then
            highest_rate=$rate
            worst_sat=$filename
        fi
    fi
done

echo "Satellite with highest relative error rate: $worst_sat (Rate: $highest_rate)"
