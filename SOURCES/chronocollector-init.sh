#!/bin/bash

if [ ! -f /var/lib/chronoc/env.sh ]
then
	echo "Error: /var/lib/chronoc/env.sh missing"
	exit 1
fi

if [ ! -f /var/lib/chronoc/config.yml ]
then
	HNM=`hostname -s`
	sed -e'1,$s'"/%HOSTNAME%/$HNM/g" /var/lib/chronoc/config.yml-tmpl > /var/lib/chronoc/config.yml
	echo "Info: /var/lib/chronoc/config.yml created from template"
fi

