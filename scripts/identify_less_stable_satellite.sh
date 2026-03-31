#!/bin/bash
grep -c "ERROR" ../logs/* | sort -t':' -k2 -nr | head -n 1 | cut -d':' -f1 | cut -d '/' -f3
