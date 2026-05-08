#!/bin/bash
USER_NAME=$1
ROLE=$2
CMD=$3
REQUEST_ID=$4 
PORT=7005
HOST="127.0.0.1"

case "$USER_NAME" in
    alice) TOKEN="token-alice-123" ;;
    bob) TOKEN="token-bob-999" ;;
    *) TOKEN="unknown" ;;
esac

TS=$(date -Iseconds)
COMMAND_ID="CMD-$(date +%Y%m%d%H%M%S)-$RANDOM"

if [ -n "$REQUEST_ID" ]; then
    DATA="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;REQUEST_ID=$REQUEST_ID;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TS"
else
    DATA="USER=$USER_NAME;ROLE=$ROLE;CMD=$CMD;COMMAND_ID=$COMMAND_ID;TIMESTAMP=$TS"
fi

AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$TOKEN" | cut -d' ' -f2)
MESSAGE="$DATA;AUTH=$AUTH"

echo "Sending securely via TLS: $MESSAGE"
echo "$MESSAGE" | openssl s_client -quiet -connect "$HOST:$PORT"
