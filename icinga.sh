#!/bin/bash

echo "Ajout d'un nouveau host dans Icinga2"
read -p "Nom a afficher: " name
if [[ -z "$name" ]]; then
        printf '%s\n' "Vous devez rentrer un nom (ex: VPS1 ITC)"
        exit 1
fi

read -p "Host: " host
if [[ -z "$host" ]]; then
        printf '%s\n' "Vous devez rentrer un host"
        exit 1
fi

read -p "Type d'OS: " os
if [[ -z "$os" ]]; then
        printf '%s\n' "Vous devez rentrer un OS"
        exit 1
fi

read -p "Provider: " provider
if [[ -z "$provider" ]]; then
        printf '%s\n' "Vous devez rentrer un Provider"
        exit 1
fi

ipPattern="^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
read -p "Adresse IP: " ip
if [[ $ip == $ipPattern ]]; then
        printf '%s\n' "Vous devez rentrer une adresse IP valide"
        exit 1
fi

echo "" #new line

read -p "Les informations sont elles correctes [Y/n] ? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" #new line
        tee -a /etc/icinga2/zones.d/master/${host}.conf <<EOF
object Host "${host}" {
 import "generic-host"
 check_command = "hostalive"
 address = "${ip}"
 display_name = "${name}"
 vars.os_type = "${os}"
 vars.provider = "${provider}"
 vars.client_endpoint = name
}
EOF
        tee -a /etc/icinga2/zones.conf <<EOF
# ${name} - ${host}
object Endpoint "${host}" {
 host = "${ip}"
}

object Zone "${host}" {
 endpoints = [ "${host}" ]
 parent = "master"
}

EOF
else
        exit 1
fi

service icinga2 restart