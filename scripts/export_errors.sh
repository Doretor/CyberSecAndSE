#!/bin/bash
cat ../logs/*.log | grep "ERROR" > ../reports/all_errors.txt
