#!/bin/bash

echo "Performing established connection audit..."
COUNT=0
LINES=$(sudo ss -tnpH state established 2>/dev/null)

while read -r line; do
    [ -z "$line" ] && continue

    local_ep=$(echo "$line" | awk '{print $(NF-2)}')
    remote_ep=$(echo "$line" | awk '{print $(NF-1)}')
    proc_info=$(echo "$line" | awk '{print $NF}')

    if [[ "$proc_info" == *"users:"* ]]; then
        pname=$(echo "$proc_info" | cut -d'"' -f2)
        pid=$(echo "$proc_info" | cut -d'=' -f2 | cut -d',' -f1)
    else
        pname="unknown"
        pid="unknown"
    fi

    echo "ESTABLISHED CONNECTION: $local_ep -> $remote_ep ${pname} ${pid}"
    COUNT=$((COUNT + 1))
done <<< "$LINES"

if [ "$COUNT" -eq 0 ]; then
    echo "NO ESTABLISHED CONNECTIONS DETECTED"
else
    echo "TOTAL ESTABLISHED CONNECTIONS: $COUNT"
fi
