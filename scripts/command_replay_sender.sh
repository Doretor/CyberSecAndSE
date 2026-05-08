#!/bin/bash
USER_NAME=$1
ROLE=$2
CMD=$3
PORT=6004
HOST="127.0.0.1"

# Lookup token based on user
case "$USER_NAME" in
    alice) TOKEN="token-alice-123" ;;
    bob) TOKEN="token-bob-999" ;;
    *) TOKEN="unknown" ;;
esac

TS=$(date -Iseconds)
# Generate a unique command identifier
COMMAND_ID="CMD-$(date +%Y%m%d%H%M%S)-$RANDOM"

# 1. Create the data string to be authenticated (now including COMMAND_ID)
DATA="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TS"

# 2. Compute the HMAC signature
AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$TOKEN" | cut -d' ' -f2)

# 3. Create the final message
MESSAGE="$DATA;AUTH=$AUTH"

echo "Sending: $MESSAGE"
echo "$MESSAGE" | nc -q 0 "$HOST" "$PORT"
