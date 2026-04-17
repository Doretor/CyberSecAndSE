#!/bin/bash
echo "Monitoring for incident escalation..."
PREV_STATUS=$(./incident_classifier.sh 50 10)

while true; do
    sleep 3
    CURR_STATUS=$(./incident_classifier.sh 50 10)
    
    if [ "$PREV_STATUS" != "$CURR_STATUS" ]; then
        if [[ "$PREV_STATUS" == "NORMAL" && "$CURR_STATUS" == "WARNING" ]] || [[ "$PREV_STATUS" == "WARNING" && "$CURR_STATUS" == "CRITICAL" ]]; then
            echo -e "\nESCALATION DETECTED:"
            echo "Time: $(date +"%Y-%m-%d %H:%M:%S")"
            echo "From: $PREV_STATUS"
            echo "To: $CURR_STATUS"
            exit 0
        fi
        PREV_STATUS=$CURR_STATUS
    fi
done
