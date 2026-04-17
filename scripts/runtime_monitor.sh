#!/bin/bash
export LC_ALL=C
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REP_FILE="../reports/runtime_monitor_${TIMESTAMP}.txt"

echo "Starting monitoring loop..."
echo "Interval: 5s"
echo "Output: $REP_FILE"
echo "Press Ctrl+C to stop."
echo "----------------------------------------"
echo "===== Monitoring started: $(date +"%Y-%m-%d %H:%M:%S") =====" > "$REP_FILE"

while true; do
    NOW=$(date +"%Y-%m-%d %H:%M:%S")

    TOP_PROC=$(ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==2 {print $2 " (PID="$1", CPU="$3"%)"}')

    WHITELIST="bash sleep ps grep awk systemd kworker rcu_preempt"
    UNAUTH=0
    while read -r comm; do
        comm=$(echo "$comm" | xargs)
        if [[ ! " $WHITELIST " == *" $comm "* ]]; then
            UNAUTH=$((UNAUTH + 1))
        fi
    done < <(ps -eo comm --no-headers)

    LOG_ANOM="NO"
    for file in ../logs/*.log; do
        if [ "$(grep -c "ERROR" "$file")" -gt 10 ]; then LOG_ANOM="YES"; break; fi
    done

    STATUS=$(./incident_classifier.sh 50 10)

    LOG_LINE="[$NOW] TOP_CPU: $TOP_PROC | UNAUTHORIZED: $UNAUTH | LOG_ANOMALY: $LOG_ANOM | STATUS: $STATUS"

    echo "$LOG_LINE"
    echo "$LOG_LINE" >> "$REP_FILE"

    sleep 5
done
