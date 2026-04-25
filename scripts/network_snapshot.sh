#!/bin/bash

TS=$(date "+%Y-%m-%d %H:%M:%S")

LISTEN=$(./listening_service_audit.sh | grep "TOTAL" | awk '{print $4}' | tail -n1)
ESTAB=$(./established_connection_audit.sh | grep "TOTAL" | awk '{print $4}' | tail -n1)
EXPOSED=$(./external_port_exposure_audit.sh | grep "TOTAL" | awk '{print $5}' | tail -n1)
SUSPICIOUS=$(./suspicious_remote_connection_audit.sh | grep "TOTAL" | awk '{print $5}' | tail -n1)

CLASS=$(./network_incident_classifier.sh | grep "FINAL CLASSIFICATION" | awk '{print $3}' | tail -n1)

TOP_PROC_INFO=$(sudo ss -tnp state established 2>/dev/null | grep -oP 'users:\(\("\K[^"]+' | sort | uniq -c | sort -nr | head -n1)

if [ -n "$TOP_PROC_INFO" ]; then
    TOP_COUNT=$(echo "$TOP_PROC_INFO" | awk '{print $1}')
    TOP_NAME=$(echo "$TOP_PROC_INFO" | awk '{print $2}')
    TOP_PID=$(pgrep -f "$TOP_NAME" | head -n1)
    TOP_DISPLAY="${TOP_NAME}/${TOP_PID:-unknown} (${TOP_COUNT})"
else
    TOP_DISPLAY="None"
fi

cat <<EOF
=== NETWORK SNAPSHOT ===
TIME: $TS
LISTENING SERVICES: ${LISTEN:-0}
ESTABLISHED CONNECTIONS: ${ESTAB:-0}
UNEXPECTED EXPOSED PORTS: ${EXPOSED:-0}
SUSPICIOUS REMOTE CONNECTIONS: ${SUSPICIOUS:-0}
TOP PROCESS BY ESTABLISHED CONNECTIONS: $TOP_DISPLAY
CLASSIFICATION: $CLASS
EOF
