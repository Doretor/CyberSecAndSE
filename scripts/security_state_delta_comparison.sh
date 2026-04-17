#!/bin/bash
export LC_ALL=C
WHITELIST="bash sleep ps grep awk incident_classi security_state systemd kworker rcu_preempt"

get_unauth() {
    local count=0
    while read -r comm; do
        comm=$(echo "$comm" | xargs)
        if [[ ! " $WHITELIST " == *" $comm "* ]]; then
            count=$((count + 1))
        fi
    done < <(ps -eo comm --no-headers)
    echo "$count"
}

echo "Taking snapshot 1..."
S1_TOP=$(ps -eo comm --sort=-%cpu | awk 'NR==2 {print $1}')
S1_UNAUTH=$(get_unauth)
S1_STAT=$(./incident_classifier.sh 50 10)

echo "Waiting 5 seconds..."
sleep 5

echo "Taking snapshot 2..."
S2_TOP=$(ps -eo comm --sort=-%cpu | awk 'NR==2 {print $1}')
S2_UNAUTH=$(get_unauth)
S2_STAT=$(./incident_classifier.sh 50 10)

echo -e "\nSTATE CHANGE DETECTED:"
if [ "$S1_TOP" == "$S2_TOP" ]; then echo "Top CPU process changed: NO"; else echo "Top CPU process changed: YES ($S1_TOP -> $S2_TOP)"; fi
if [ "$S1_UNAUTH" == "$S2_UNAUTH" ]; then echo "Unauthorized process count changed: NO"; else echo "Unauthorized process count changed: YES ($S1_UNAUTH -> $S2_UNAUTH)"; fi
if [ "$S1_STAT" == "$S2_STAT" ]; then echo "Incident classification changed: NO"; else echo "Incident classification changed: $S1_STAT -> $S2_STAT"; fi
