#!/bin/bash

while read -r line; do

#	[-z "$line"] && continue

	prot=$(echo "$line" | awk '{print $1}')
	local_addr=$(echo "$line" | awk '{print $5}')
	proc_info=$(echo "$line" | grep -o 'users:(.*)' || echo "")

	if [ -n "$proc_info"]; then
		proc_name=$(echo "$proc_info" | grep -Po '"\K[^"]*')
		pid=$(echo "$proc_info" | grep -Po 'pid=\K[0-9]*')
	else
		proc_name="unknown"
		pid="unknown"
	fi
	echo "LISTENING SERVICE: $prot $local_addr $proc_name $pid"
	COUNT=$((COUNT + 1))

done <<< "$(ss -tunlp --no-header)"

if [ "$COUNT" -eq 0 ]; then
	echo "NO LISTENING SERVICES DETECTED"
else
	echo "TOTAL LISTENING SERVICES: $COUNT"
fi



