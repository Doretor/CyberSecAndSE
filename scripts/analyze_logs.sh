#!/bin/bash
TOTAL=$(cat ../logs/* | wc -l)
INFO=$(cat ../logs/* | grep -c "INFO")
WARN=$(cat ../logs/* | grep -c "WARN")
ERROR=$(cat ../logs/* | grep -c "ERROR")
WORST=$(grep -c "ERROR" ../logs/* | sort -t':' -k2 -nr | head -n 1 | cut -d':' -f1 | cut -d '/' -f3)

cat <<EOF > ../reports/log_summary.txt
ORION LOG SUMMARY
Total log entries: $TOTAL
INFO events: $INFO
WARN events: $WARN
ERROR events: $ERROR
Less stable satellite: $WORST
EOF
