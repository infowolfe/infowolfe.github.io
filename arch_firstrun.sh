#!/bin/bash

if [[ "$(whoami)" == "root" ]] ; then
	# set temporary hostname
	echo "Please enter this machine's hostname"
	read hostname
	hostnamectl set-hostname ${hostname}
	echo ${hostname} > /etc/hostname
	echo -e "127.0.0.1\t${hostname}" >> /etc/hosts
	rm /etc/profile.d/firstrun.sh
fi
