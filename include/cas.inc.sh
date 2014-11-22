#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Updated by ADN SYSTEMES / DIXINFOR, Yannick Molinet
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForCAS() {
	read -e -p "Do you want to install a CAS Server ? [y/n] " -i "n" cas
	if [ "$cas" = "y" ]; then
		cp $ALF_HOME/scripts/remote-script.sh $ALF_HOME/scripts/remote-cas.sh
		chmod u+x $ALF_HOME/scripts/remote-cas.sh
		#JASIG_WORK="/opt/work"
		read -e -p "Enter CAS IP Address: " casip
		read -e -p "Enter root password: " caspwd
		read -e -p "Enter the CAS FQDN: " FQDN

		sed -i.bak -e "s/CAS_DOWNLOAD=.*/CAS_DOWNLOAD=$CAS_DOWNLOAD/g" $ALF_HOME/scripts/cas.sh
		sed -i.bak -e "s/FQDN=.*/FQDN=$FQDN/g" $ALF_HOME/scripts/cas.sh
		
		fullpath="$ALF_HOME/scripts/cas.sh"
		
		sed -i.bak -e "s/set remoteip.*/set remoteip $casip/g" $ALF_HOME/scripts/remote-cas.sh
		sed -i.bak -e "s/set rootpassword.*/set rootpassword $caspwd/g" $ALF_HOME/scripts/remote-cas.sh
		sed -i.bak -e "s/set filename.*/set filename jasig-cas.sh/g" $ALF_HOME/scripts/remote-cas.sh
		sed -i.bak -e "s;set fullpath.*$;set fullpath ${fullpath};g" $ALF_HOME/scripts/remote-cas.sh
		
		$ALF_HOME/scripts/remote-cas.sh
	fi
}
