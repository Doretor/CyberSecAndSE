#!/bin/bash

echo "Performing listening service audit..."
COUNT=0

LINES=$(sudo ss -tunlpH 2>/dev/null)

while read -r line; do
    [ -z "$line" ] && continue

    proto=$(echo "$line" | awk '{print $1}')
    local_addr=$(echo "$line" | awk '{print $5}')

    proc_info=$(echo "$line" | grep -o 'users:(.*)')
    if [ -n "$proc_info" ]; then
        proc_name=$(echo "$proc_info" | cut -d'"' -f2)
        pid=$(echo "$proc_info" | grep -oE 'pid=[0-9]+' | cut -d'=' -f2)
    else
        proc_name="unknown"
        pid="unknown"
    fi

    echo "LISTENING SERVICE: $proto $local_addr $proc_name $pid"
    COUNT=$((COUNT + 1))
done <<< "$LINES"

if [ "$COUNT" -eq 0 ]; then
    echo "NO LISTENING SERVICES DETECTED"
else
    echo "TOTAL LISTENING SERVICES: $COUNT"
fi
