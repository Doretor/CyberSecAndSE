#!/bin/bash
export LC_ALL=C
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="../reports/mission_runtime_security_report_${TIMESTAMP}.txt"

LOG_COUNT=0
TOT_ERR=0
MAX_ERR=-1
WORST_LOG=""

shopt -s nullglob
for f in ../logs/*.log; do
    LOG_COUNT=$((LOG_COUNT + 1))
    err=$(grep -c "ERROR" "$f" | tr -d '\r')
    err=${err:-0}
    TOT_ERR=$((TOT_ERR + err))
    if [ "$err" -gt "$MAX_ERR" ]; then
        MAX_ERR=$err
        WORST_LOG=$(basename "$f")
    fi
done

ACT_PROC=$(ps -e --no-headers | wc -l)
HIGH_CPU=$(ps -eo %cpu --no-headers | awk '{if($1+0>50) count++} END {print count+0}')
TOP_PROC=$(ps -eo comm --sort=-%cpu | awk 'NR==2 {print $1}')

WHITELIST="bash sleep ps grep awk incident_classi mission_runtime systemd kworker rcu_preempt"
UNAUTH=0
while read -r comm; do
    comm=$(echo "$comm" | xargs)
    if [[ ! " $WHITELIST " == *" $comm "* ]]; then
        UNAUTH=$((UNAUTH + 1))
    fi
done < <(ps -eo comm --no-headers)

STATUS=$(./incident_classifier.sh 50 10)

cat <<EOF > "$FILE"
MISSION RUNTIME SECURITY REPORT
Generated at: $TIMESTAMP
Processed log files: $LOG_COUNT
Active processes: $ACT_PROC
Unauthorized processes: $UNAUTH
High CPU processes: $HIGH_CPU
ERROR entries: $TOT_ERR
Most unstable log: $WORST_LOG
Top CPU process: $TOP_PROC
Incident classification: $STATUS
EOF

echo "Final report generated at: $FILE"
cat "$FILE"
