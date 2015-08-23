# Comptes détaillés de Regards Citoyens

Ce dépot publie les comptes détaillés de l'association [Regards Citoyens](http://regardscitoyens.org/) à partir de son relevé bancaire permanent et de son compte Paypal.

Le fichier [history.csv](https://github.com/regardscitoyens/banque/blob/master/data/history.csv) permet de connaitre les différentes opérations ayant été effectuées sur le compte depuis le 29 avril 2015.
Le fichier [list.csv](https://github.com/regardscitoyens/banque/blob/master/data/list.csv) contient le solde du compte.

L'export est réalisé grace aux plugins [creditmutuel](http://weboob.org/modules#mod_creditmutuel) et [paypal](http://weboob.org/modules#paypal) de [weboob](http://weboob.org/) et à [csvkit](http://csvkit.readthedocs.org/en/0.9.1/). Les informations sont mises à jour toutes les heures.

## Installation

```bash
bin/install.sh
```

## Exécution (attention autocommit)

```bash
bin/update_data.sh
```

## Dev:

- Exécution sans autocommit

```bash
bin/update_data.sh nocommit
```

- Utiliser les outils weboob
Weboob est installé dans le virtualenv boobankRC. Il faut donc l'activer:

```bash
# D'ordinaire les envs sont installés dans $HOME/.virtualenvs
~/.virtualenvs/boobankRC/bin/activate
# ou avec virtualenvwrapper
source /usr/local/bin/virtualenvwrapper.sh
workon boobankRC
```

## Reset bank account logins
```bash
source /usr/local/bin/virtualenvwrapper.sh
workon boobankRC
weboob-config add creditmutuel
weboob-config add paypal
```

## Désinstallation

```bash
bin/uninstall.sh
```

