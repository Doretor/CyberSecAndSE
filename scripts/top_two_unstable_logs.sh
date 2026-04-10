#!/bin/bash

tmp_file=$(mktemp)

for file in ../logs/*.log; do
    count=$(grep -c "ERROR" "$file")
    filename=$(basename "$file")
    echo "$count $filename" >> "$tmp_file"
done

echo "Top two most unstable logs:"
sort -nr "$tmp_file" | head -n 2

rm "$tmp_file"
