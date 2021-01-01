#!/bin/bash
echo "== Building reports (ledger) =="
./mk-reports.sh
echo
echo "== Building graphs (R) =="
Rscript analyze.r
