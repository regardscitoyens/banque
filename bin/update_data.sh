#!/bin/bash

cd $(dirname $0)/..
source config.inc || exit 1

# Collect and format details on all accounts
boobank -f csv list > data/list.csv.tmp 2> /tmp/boobank.list.log ||
 ( echo "ERROR collecting list of accounts" && cat /tmp/boobank.list.log && exit 1 )
cat data/list.csv.tmp                   |
 sed 's/^"[0-9]*EUR@/"/'                |
 sed -r 's/Not (available|loaded)//g'   |
 grep ";\"EUR\";\|^id"                  |
 csvcut -d ";" -c "id,label,balance,currency,coming,type" > data/list.csv
rm -f data/list.csv.tmp

# Collect and format recent history for each account
for BANKID in $CREDITMUTUEL $PAYPAL; do
  boobank history -f csv $BANKID -n 20 > data/.history.${BANKID}.csv.tmp 2> /tmp/boobank.${BANKID}.history.log ||
   ( echo "ERROR collecting history for $BANKID" && cat /tmp/boobank.${BANKID}.history.log && exit 1 )
  cat data/.history.${BANKID}.csv.tmp   |
   bin/format_bankline.py               |
   csvcut -d ";" -c "date,id,amount,raw,type,commission,vdate,label" > data/.history.${BANKID}.csv
  rm -f data/.history.${BANKID}.csv.tmp
  #mv data/.history.${BANKID}.csv.tmp data/.history.${BANKID}.$(date +%y%m%d-%H%M).tmp
done

# Merge new entries into global history
cat data/history.csv data/.history.*@*.csv | sort -ur > data/.history.csv.tmp
mv data/.history.csv.tmp data/history.csv

# Auto commit if not debugging
if ! test "$1" = "nocommit" && [ `cat data/list.csv | wc -l` -eq 3 ] && [ -s data/.history.${CREDITMUTUEL}.csv ] && [ -s data/.history.${PAYPAL}.csv ]; then
  git add data/list.csv data/history.csv
  if git commit -m "update bank situation" > /dev/null ; then
    git pull origin master
    git push origin master
  fi
fi
