#!/bin/bash

. bin/config.inc

# Connexion à Cozycloud
COZY_URLAUTH=$(curl -X GET -I "$COZY_URLBANK" | grep "location" | tr -d "\r" | cut -d " " -f 2)
COZY_CSRFTOKEN=$(curl -X GET "$COZY_URLAUTH" -c /tmp/cozycookie | grep "csrf_token" | sed -r 's/.+value=\"//' | sed -r 's/".+//')
curl -b /tmp/cozycookie  -c /tmp/cozycookie "$(curl -X POST "$COZY_URLAUTH" -b /tmp/cozycookie -c /tmp/cozycookie -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -d "passphrase=$COZY_PASSCRYPTE&csrf_token=$COZY_CSRFTOKEN&long-run-session=1&two-factor-trusted-device-token=&redirect=$COZY_URLBANK" | jq '.redirect' | sed 's/"//g')"
COZY_JWTTOKEN=$(curl "$COZY_URLBANK" -b /tmp/cozycookie | grep "data-cozy-token=" | sed -r 's/.+data-cozy-token="//' | sed -r 's/".+//')
COZY_URLDATA="https://$(curl "$COZY_URLBANK" -b /tmp/cozycookie | grep "data-cozy-domain=" | sed -r 's/.+data-cozy-domain="//' | sed -r 's/".+//')/data"

git pull

echo "date,\"raw\",amount,type,id,rdate,vdate,\"label\"" > $HISTORY_FILE".new"

curl "$COZY_URLDATA/io.cozy.bank.operations/_all_docs?include_docs=true" -b /tmp/cozycookie -H 'Accept: application/json' -H "Authorization: Bearer $COZY_JWTTOKEN" | jq -c '.rows[].doc' | grep "\"$COZY_COMPTEBANCAIRE_ID\"" | jq -c "[.rawDate,\"|<\",.originalBankLabel,\"|>\",.amount,.localCategoryId,\"$COZY_COMPTEBANCAIRE_NOM\",.rawDate,.valueDate,\"|<\",.label,\"|>\"]" | sed 's/"//g' | sed 's/|<,/"/g' | sed 's/,|>/"/g' | sed 's/\[//g' | sed 's/^\[//' | sed 's/\]$//' >> $HISTORY_FILE".new"

tail -n +10 $HISTORY_FILE > $HISTORY_FILE".old"
cat $HISTORY_FILE".new" $HISTORY_FILE".old" | sort| uniq | sort -r > $HISTORY_FILE".tmp"
mv $HISTORY_FILE".tmp" $HISTORY_FILE
rm -f $HISTORY_FILE".old" $HISTORY_FILE".new"

git add $HISTORY_FILE
git commit -m "Mise à jour des opérations" $HISTORY_FILE > /dev/null

git push
