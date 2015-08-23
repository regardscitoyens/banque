#!/bin/bash

cd $(dirname $0)/..
echo "- Install possibly missing python pip/virtualenv"
sudo apt-get -q install git python-pip > /dev/null
sudo pip install -q virtualenv virtualenvwrapper > /dev/null

echo
echo "- Create boobankRC virtualenv using virtualenvwrapper"
source /usr/local/bin/virtualenvwrapper.sh ||
 ( echo "Error: could not find virtualenvwrapper.sh" && exit 1 )
mkvirtualenv --no-site-packages boobankRC ||
 ( echo "Error: could not create virtualenv boobankRC" && exit 1 )

echo
echo "- Install python dependencies for the env"
pip install -q PyExecJS virtualenvwrapper ||
 ( echo "Error: could not create virtualenv boobankRC" && exit 1 )

echo
echo "- Install weboob for the env"
# Temporarily use local weboob with fixed paypal until merged
#git clone git://git.symlink.me/pub/weboob/stable.git weboob ||
git clone https://github.com/RouxRC/weboob.git -b paypal-commissions weboob ||
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
echo 'Use source "/usr/local/bin/virtualenvwrapper.sh && workon boobankRC" to activate virtualenv and use weboob features such as "boobank list" or "boobank history".'

# Generate config.inc from boobank list
boobank list 2> /dev/null > /tmp/boobank.list
cat /tmp/boobank.list
cat /tmp/boobank.list |
 grep "@" |
 awk '{print $1}' |
 awk -F '@' '{print toupper($2)"="$1"@"$2}' > config.inc
source config.inc
echo '__________________________________'
echo 'CREDIT MUTUEL History:'
boobank history $CREDITMUTUEL -n 10 2> /dev/null
echo '__________________________________'
echo 'PAYPAL History:'
boobank history $PAYPAL -n 10 2> /dev/null

