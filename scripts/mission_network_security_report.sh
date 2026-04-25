#!/bin/bash

TS=$(date "+%Y-%m-%d %H:%M:%S")
FILE_TS=$(date "+%Y-%m-%d-%H-%M-%S")
REPORT_PATH="../reports/mission_network_security_report-$FILE_TS.txt"

LISTEN=$(./listening_service_audit.sh | grep "TOTAL" | awk '{print $4}' | tail -n1)
ESTAB=$(./established_connection_audit.sh | grep "TOTAL" | awk '{print $4}' | tail -n1)
EXPOSED=$(./external_port_exposure_audit.sh | grep "TOTAL" | awk '{print $5}' | tail -n1)
SUSPICIOUS=$(./suspicious_remote_connection_audit.sh | grep "TOTAL" | awk '{print $5}' | tail -n1)

TOP_PROC_RAW=$(sudo ss -tnp state established 2>/dev/null | grep -oP 'users:\(\("\K[^"]+' | sort | uniq -c | sort -nr | head -n1)

if [ -n "$TOP_PROC_RAW" ]; then
    TOP_COUNT=$(echo "$TOP_PROC_RAW" | awk '{print $1}')
    TOP_NAME=$(echo "$TOP_PROC_RAW" | awk '{print $2}')
    TOP_PID=$(pgrep -x "$TOP_NAME" | head -n1)
    TOP_DISPLAY="${TOP_NAME}/${TOP_PID:-unknown} ($TOP_COUNT)"
else
    TOP_DISPLAY="None"
fi

HIGH_CPU_COUNT=$(ps -eo %cpu --no-headers | awk '$1 > 50 {c++} END {print c+0}')
LOG_ERRORS=$(cat ../logs/*.log 2>/dev/null | grep -c "ERROR" || echo 0)

CLASS=$(./network_incident_classifier.sh | grep "FINAL CLASSIFICATION" | awk '{print $3}' | tail -n1)

cat <<EOF > "$REPORT_PATH"
=== MISSION NETWORK SECURITY REPORT ===
TIME: $TS

[NETWORK STATE]
LISTENING SERVICES: ${LISTEN:-0}
ESTABLISHED CONNECTIONS: ${ESTAB:-0}
UNEXPECTED EXPOSED PORTS: ${EXPOSED:-0}
SUSPICIOUS REMOTE CONNECTIONS: ${SUSPICIOUS:-0}
TOP PROCESS BY ESTABLISHED CONNECTIONS: $TOP_DISPLAY

[RUNTIME AND LOGS]
HIGH CPU PROCESSES: $HIGH_CPU_COUNT
TOTAL LOG ERRORS: $LOG_ERRORS

[CLASSIFICATION]
FINAL CLASSIFICATION: $CLASS

[COMPARISON]
System evaluated with network simulation active. 
Detected $SUSPICIOUS suspicious remote connections and $EXPOSED unexpected exposed ports.
The system state is currently: $CLASS.
EOF

echo "Full report generated at: $REPORT_PATH"
cat "$REPORT_PATH"
