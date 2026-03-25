echo -e "sat-001 ERRORS: $(grep ERROR ../logs/sat-001.log | wc -l)"
echo -e "sat-002 ERRORS: $(grep ERROR ../logs/sat-002.log | wc -l)"
echo -e "all ERRORS: $(grep ERROR ../logs/*.log | wc -l)"
echo -e "\nERRORS messages:\n$(grep ERROR ../logs/*.log)"
