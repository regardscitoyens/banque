#!/bin/bash

cd $(dirname $0)/../weboob
source ../config.inc || exit 1

python setup.py install
weboob-config update
