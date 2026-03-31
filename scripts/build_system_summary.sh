#!/bin/bash
echo "Total log entries: $(cat ../logs/* | wc -l)" > ../reports/system_summary.txt
echo "Total ERROR events: $(cat ../logs/* | grep -c "ERROR")" >> ../reports/system_summary.txt
echo "Total WARN events: $(cat ../logs/* | grep -c "WARN")" >> ../reports/system_summary.txt
echo "Total INFO events: $(cat ../logs/* | grep -c "INFO")" >> ../reports/system_summary.txt
