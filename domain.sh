#!/bin/bash

echo "Ajout d'un nouveau domaine a monitorer"
read -p "Host name: " host
if [[ -z "$host" ]]; then
        printf '%s\n' "Vous devez rentrer un nom du host (ex: ucorsu.itc.ovh)"
        exit 1
fi

if [ ! -f "/etc/icinga2/zones.d/master/${host}.conf" ]
then
        echo "Fichier de conf introuvable"
        exit 1
fi

read -p "Domaine: " domain
if [[ -z "$domain" ]]; then
        printf '%s\n' "Vous devez rentrer un nom de domaine sans http(s):// (ex: u-corsu.com)"
        exit 1
fi

NEWFILE=$( cat file.txt | head -n -1 && echo -e " vars.http_vhosts[\""$domain"\"] = {
  http_vhost = \""$domain"\"
  http_ssl = true
 }
}" )

echo "$NEWFILE" > "/etc/icinga2/zones.d/master/${host}.conf"