#!/bin/bash

PORT=5001
SECRET_KEY="orion-shared-secret"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/../reports"
LOG_FILE="$REPORT_DIR/telemetry_insecure.log"
STATE_FILE="../reports/last_timestamp.db"

touch "$STATE_FILE"

echo "$LOG_FILE"
mkdir -p "$REPORT_DIR"
touch "$LOG_FILE"

echo "=== TELEMETRY RECEIVER STARTED ==="
echo "Listening on port $PORT"
echo "Logging to $LOG_FILE"
echo ""

while true; do
	nc -l 127.0.0.1 "$PORT" | while IFS= read -r line; do
        DATA=$(echo "$line" | sed 's/;SIGNATURE=.*//')
	RECEIVED_SIGNATURE=$(echo "$line" | sed 's/.*;SIGNATURE=//')
	TS=$(date -Iseconds)
	EXPECTED_SIGNATURE=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$SECRET_KEY" | cut -d ' ' -f2)
	
	TIMESTAMP=$(echo "$DATA" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
	SAT_ID=$(echo "$DATA" | grep -o 'SAT_ID=[^;]*' | cut -d= -f2)
	LAST_TS=$(grep "^$SAT_ID=" "$STATE_FILE" | cut -d= -f2)

	if [ -n "$LAST_TS" ] && [[ "$TIMESTAMP" <= "$LAST_TS" ]]; then
		echo "[REJECTED] REPLAY DETECTED: $DATA"
		continue
	fi

	if [ "$RECEIVED_SIGNATURE" = "$EXPECTED_SIGNATURE" ]; then
		echo "[ACCEPTED $TS] $DATA"
		echo "[ACCEPTED $TS] $DATA" >> "$LOG_FILE"
		TMP_FILE=$(mktemp)
		grep -v "^$SAT_ID=" "$STATE_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
		echo "$SAT_ID=$TIMESTAMP" >> "$STATE_FILE"
	else
		echo "[REJECTED $TS] INVALID SIGNATURE: $line"
		echo "[REJECTED $TS] INVALID SIGNATURE: $line" >> "$LOG_FILE"
	fi

        done
done
