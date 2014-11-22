#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForNginx() {
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Nginx can be used as frontend to Tomcat."
	echo "This installation will add config default proxying to Alfresco tomcat."
	echo "The config file also have sample config for ssl and proxying"
	echo "to Sharepoint plugin."
	echo "You can run Alfresco fine without installing nginx."
	echo "If you prefer to use Apache, install that manually. Or you can use iptables"
	echo "forwarding, sample script in $ALF_HOME/scripts/iptables.sh"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Install nginx${ques} [y/n] " -i "n" installnginx
	if [ "$installnginx" = "y" ]; then
	  InstallNginx
	else
	  echo "Skipping install of nginx"
	fi
}

function InstallNginx() {
	echoblue "Installing nginx. Fetching packages..."
	echo
	$SUDO echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" >> /etc/apt/sources.list
	$SUDO curl -# -o $TMPFOLDER/nginx_signing.key http://nginx.org/keys/nginx_signing.key
	$SUDO apt-key add $TMPFOLDER/nginx_signing.key
	
	#echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
	#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
	# Alternate with spdy support and more, change  apt install -> nginx-custom
	#echo "deb http://ppa.launchpad.net/brianmercer/nginx/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
	#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D0DC64F
	
	$SUDO apt-get $APTVERBOSITY update && $SUDO apt-get $APTVERBOSITY install nginx
	$SUDO mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
	$SUDO curl -# -o /etc/nginx/nginx.conf $BASE_DOWNLOAD/nginx/nginx.conf
	$SUDO mkdir -p /var/cache/nginx/alfresco
	$SUDO mkdir -p $ALF_HOME/www
	
	if [ ! -f "$ALF_HOME/www/maintenance.html" ]; then
		echo "Downloading maintenance html page..."
		$SUDO curl -# -o $ALF_HOME/www/maintenance.html $BASE_DOWNLOAD/nginx/maintenance.html
	fi
	$SUDO chown -R www-data:root /var/cache/nginx/alfresco
	$SUDO chown -R www-data:root $ALF_HOME/www
	
	## Reload config file
	$SUDO service nginx reload

	echo
	echogreen "Finished installing nginx"
	echo
}