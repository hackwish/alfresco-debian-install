#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Updated by ADN SYSTEMES / DIXINFOR, Yannick Molinet
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForOpenJDK() {
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Install Java JDK."
	echo "This will install the OpenJDK 7 version of Java. If you prefer Oracle Java"
	echo "you need to download and install that manually."
	echo "If OpenJDK6 is installed, it will be removed".
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Install OpenJDK7${ques} [y/n] " -i "y" installjdk
	if [ "$installjdk" = "y" ]; then
	  InstallOpenJDK
	else
	  echo "Skipping install of OpenJDK 7"
	  echored "IMPORTANT: You need to install other JDK and adjust paths for the install to be complete"
	  echo
	fi
}

function InstallOpenJDK() {
	echoblue "Installing OpenJDK7. Fetching packages..."
	$SUDO apt-get $APTVERBOSITY install openjdk-7-jdk
	echoblue "Removing OpenJDK6..."
	$SUDO apt-get $APTVERBOSITY autoremove openjdk-6-jre-headless openjdk-6-jre-lib openjdk-6-jre
	echo
	echogreen "Finished installing OpenJDK"
	echo
}