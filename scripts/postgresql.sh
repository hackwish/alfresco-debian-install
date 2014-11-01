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
	export SU_POSTGRES='su postgres -c '
else
	export SUDO='sudo'
	export SU_POSTGRES='sudo -u postgres'
fi

export ALFRESCODB="alfresco"
export ALFRESCOUSER="alfresco"
export ALFRESCOPWD="alfresco"
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
	OS=`uname -a`
	if [[ $OS == *Debian* ]]
	then
		echo
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "Preparing for install on Debian. Check/Add contrib sources if not present in sources.list"
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

		debcontrib="deb http:\/\/ftp.fr.debian.org\/debian wheezy main contrib"
		deb="deb http:\/\/ftp.fr.debian.org\/debian wheezy main"
		debsec="deb http:\/\/security.debian.org\/ wheezy\/updates main"
		debcontribsec="deb http:\/\/security.debian.org\/ wheezy\/updates main contrib"

		sed -i.bak -e 's/'"$deb"'/'"$debcontrib"'/g' /etc/apt/sources.list
		sed -i.bak -e 's/'"$debsec"'/'"$debcontribsec"'/g' /etc/apt/sources.list

		# Add postgresql apt sources
		# echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list
		# $SUDO apt-get $APTVERBOSITY install wget ca-certificates
		# wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | $SUDO apt-key add -
		echo
	else
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "Non debian OS (Ubuntu ?)"
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	fi

	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Preparing for install. Updating the apt package index files..."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	$SUDO apt-get $APTVERBOSITY update
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Installing Postgresql ..."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

	$SUDO apt-get $APTVERBOSITY install postgresql
	echo
fi

if [ "$createuser" = "y" ]; then
  # $SU_POSTGRES createuser -D -A -P $ALFRESCOUSER 
  $SU_POSTGRES "psql -c \"CREATE USER $ALFRESCOUSER WITH PASSWORD '$ALFRESCOPWD';\" "
fi

if [ "$createdb" = "y" ]; then
  $SU_POSTGRES "createdb -O $ALFRESCOUSER $ALFRESCODB"
fi


brutpsqlversion=`su postgres -c "psql -c 'SHOW server_version'"`
longpsqlversion=`echo $brutpsqlversion | sed 's/server_version//' | sed 's/(1 row)//' | sed 's/\-//g' | sed 's/ //g'`
psqlversion=${longpsqlversion%.*}
		
echogreen "PSQL Version $psqlversion dectected"
echoblue "Path to access pg_hba.conf must be /etc/postgresql/$psqlversion/main/pg_hba.conf"
	
psqlpath="/etc/postgresql/$psqlversion/main/pg_hba.conf"
psqlconf="/etc/postgresql/$psqlversion/main/postgresql.conf"


pghba="host\talfresco\talfresco\t$ALFRESCOSERVER\tpassword"
	
if [ -f $psqlpath ]; then
	echogreen "file pg_hba.conf was found! update it!"
	echo $pghba >> $psqlpath
	echo
	echogreen "file postgresql.conf was found! update it!"
	sed -i.bak -e "s/#listen_addresses = 'localhost'/listen_addresses='*'/d" $psqlconf
	service postgresql restart
else
	echored  "Unable to find pg_hba.conf, You must update the configuration file manually"
fi
