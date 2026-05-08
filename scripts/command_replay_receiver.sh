#!/bin/bash
PORT=6004
LOG_FILE="../reports/command_replay_protection.log"
USER_DB="../credentials/user_db.txt"
STATE_FILE="../reports/processed_commands.db"

touch "$LOG_FILE"
touch "$STATE_FILE"

echo "Replay-Protected Receiver listening on port $PORT..."
while true; do
    nc -l -p $PORT | while read -r line; do
        if [ -z "$line" ]; then continue; fi
        
        USER=$(echo "$line" | grep -o 'USER=[^;]*' | cut -d= -f2)
        ROLE=$(echo "$line" | grep -o 'ROLE=[^;]*' | cut -d= -f2)
        CMD=$(echo "$line" | grep -o 'CMD=[^;]*' | cut -d= -f2)
        COMMAND_ID=$(echo "$line" | grep -o 'COMMAND_ID=[^;]*' | cut -d= -f2)
        TIMESTAMP=$(echo "$line" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
        RECEIVED_AUTH=$(echo "$line" | grep -o 'AUTH=[^;]*' | cut -d= -f2)
        
        ENTRY=$(grep "^$USER:" "$USER_DB")
        if [ -z "$ENTRY" ]; then continue; fi
        
        DB_ROLE=$(echo "$ENTRY" | cut -d: -f2)
        DB_TOKEN=$(echo "$ENTRY" | cut -d: -f3)
        
        if [ "$ROLE" != "$DB_ROLE" ]; then continue; fi

        DATA="USER=$USER;ROLE=$ROLE;CMD=$CMD;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TIMESTAMP"
        EXPECTED_AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$DB_TOKEN" | cut -d' ' -f2)
        
        if [ "$RECEIVED_AUTH" != "$EXPECTED_AUTH" ]; then continue; fi

        # Replay Detection
        if grep -q "^$COMMAND_ID$" "$STATE_FILE"; then
            echo "[REJECTED] REPLAY DETECTED: COMMAND_ID=$COMMAND_ID"
            echo "[REJECTED] REPLAY DETECTED: COMMAND_ID=$COMMAND_ID RAW=$line" >> "$LOG_FILE"
            continue
        fi
        
        echo "$COMMAND_ID" >> "$STATE_FILE"

        if [[ "$ROLE" == "operator" ]]; then
            if [[ "$CMD" == "SET_MODE_NOMINAL" || "$CMD" == "SET_MODE_SAFE" ]]; then
                echo "[AUTHORIZED] USER=$USER ROLE=$ROLE CMD=$CMD COMMAND_ID=$COMMAND_ID"
                echo "[ACTION] Switching satellite mode to ${CMD#SET_MODE_}"
                echo "[ACCEPTED] $line" >> "$LOG_FILE"
            else
                echo "[REJECTED] FORBIDDEN COMMAND: $CMD"
            fi
        elif [[ "$ROLE" == "admin" ]]; then
            echo "[AUTHORIZED] USER=$USER ROLE=$ROLE CMD=$CMD COMMAND_ID=$COMMAND_ID"
            echo "[ACTION] Executing: $CMD"
            echo "[ACCEPTED] $line" >> "$LOG_FILE"
        fi
    done
done
