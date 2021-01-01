#!/bin/bash
echo "== Regenerating Ledger File =="
python3 generate_data.py > ledger.example.dat
echo "== Building reports (ledger) =="
./mk-reports.sh
echo
echo "== Building graphs (R) =="
Rscript analyze.r
