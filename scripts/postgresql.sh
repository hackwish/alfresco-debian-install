#!/bin/bash
# -------
# Script for install of Postgresql to be used with Alfresco
# 
# Copyright 2013 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------
# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
  echo "${bldblu}$1${txtrst}"
}
echored () {
  echo "${bldred}$1${txtrst}"
}
echogreen () {
  echo "${bldgre}$1${txtrst}"
}


if [ "`which sudo`" = "" ]; then
	export SUDO=''
	export SU_POSTGRES='su posgres -c \"'
	export END_SU='\"'
else
	export SUDO='sudo'
	export SU_POSTGRES='sudo -u postgres'
	export END_SU=
fi

export ALFRESCODB=alfresco
export ALFRESCOUSER=alfresco
export ALFRESCOSERVER="127.0.0.1/32"

echoblue
echoblue "--------------------------------------------"
echoblue "This script will install PostgreSQL."
echoblue "and create alfresco database and user."
echoblue "You may be prompted for $SUDO password."
echoblue "--------------------------------------------"
echoblue

read -e -p "Install PostgreSQL database? [y/n] " -i "n" installpg
if [ "$installpg" = "y" ]; then
  $SUDO apt-get install postgresql
  echo
fi

read -e -p "Create Alfresco Database and user? [y/n] " -i "n" createdb
if [ "$createdb" = "y" ]; then
  $SU_POSTGRES createuser -D -A -P $ALFRESCOUSER $END_SU
  $SU_POSTGRES createdb -O $ALFRESCOUSER $ALFRESCODB $END_SU
  echo
  echoblue "Remember to update alfresco-global.properties with the alfresco database password"
  echo
fi

read -e -p "Set password for postgresql admin account ? [y/n]" -i "n" setadminpwd
if [ "$setadminpwd" = "y"]; then
  echoblue "You will now set the default password for the postgres user."
  echoblue "This will open a psql terminal, enter:"
  echo
  echoblue "\\password postgres"
  echo
  echoblue "and follow instructions for setting postgres admin password."
  echoblue "Press Ctrl+D or type \\q to quit psql terminal"
  echoblue "START psql --------"
  $SU_POSTGRES psql postgres $END_SU
  echoblue "END psql --------"
  echo
fi

read -e -p "Configure psql to allow remote acces from alfresco server (!!! PSQL will be reload !!!) ? [y/n]" -i "n" alfremote
if ["$alfremote" = "y"]; then
	if ["$ALFRESCOSERVER" = ""]; then
		read -e -p "Enter Alfresco Server IP with CIDR (127.0.0.1/32 for localhost)" -i "$ALFRESCOSERVER" ALFRESCOSERVER
	fi
	
	brutpsqlversion=`su postgres -c "psql -c 'SHOW server_version'"`
	longpsqlversion=`echo $brutpsqlversion | sed 's/server_version//' | sed 's/(1 row)//' | sed 's/\-//g' | sed 's/ //g'`
	psqlversion=${longpsqlversion%.*}
		
	echogreen "PSQL Version $psqlversion dectected"
	echoblue "Path to access pg_hba.conf must be /etc/postgresql/$psqlversion/main/pg_hba.conf"
	
	psqlpath="/etc/postgresql/$psqlversion/main/pg_hba.conf"
	pghba="host alfresco alfresco $ALFRESCOSERVER password"
	
	if [ -f $psqlpath ]; then
		echogreen "file pg_hba.conf was found !"
		echo $pghba >> $psqlpath
		service postgresql reload
	else
		echored  "Unable to find pg_hba.conf, You must update the configuration file manually"
	fi
else
	echo
	echoblue "You must update postgresql configuration to allow password based authentication"
	echoblue "(if you have not already done this)."
	echo
	echoblue "Add the following to pg_hba.conf or postgresql.conf (depending on version of postgresql installed)"
	echoblue "located in folder /etc/postgresql/<version>/main/"
	echo
	echoblue "$pghba"
	echo
	echoblue "After you have updated, restart the postgres server /etc/init.d/postgresql restart"
	echo
fi

