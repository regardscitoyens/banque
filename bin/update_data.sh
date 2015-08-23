#!/bin/bash

cd $(dirname $0)/..
source /usr/local/bin/virtualenvwrapper.sh ||
 ( echo "Error: could not find virtualenvwrapper.sh" && exit 1 )
workon boobankRC

source config.inc

boobank -f csv list > data/list.csv.tmp 2> /tmp/boobank.list.log ||
 ( echo "ERROR collecting list of accounts" && cat /tmp/boobank.list.log && exit 1 )
cat data/list.csv.tmp |
 sed 's/^[0-9]*EUR@//' |
 sed -r 's/Not (available|loaded)//g' |
 csvcut -d ";" -c "id,label,balance,currency,coming,type" > data/list.csv
rm -f data/list.csv.tmp

for BANKID in $CREDITMUTUEL $PAYPAL; do
  boobank history -f csv $BANKID > data/.history.${BANKID}.csv.tmp 2> /tmp/boobank.${BANKID}.history.log ||
   ( echo "ERROR collecting history for $BANKID" && cat /tmp/boobank.${BANKID}.history.log && exit 1 )
  cat data/.history.${BANKID}.csv.tmp |
   sed 's/^[0-9A-Z]*@//' |
   sed 's/ 00:00:00//g' |
   sed -r 's/Not (available|loaded)//g' |
   sed -r 's/(Don|Paiement récurrent) de (\w)[^; ]+( (\w)[^; ]+)*?(;| \(€)/\1 de \2.\4.\5/g' |
   csvcut -d ";" -c "date,id,amount,raw,type,commission,vdate,label" > data/.history.${BANKID}.csv
  rm -f data/.history.${BANKID}.csv.tmp
done

cat data/history.csv data/.history.*@*.csv | sort -ur > data/.history.csv.tmp
mv data/.history.csv.tmp data/history.csv

if ! test "$1" = "nocommit"; then
  git add data/list.csv data/history.csv
  if git commit -m "update bank situation" > /dev/null ; then
    git pull origin master
    git push origin master
  fi
fi
