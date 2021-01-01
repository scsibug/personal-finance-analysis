#!/bin/bash
echo "== Building reports (ledger) =="
./mk-reports.sh
echo
echo "== Building graphs (R) =="
R CMD BATCH analyze.r
