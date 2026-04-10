#!/bin/bash

echo "Messages appearing in more than one log file:"

cat ../logs/*.log | awk '{$1=""; $2=""; $3=""; print $0}' | sort | uniq -c | awk '$1 > 1 {print $0}'
