#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing argument: file pattern"
    exit 1
fi

total_files=0
total_entries=0
total_info=0
total_warn=0
total_error=0

max_errors=-1
unstable_log=""

for file in $1; do
    if [ -f "$file" ]; then
        total_files=$((total_files + 1))
        
        entries=$(wc -l < "$file")
        total_entries=$((total_entries + entries))
        
        info=$(grep -c "INFO" "$file")
        total_info=$((total_info + info))
        
        warn=$(grep -c "WARN" "$file")
        total_warn=$((total_warn + warn))
        
        error=$(grep -c "ERROR" "$file")
        total_error=$((total_error + error))
        
        if [ "$error" -gt "$max_errors" ]; then
            max_errors=$error
            unstable_log=$(basename "$file")
        fi
    fi
done

REPORT_FILE="../reports/mission_report.txt"

cat <<EOF > "$REPORT_FILE"
MISSION REPORT
Processed files: $total_files
Total entries: $total_entries
INFO: $total_info
WARN: $total_warn
ERROR: $total_error
Most unstable log: $unstable_log
EOF

echo "Mission report generated at $REPORT_FILE"
