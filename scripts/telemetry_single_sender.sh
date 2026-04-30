#!/bin/bash

HOST="127.0.0.1"
PORT=5001
SAT_ID="sat-001"
SECRET_KEY="orion-shared-secret"

# Jeśli podasz czas przy uruchamianiu, skrypt go użyje. Jak nie, użyje obecnego.
if [ -n "$1" ]; then
    TS="$1"
else
    TS=$(date -Iseconds)
fi

VALUE=$((RANDOM % 100))
MESSAGE="SAT_ID=$SAT_ID;TIMESTAMP=$TS;VALUE=$VALUE"
SIGNATURE=$(printf "%s" "$MESSAGE" | openssl dgst -sha256 -hmac "$SECRET_KEY" | awk '{print $NF}')
SIGNED_MESSAGE="$MESSAGE;SIGNATURE=$SIGNATURE"

echo "=== WYSYŁANIE WIADOMOŚCI ==="
echo "$SIGNED_MESSAGE"
echo "$SIGNED_MESSAGE" | nc -q 0 "$HOST" "$PORT"
