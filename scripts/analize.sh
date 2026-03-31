#!/bin/bash

if [ -z "$1" ]
then
	echo "Missing argument: path"
	exit -1
fi

if [ -z "$2" ]
then
	echo "Missing argument: search pattern"
	exit -1
fi

FILE=$1
PATT=$2

echo "All files contains $(cat ../logs/*.log | wc -l) lines"
echo "All files contains $(grep "$PATT" ../logs/*.log | wc -l)"
echo "File contains $(wc -l < "$FILE") lines" 
echo "File contains $(grep "$PATT" "$FILE" | wc -l) lines with "$PATT" message"

