#!/bin/bash

cd $(dirname $0)/..

echo
echo "- Create boobankRC virtualenv using virtualenvwrapper"
VEWR=$(which virtualenvwrapper.sh)
if [ ! -z "$VEWR" ]; then
  source $VEWR
else
  for vewpath in /usr/local/bin/virtualenwrapper.sh /usr/bin/virtualenvwrapper.sh /usr/share/virtualenwrapper/virtualenvwrapper.sh /etc/bash_completion.d/virtualenvwrapper; do
    source $vewpath 2> /dev/null && VEWR=$vewpath && break
  done
fi
echo "source $VEWR ||
 ( echo 'Error: could not find virtualenvwrapper.sh, please try to locate it and change it in config.inc' && exit 1 )
workon boobankRC" > config.inc

mkvirtualenv --no-site-packages boobankRC ||
 ( echo "Error: could not create virtualenv boobankRC" && exit 1 )

echo
echo "- Install python dependencies for the env"
pip install -q csvkit PyExecJS virtualenvwrapper ||
 ( echo "Error: could not create virtualenv boobankRC" && exit 1 )

echo
echo "- Install weboob for the env"
git clone git://git.symlink.me/pub/weboob/devel.git weboob ||
 ( echo "Error: could not clone weboob git directory" && exit 1 )
cd weboob
echo "installing..."
python setup.py install > /tmp/weboob-install.log 2>&1 ||
 ( echo 'Error: could not install weboob, see full log in "/tmp/weboob-install.log"' && exit 1 )
cd ..

echo
echo "- Set boobank's directory as a python library source (for possible dev)"
add2virtualenv $(pwd)

echo
echo '__________________________________'
echo 'Virtualenv "boobankRC" with weboob included successfully installed!'
echo
echo 'Installing weboob modules now.'
echo 'Enter logins/passwords and set configs to "s" to allow autoupdates.'
echo
echo '__________________________________'
echo ' - CREDIT MUTUEL:'
echo
weboob-config add creditmutuel
echo
echo '__________________________________'
echo ' - PAYPAL:'
echo
weboob-config add paypal

# Update paypal modules with local install until fixed
echo
echo file://$(pwd)/weboob/modules/ >> $HOME/.config/weboob/sources.list
weboob-config update > /tmp/weboob-config.update.log 2>&1 ||
 ( echo "Error updating paypal module" && cat /tmp/weboob-config.update.log)

echo
echo '__________________________________'
echo "Install finished!"
echo 'Use "source config.inc" to activate virtualenv and use weboob features such as "boobank list" or "boobank history".'

# Generate config.inc from boobank list
echo
echo '__________________________________'
echo 'Accounts balance:'
boobank list 2> /dev/null > /tmp/boobank.list
cat /tmp/boobank.list
cat /tmp/boobank.list |
 grep "@" |
 awk '{print $1}' |
 awk -F '@' '{print toupper($2)"="$1"@"$2}' >> config.inc
source config.inc
echo '__________________________________'
echo 'CREDIT MUTUEL History:'
boobank history $CREDITMUTUEL -n 10 2> /dev/null
echo '__________________________________'
echo 'PAYPAL History:'
boobank history $PAYPAL -n 10 2> /dev/null

