#!/bin/bash

export LC_ALL=C

ps -eo pid,%cpu,%mem,comm --no-headers | awk -v ct=$1 -v mt=$2 '{
	if ($2 + 0 > ct + 0) {
		print "WARNING: suspicious CPU usage: "$4" (PID: "$1")"
	}
	if ($3 + 0 > mt + 0) {
		print "WARNING: suspicious memory usage: "$4" (PID: "$1")"
	}
}'

