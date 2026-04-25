#!/bin/bash

EXP_PORTS=" 5000 6000 "
UNEXP_COUNT=0

OPEN_PORTS=$(nmap -n -p- -sT 127.0.0.1 | grep '^[0-9]' | grep 'open' | awk -F/ '{print $1}')
for port in $OPEN_PORTS; do
	if ! echo "$EXP_PORTS" | grep -qw "$port"; then
		echo "EXPOSED PORT: $port"
		UNEXP_COUNT=$((UNEXP_COUNT + 1))
	fi
done
if [ "$UNEXP_COUNT" -eq 0 ]; then
	echo "NO UNEXPECTED EXPOSED PORTS"
else
	echo "TOTAL UNEXPECTED EXPOSED PORTS: $UNEXP_COUNT"
fi
