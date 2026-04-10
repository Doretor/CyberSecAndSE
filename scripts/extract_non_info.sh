#!/bin/bash

grep -v "INFO" ../logs/*.log > ../reports/non_info_events.txt

count=$(wc -l < ../reports/non_info_events.txt)
echo "Total non-INFO entries found: $count"
