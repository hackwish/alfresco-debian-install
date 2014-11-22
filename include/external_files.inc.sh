#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function CheckRemoteFiles (){
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Checking for the availability of the URLs inside script..."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo

	URLERROR=0

	for REMOTE in ${REMOTEFILES[@]}

	do
			echo "check remote file: $REMOTE"
			wget --spider $REMOTE  >& /dev/null
			if [ $? != 0 ]
			then
					echored "In alfinstall.sh, please fix this URL: $REMOTE"
					URLERROR=1
			fi
	done

	if [ $URLERROR = 1 ]
	then
		echo
		echored "Please fix the above errors and rerun."
		echo
		exit
	fi
}

function RetrieveExecutionScripts() {
	$SUDO mkdir -p $ALF_HOME/scripts
	
	if [ ! -f "$ALF_HOME/scripts/mariadb.sh" ]; then
		echo "Downloading mariadb.sh install and setup script..."
		$SUDO curl -# -o $ALF_HOME/scripts/mariadb.sh $BASE_DOWNLOAD/scripts/mariadb.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/postgresql.sh" ]; then
		echo "Downloading postgresql.sh install and setup script..."
		$SUDO curl -# -o $ALF_HOME/scripts/postgresql.sh $BASE_DOWNLOAD/scripts/postgresql.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/limitconvert.sh" ]; then
		echo "Downloading limitconvert.sh script..."
		$SUDO curl -# -o $ALF_HOME/scripts/limitconvert.sh $BASE_DOWNLOAD/scripts/limitconvert.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/createssl.sh" ]; then
		echo "Downloading createssl.sh script..."
		$SUDO curl -# -o $ALF_HOME/scripts/createssl.sh $BASE_DOWNLOAD/scripts/createssl.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/libreoffice.sh" ]; then
		echo "Downloading libreoffice.sh script..."
		$SUDO curl -# -o $ALF_HOME/scripts/libreoffice.sh $BASE_DOWNLOAD/scripts/libreoffice.sh
		$SUDO sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" $ALF_HOME/scripts/libreoffice.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/iptables.sh" ]; then
		echo "Downloading iptables.sh script..."
		$SUDO curl -# -o $ALF_HOME/scripts/iptables.sh $BASE_DOWNLOAD/scripts/iptables.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/alfresco-iptables.conf" ]; then
		echo "Downloading alfresco-iptables.conf upstart script..."
		$SUDO curl -# -o $ALF_HOME/scripts/alfresco-iptables.conf $BASE_DOWNLOAD/scripts/alfresco-iptables.conf
	fi
	if [ ! -f "$ALF_HOME/scripts/ams.sh" ]; then
		echo "Downloading maintenance shutdown script..."
		$SUDO curl -# -o $ALF_HOME/scripts/ams.sh $BASE_DOWNLOAD/scripts/ams.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/remote-script.sh" ]; then
		echo "Downloading script to install remotly ..."
		$SUDO curl -# -o $ALF_HOME/scripts/remote-script.sh $BASE_DOWNLOAD/scripts/remote-script.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/glusterfs.sh" ]; then
		echo "Downloading script to install glusterfs ..."
		$SUDO curl -# -o $ALF_HOME/scripts/glusterfs.sh $BASE_DOWNLOAD/scripts/glusterfs.sh
	fi
	if [ ! -f "$ALF_HOME/scripts/cas.sh" ]; then
		echo "Downloading script to install jasig cas ..."
		$SUDO curl -# -o $ALF_HOME/scripts/jasig-cas.sh $BASE_DOWNLOAD/scripts/jasig-cas.sh
	fi
  
	$SUDO chmod u+x $ALF_HOME/scripts/*.sh
}