#!/bin/bash
export LC_NUMERIC=C

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./incident_classifier.sh <CPU_THRESHOLD> <ERROR_THRESHOLD>"
    exit 1
fi

CPU_THRESH="$1"
ERR_THRESH="$2"
WHITELIST="bash sleep ps awk grep incident_classi systemd kworker"

indicators=0

cpu_anomaly=$(ps -eo %cpu --no-headers | awk -v ct="$CPU_THRESH" '$1 > ct {print 1; exit}')
if [ "$cpu_anomaly" == "1" ]; then
    indicators=$((indicators + 1))
fi


unauth_found=0
while read -r comm; do
    if ! echo "$WHITELIST" | grep -qw "$comm"; then
        unauth_found=1
        break
    fi
done < <(ps -eo comm --no-headers)

if [ "$unauth_found" == "1" ]; then
    indicators=$((indicators + 1))
fi

log_anomaly=0
for file in ../logs/*.log; do
    errors=$(grep -c "ERROR" "$file")
    if [ "$errors" -gt "$ERR_THRESH" ]; then
        log_anomaly=1
        break
    fi
done

if [ "$log_anomaly" == "1" ]; then
    indicators=$((indicators + 1))
fi


if [ "$indicators" -eq 0 ]; then
    echo "NORMAL"
elif [ "$indicators" -eq 1 ]; then
    echo "WARNING"
else
    echo "CRITICAL"
fi
