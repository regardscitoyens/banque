#!/bin/bash

cd $(dirname $0)/..
source /usr/local/bin/virtualenvwrapper.sh ||
 ( echo "Error: could not find virtualenvwrapper.sh" && exit 1 )
if [ ! -z "$VIRTUAL_ENV" ]; then deactivate; fi
rmvirtualenv boobankRC
rm -rf weboob
echo 'Will now remove user config for weboob in "'$HOME'/.config/weboob/"'
echo 'Press Ctrl+c to keep your config, then Ctrl+c again twice on reinstall during accounts config'
read
rm -f config.inc
rm -rf ~/.config/weboob

