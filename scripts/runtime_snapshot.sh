#!/bin/bash
export LC_ALL=C
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILE="../reports/runtime_snapshot_${TIMESTAMP}.txt"

TOT_PROC=$(ps -e --no-headers | wc -l)
TOP_PROC=$(ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==2 {print "PID="$1" PROC="$2" CPU="$3"%"}')

WHITELIST="bash sleep ps grep awk incident_classi runtime_snapshot systemd kworker rcu_preempt"
UNAUTH=0
while read -r comm; do
    comm=$(echo "$comm" | xargs)
    if [[ ! " $WHITELIST " == *" $comm "* ]]; then
        UNAUTH=$((UNAUTH + 1))
    fi
done < <(ps -eo comm --no-headers)

TOT_ERR=0
shopt -s nullglob
for f in ../logs/*.log; do
    err=$(grep -c "ERROR" "$f" | tr -d '\r')
    TOT_ERR=$((TOT_ERR + ${err:-0}))
done

STATUS=$(./incident_classifier.sh 50 10)

cat <<EOF > "$FILE"
========================================
Runtime Security Snapshot
========================================
Date and time: $(date +"%Y-%m-%d %H:%M:%S")
Total active processes: $TOT_PROC
Top CPU process: $TOP_PROC
Unauthorized processes: $UNAUTH
Total ERROR entries across all logs: $TOT_ERR
Incident classification: $STATUS
========================================
EOF
echo "Snapshot saved to $FILE"
