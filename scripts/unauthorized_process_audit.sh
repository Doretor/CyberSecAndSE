#!/bin/bash

WHITELIST="bash sleep"

auth_c=0
unauth_c=0
echo "$WHITELIST"
while read -r pid comm; do

	comm=$(echo "$comm" | xargs)

	if [[ " $WHITELIST " == *" $comm "* ]]; then
		echo "AUTHORIZED PROCESS: "$comm" (PID: "$pid")"
		auth_c=$((auth_c+1))
	else
		echo "UNAUTHORIZED PROCESS: "$comm" (PID: "$pid")"
                unauth_c=$((unauth_c+1))
	fi
done < <(ps -eo pid,comm --no-headers)

echo "TOTAL AUTHORIZED: "$auth_c""
echo "TOTAL UNAUTHORIZED: "$unauth_c""
