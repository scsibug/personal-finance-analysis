#!/bin/bash
echo -e "== Generating Ledger File ==\n"
python3 generate_data.py > ledger.example.dat
# count number of transactions
TXNS=$(grep "^\d" ledger.example.dat | wc -l | awk '{print $1}')
echo "* Generated $TXNS transactions"
echo

echo -e "== Building reports (ledger) ==\n"
./mk-reports.sh
echo

echo -e "== Building graphs (R) ==\n"
Rscript analyze.r
