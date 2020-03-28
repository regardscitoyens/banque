#!/bin/bash

cd $(dirname $0)/..
source config.inc || exit 1

# Collect and format details on all accounts
PYTHONIOENCODING=UTF-8 boobank -f csv list > data/list.csv.tmp 2> /tmp/boobank.list.log ||
 ( echo "ERROR collecting list of accounts" && cat /tmp/boobank.list.log && exit 1 )
cat data/list.csv.tmp                   |
 sed -r 's/^("?)[0-9]*EUR@/\1/'         |
 sed -r 's/Not (available|loaded)//g'   |
 grep ";\"\?EUR\"\?;\|^id"              |
 grep -v 'CBMastercard'                 |
 csvcut -d ";" -c "id,label,balance,currency,coming,type" > data/list.csv
rm -f data/list.csv.tmp

# Collect and format recent history for each account
BANKFILES=""
for BANKID in $CREDITMUTUEL $PAYPAL; do
  PYTHONIOENCODING=UTF-8 boobank history -f csv $BANKID -n 20 | grep -v "reconfigure this backend" > data/.history.${BANKID}.csv.tmp 2> /tmp/boobank.${BANKID}.history.log ||
   ( echo "ERROR collecting history for $BANKID" && cat /tmp/boobank.${BANKID}.history.log && exit 1 )
  bin/format_bankline.py data/.history.${BANKID}.csv.tmp   |
   csvcut -d "," -c "date,id,amount,raw,type,commission,vdate,label" > data/.history.${BANKID}.csv
  #mv data/.history.${BANKID}.csv.tmp data/.history.${BANKID}.$(date +%y%m%d-%H%M).tmp
  rm -f data/.history.${BANKID}.csv.tmp
  BANKFILES=$BANKFILES data/.history.${BANKID}.csv
done

if ! test -s data/list.csv ; then
	git checkout data/list.csv
fi
bash bin/update_cozy.sh

# Merge new entries into global history
cat data/history.csv $BANKFILES > data/.history.csv.tmp

# Anonymisation
bin/anon_bankline.py data/.history.csv.tmp | sort -ur > data/history.csv
rm data/.history.csv.tmp

# Auto commit if not debugging
if ! test "$1" = "nocommit" ; then
  if test `cat data/list.csv | wc -l` -eq 3 ; then
	  git add data/list.csv
  fi
  git add data/history.csv
  if git commit -m "update bank situation" > /dev/null ; then
    git pull origin master
    git push origin master
    git checkout data/list.csv data/history.csv
  fi
fi
