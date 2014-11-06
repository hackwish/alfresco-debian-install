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
else
	export SUDO='sudo'
fi

GLUSTERFOLDER="/srv/brik"
GLUSTERVOLUME="alfrescodata"
GLUSTERTYPE="replica"
GLUSTERPEERS=array("127.0.0.1")
GLUSTERMASTER="n"
ALFRESCOSERVER="127.0.0.1"
APTVERBOSITY="-qq -y"

echoblue
echoblue "-----------------------------------------------------------------------"
echoblue "This script will install GlusterFS Server on one or more remote server "
echoblue "and create a volume."
echoblue "You may be prompted for $SUDO password."
echoblue "-----------------------------------------------------------------------"
echoblue

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
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing GlusterFS Server ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install glusterfs-server

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Create the brick folder ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
mkdir -p $GLUSTERFOLDER

if [ "$GLUSTERMASTER" = "y" ]; then
	echo
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "We are on the 'master' GlusterFS Server, Create VOLUME and Add PEERS"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	
	glusternode="";
	
	for peer in ${GLUSTERPEERS[@]} do
		echo "Add peer $peer"
		gluster peer probe $peer
		$glusternode="$glusternode $peer:/$GLUSTERFOLDER"
	done
	
	echoblue "PEERS STATUS"
	gluster peer status
	echo
	
	echoblue "CREATE GLUSTERFS VOLUME"
	gluster volume create $GLUSTERVOLUME $GLUSTERTYPE ${#GLUSTERPEERS[@]} $glusternode
	echo
	
	echoblue "GLUSTERFS VOLUME INFORMATION"
	gluster volume info
	echo
	
	echoblue "START GLUSTERFS VOLUME"
	gluster volume start $GLUSTERVOLUME
	echo

	echoblue "GLUSTERFS VOLUME INFORMATION"
	gluster volume info
	echo

	echoblue "ALLOW CLIENT TO ACCESS THE GLUSTERFS VOLUME"
	gluster volume set $GLUSTERVOLUME auth.allow $ALFRESCOSERVER
fi





