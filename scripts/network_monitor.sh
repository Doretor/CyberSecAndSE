#!/bin/bash

INTERVAL=5
REPORT_FILE="../reports/network_monitoring_$(date +%Y%m%d_%H%M%S).log"

echo "Network Monitoring Started."
echo "Interval: ${INTERVAL}s"
echo "Logging to: $REPORT_FILE"
echo "Press [Ctrl+C] to stop..."

echo "=== NETWORK MONITORING LOG ===" >> "$REPORT_FILE"

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    LISTEN=$(./listening_service_audit.sh | grep "TOTAL" | awk '{print $4}' | tail -n1)
    ESTAB=$(./established_connection_audit.sh | grep "TOTAL" | awk '{print $4}' | tail -n1)
    EXPOSED=$(./external_port_exposure_audit.sh | grep "TOTAL" | awk '{print $5}' | tail -n1)
    SUSPICIOUS=$(./suspicious_remote_connection_audit.sh | grep "TOTAL" | awk '{print $5}' | tail -n1)

    CLASS=$(./network_incident_classifier.sh | grep "FINAL CLASSIFICATION" | awk '{print $3}' | tail -n1)

    LOG_LINE="$TIMESTAMP LISTEN=${LISTEN:-0} ESTAB=${ESTAB:-0} EXPOSED=${EXPOSED:-0} SUSPICIOUS=${SUSPICIOUS:-0} CLASS=${CLASS:-UNKNOWN}"

    echo "$LOG_LINE" | tee -a "$REPORT_FILE"

    sleep $INTERVAL
done
