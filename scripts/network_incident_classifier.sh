#!/bin/bash

UNEXPECTED_PORTS=$(./external_port_exposure_audit.sh | grep "TOTAL" | awk '{print $5}' | head -n1)
SUSPICIOUS_CONN=$(./suspicious_remote_connection_audit.sh | grep "TOTAL" | awk '{print $5}' | head -n1)

CPU_LOAD=$(ps -eo %cpu --no-headers | awk '{sum+=$1} END {print int(sum)}')
[[ ${CPU_LOAD:-0} -gt 50 ]] && CPU_STATUS="ACTIVE" || CPU_STATUS="INACTIVE"

LOG_ERRORS=$(cat ../logs/*.log 2>/dev/null | grep -c "ERROR" || echo 0)
[[ ${LOG_ERRORS:-0} -gt 0 ]] && LOG_STATUS="ACTIVE" || LOG_STATUS="INACTIVE"

[[ ${UNEXPECTED_PORTS:-0} -gt 0 ]] && PORT_STATUS="ACTIVE" || PORT_STATUS="INACTIVE"
[[ ${SUSPICIOUS_CONN:-0} -gt 0 ]] && CONN_STATUS="ACTIVE" || CONN_STATUS="INACTIVE"

ACTIVE_COUNT=0
[[ "$PORT_STATUS" == "ACTIVE" ]] && ((ACTIVE_COUNT++))
[[ "$CONN_STATUS" == "ACTIVE" ]] && ((ACTIVE_COUNT++))
[[ "$CPU_STATUS" == "ACTIVE" ]] && ((ACTIVE_COUNT++))
[[ "$LOG_STATUS" == "ACTIVE" ]] && ((ACTIVE_COUNT++))

if [ $ACTIVE_COUNT -eq 0 ]; then
    CLASS="NORMAL"
elif [ $ACTIVE_COUNT -eq 1 ]; then
    CLASS="WARNING"
else
    CLASS="CRITICAL"
fi

echo "=== INCIDENT CLASSIFICATION ==="
echo "Unexpected Exposed Ports: $PORT_STATUS"
echo "Suspicious Connections:   $CONN_STATUS"
echo "High CPU Process:         $CPU_STATUS"
echo "Log Anomalies:            $LOG_STATUS"
echo "-------------------------------"
echo "TOTAL ACTIVE CATEGORIES:  $ACTIVE_COUNT"
echo "FINAL CLASSIFICATION:     $CLASS"
