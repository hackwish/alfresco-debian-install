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