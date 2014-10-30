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
export APTVERBOSITY="-qq -y"

installpg=y
createdb=y
createuser=y
setadminpwd=y

echoblue
echoblue "--------------------------------------------"
echoblue "This script will install PostgreSQL."
echoblue "and create alfresco database and user."
echoblue "You may be prompted for $SUDO password."
echoblue "--------------------------------------------"
echoblue

if [ "$installpg" = "y" ]; then
  $SUDO apt-get $APTVERBOSITY install postgresql
  echo
fi

if [ "$createuser" = "y" ]; then
  $SU_POSTGRES createuser -D -A -P $ALFRESCOUSER $END_SU
fi

if [ "$createdb" = "y" ]; then
  $SU_POSTGRES createdb -O $ALFRESCOUSER $ALFRESCODB $END_SU
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
