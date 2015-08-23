#!/bin/bash

cd $(dirname $0)/..
source /usr/local/bin/virtualenvwrapper.sh ||
 ( echo "Error: could not find virtualenvwrapper.sh" && exit 1 )
workon boobankRC

source config.inc

boobank -f csv list | sed 's/^[0-9]*EUR@//' | sed 's/,/./g' | sed 's/;/,/g' > data/list.csv 2> /tmp/boobank.list.log ||
 ( echo "ERROR collecting list of accounts" && cat /tmp/boobank.list.log && exit 1 )

for BANKID in $CREDITMUTUEL $PAYPAL; do
  boobank history -f csv $BANKID > data/.history.${BANKID}.csv.tmp 2> /tmp/boobank.${BANKID}.history.log ||
   ( echo "ERROR collecting history for $BANKID" && cat /tmp/boobank.${BANKID}.history.log && exit 1 )
  cat data/.history.${BANKID}.csv.tmp |
   sed 's/^[0-9A-Z]*@//' |
   sed 's/ 00:00:00//g' |
   sed 's/,/./g' |
   sed 's/;/,/g' > data/.history.${BANKID}.csv
  rm -f data/.history.${BANKID}.csv.tmp
done

cat data/history.csv data/.history.*@*.csv | sort -ur > data/.history.csv.tmp
mv data/.history.csv.tmp data/history.csv

git add data/list.csv data/history.csv
if ! test "$1" = "nocommit" && git commit -m "update bank situation" > /dev/null ; then
  git pull origin master
  git push origin master
fi
