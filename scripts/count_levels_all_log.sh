#!/bin/bash
cat ../logs/* | grep -oE "(INFO|WARN|ERROR)" | sort | uniq -c > ../reports/level_summary.txt
