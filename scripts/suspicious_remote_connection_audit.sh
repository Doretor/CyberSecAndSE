#!/bin/bash

echo "Checking for suspicious remote connections..."
COUNT=0
LINES=$(sudo ss -tnpH state established 2>/dev/null)

while read -r line; do
    [ -z "$line" ] && continue

    remote_ep=$(echo "$line" | awk '{print $(NF-1)}')
    remote_ip=$(echo "$remote_ep" | rev | cut -d':' -f2- | rev | tr -d '[]')

    if [[ -n "$remote_ip" && "$remote_ip" != "127.0.0.1" && "$remote_ip" != "::1" ]]; then
        proc_info=$(echo "$line" | awk '{print $NF}')

        if [[ "$proc_info" == *"users:"* ]]; then
            pname=$(echo "$proc_info" | cut -d'"' -f2)
            pid=$(echo "$proc_info" | cut -d'=' -f2 | cut -d',' -f1)
        else
            pname="unknown"
            pid="unknown"
        fi

        echo "SUSPICIOUS CONNECTION: ${pname} ${pid} -> $remote_ep"
        COUNT=$((COUNT + 1))
    fi
done <<< "$LINES"

if [ "$COUNT" -eq 0 ]; then
    echo "NO SUSPICIOUS REMOTE CONNECTIONS DETECTED"
else
    echo "TOTAL SUSPICIOUS REMOTE CONNECTIONS: $COUNT"
fi
