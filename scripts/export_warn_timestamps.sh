grep WARN ../logs/*.log > ../reports/warn_timestamps.txt
cut -d ":" -f 2,3,4 ../reports/warn_timestamps.txt > temp.txt
cut -d " " -f 1,2 ./temp.txt > ../reports/warn_timestamps.txt
rm temp.txt
