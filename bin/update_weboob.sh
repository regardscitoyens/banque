#!/bin/bash

cd $(dirname $0)/..
source config.inc || exit 1
cd weboob
git pull
python setup.py install
weboob-config update
