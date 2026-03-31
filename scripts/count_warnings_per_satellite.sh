
MAX_WARN=-1
MAX_SAT=""

for PLIK in "../logs/"*.log; do
	SAT=$(basename "$PLIK")
	L_WARN=$(grep "WARN" "$PLIK" | wc -l)
	echo "$SAT WARNS: $L_WARN"
	if [ "$L_WARN" -gt "$MAX_WARN" ]; then
		MAX_WARN=$L_WARN
		MAX_SAT="$SAT"
	fi
done
echo -e "\nThe most WARN has: $MAX_SAT"
