#!/bin/bash

REPORTS_DIR=reports-generated
DAT_FILE=ledger.example.dat
PRICE_DB=prices.db
DATE_FMT="--date-format %Y-%m-%d"
mkdir -p reports-generated
# Only add external prices if db exists
if test -f "$PRICE_DB"; then
  PRICES="--price-db $PRICE_DB"
else
  PRICES=""
fi

# Net worth (assets - liabilities) reported against each month
echo "Report: Net Worth (monthly)"
ledger -f $DAT_FILE reg $DATE_FMT \
  Assets Liabilities \
  --monthly --total-data --collapse \
  --no-rounding -X \$ $PRICES \
  > "$REPORTS_DIR/networth.monthly.csv"
