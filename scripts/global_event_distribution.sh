#!/bin/bash

echo "Global Event Distribution Summary:"

cat ../logs/*.log | awk '{print $3}' | tr -d '[]' | sort | uniq -c | sort -nr
