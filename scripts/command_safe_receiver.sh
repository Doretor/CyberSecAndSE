#!/bin/bash
PORT=6005
LOG_FILE="../reports/command_safety_gate.log"
USER_DB="../credentials/user_db.txt"
STATE_FILE="../reports/processed_commands.db"
PENDING_FILE="../reports/pending_commands.db"

touch "$LOG_FILE"
touch "$STATE_FILE"
touch "$PENDING_FILE"

echo "Safety-Gated Receiver listening on port $PORT..."
while true; do
    nc -l -p $PORT | while read -r line; do
        if [ -z "$line" ]; then continue; fi
        
        USER=$(echo "$line" | grep -o 'USER=[^;]*' | cut -d= -f2)
        ROLE=$(echo "$line" | grep -o 'ROLE=[^;]*' | cut -d= -f2)
        CMD=$(echo "$line" | grep -o 'CMD=[^;]*' | cut -d= -f2)
        COMMAND_ID=$(echo "$line" | grep -o 'COMMAND_ID=[^;]*' | cut -d= -f2)
        TIMESTAMP=$(echo "$line" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
        RECEIVED_AUTH=$(echo "$line" | grep -o 'AUTH=[^;]*' | cut -d= -f2)
        REQUEST_ID_IN_MSG=$(echo "$line" | grep -o 'REQUEST_ID=[^;]*' | cut -d= -f2)
        
        ENTRY=$(grep "^$USER:" "$USER_DB")
        if [ -z "$ENTRY" ]; then continue; fi
        DB_ROLE=$(echo "$ENTRY" | cut -d: -f2)
        DB_TOKEN=$(echo "$ENTRY" | cut -d: -f3)
        
        if [ "$ROLE" != "$DB_ROLE" ]; then continue; fi

        if [ -n "$REQUEST_ID_IN_MSG" ]; then
            DATA="USER=$USER;ROLE=$ROLE;CMD=$CMD;REQUEST_ID=$REQUEST_ID_IN_MSG;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TIMESTAMP"
        else
            DATA="USER=$USER;ROLE=$ROLE;CMD=$CMD;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TIMESTAMP"
        fi
        
        EXPECTED_AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$DB_TOKEN" | cut -d' ' -f2)
        if [ "$RECEIVED_AUTH" != "$EXPECTED_AUTH" ]; then continue; fi

        if grep -q "^$COMMAND_ID$" "$STATE_FILE"; then continue; fi
        echo "$COMMAND_ID" >> "$STATE_FILE"

        if [[ "$ROLE" == "operator" ]]; then
            if [[ "$CMD" == "SET_MODE_NOMINAL" || "$CMD" == "SET_MODE_SAFE" ]]; then
                echo "[ACTION] Switching satellite mode to ${CMD#SET_MODE_}"
                echo "[ACCEPTED] $line" >> "$LOG_FILE"
            else
                echo "[REJECTED] FORBIDDEN COMMAND: $CMD"
            fi
        elif [[ "$ROLE" == "admin" ]]; then
            
            if [ "$CMD" = "CONFIRM" ]; then
                PENDING_ENTRY=$(grep "^$REQUEST_ID_IN_MSG:" "$PENDING_FILE")
                if [ -z "$PENDING_ENTRY" ]; then
                    echo "[REJECTED] UNKNOWN REQUEST_ID=$REQUEST_ID_IN_MSG"
                    continue
                fi
                STORED_CMD=$(echo "$PENDING_ENTRY" | cut -d: -f4)
                echo "[ACTION] CONFIRMED. Executing critical command: $STORED_CMD"
                grep -v "^$REQUEST_ID_IN_MSG:" "$PENDING_FILE" > temp.db && mv temp.db "$PENDING_FILE"
                continue
            fi

            if [ "$CMD" = "RESET" ] || [ "$CMD" = "SHUTDOWN" ]; then
                REQUEST_ID="REQ-$(date +%Y%m%d%H%M%S)-$RANDOM"
                echo "$REQUEST_ID:$USER:$ROLE:$CMD" >> "$PENDING_FILE"
                echo "[PENDING] CRITICAL COMMAND REQUIRES CONFIRMATION REQUEST_ID=$REQUEST_ID"
                echo "[PENDING] USER=$USER ROLE=$ROLE CMD=$CMD REQUEST_ID=$REQUEST_ID" >> "$LOG_FILE"
                continue
            fi

            echo "[ACTION] Executing standard admin command: $CMD"
        fi
    done
done
