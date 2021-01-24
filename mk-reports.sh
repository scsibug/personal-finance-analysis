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

# Net worth (assets - liabilities) totals each month
echo "* Report: Net Worth (monthly)"
ledger -f $DAT_FILE reg Assets Liabilities \
  $DATE_FMT -X \$ $PRICES --no-rounding \
  --monthly --total-data --collapse --empty \
  > "$REPORTS_DIR/networth.monthly.csv"

# Expenses
echo "* Report: Expenses (monthly)"
ledger -f $DAT_FILE reg Expenses \
  $DATE_FMT -X \$ $PRICES --no-rounding \
  --monthly --amount-data --collapse --empty \
  > "$REPORTS_DIR/expenses.monthly.csv"

# Invested Assets (totals, monthly)
echo "* Report: Invested Assets (monthly)"
ledger -f $DAT_FILE reg Assets:Brokerage \
  $DATE_FMT -X \$ $PRICES --no-rounding \
  --monthly --total-data --collapse --empty \
  > "$REPORTS_DIR/invested.monthly.csv"
