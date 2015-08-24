#!/bin/bash

cd $(dirname $0)/..
source config.inc || exit 1
deactivate
rmvirtualenv boobankRC
rm -rf weboob
echo 'Will now remove user config for weboob in "'$HOME'/.config/weboob/"'
echo 'Press Ctrl+c to keep your config, then Ctrl+c again twice on reinstall during accounts config'
read
rm -rf ~/.config/weboob

