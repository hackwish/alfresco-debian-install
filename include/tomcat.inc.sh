#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------


function AskForTomcat(){
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Tomcat is the application server that runs Alfresco."
	echo "You will also get the option to install jdbc lib for Postgresql or MySql/MariaDB."
	echo "Install the jdbc lib for the database you intend to use."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Install Tomcat${ques} [y/n] " -i "y" installtomcat

	if [ "$installtomcat" = "y" ]; then
		InstallTomcat
	else
		echo "Skipping install of Tomcat"
		echo
	fi
}

function InstallTomcat() {
	echogreen "Installing Tomcat"
	if [ "$usepack" = "y" ]; then
		echo "Installing tomcat from package..."
		$SUDO apt-get $APTVERBOSITY install tomcat7 libtcnative-1
		service tomcat7 stop
		echo "Set memory setting for JAVA ..."
		sed -i.bak -e "s/-Xmx128m/-Xms1G -Xmx2G -Xss1024k -XX:MaxPermSize=256m/g" /etc/default/tomcat7
	else
		echo "Downloading tomcat..."
		curl -# -L -O $TOMCAT_DOWNLOAD
		# Make sure install dir exists
		$SUDO mkdir -p $ALF_HOME
		echo "Extracting..."
		tar xf "$(find . -type f -name "apache-tomcat*")"
		$SUDO mv "$(find . -type d -name "apache-tomcat*")" $CATALINA_HOME
	  
		echo
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "You need to add a system user that runs the tomcat Alfresco instance."
		echo "Also updates locale support."
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		read -e -p "Add alfresco system user${ques} [y/n] " -i "n" addalfresco
		if [ "$addalfresco" = "y" ]; then
			$SUDO adduser --system --no-create-home --disabled-login --disabled-password --group $ALF_USER
			echogreen "Finished adding alfresco user"
			echo
		else
			echo "Skipping adding alfresco user"
			echo
		fi
	fi
	  
	# Remove apps not needed -- Why, keep default files to check if tomcat is working.
	# $SUDO rm -rf $CATALINA_BASE/webapps/*
	  
	# Get Alfresco config
	echo "Downloading tomcat configuration files..."
	$SUDO curl -# -o $CATALINA_CONF/server.xml $BASE_DOWNLOAD/tomcat-alfresco/server.xml
	$SUDO curl -# -o $CATALINA_CONF/catalina.properties $BASE_DOWNLOAD/tomcat-alfresco/catalina.properties

	# Create /shared
	$SUDO mkdir -p $CATALINA_BASE/shared/classes/alfresco/extension
	$SUDO mkdir -p $CATALINA_BASE/shared/classes/alfresco/web-extension
	
	# Add endorsed dir
	$SUDO mkdir -p $CATALINA_BASE/endorsed
	  
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to add the dns name, port and protocol for your server(s)."
	echo "It is important that this is is a resolvable server name."
	echo "This information will be added to default configuration files."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Please enter the public host name for Share server (fully qualified domain name)${ques} [`hostname`] " -i "`hostname`" SHARE_HOSTNAME
	read -e -p "Please enter the protocol to use for public Share server (http or https)${ques} [http] " -i "http" SHARE_PROTOCOL
	
	# Keep Share on default port and use a reverse proxy to do the trick.
	SHARE_PORT=8080
	if [ "${SHARE_PROTOCOL,,}" = "https" ]; then
		SHARE_PORT=8443
	fi
	
	read -e -p "Please enter the host name for Alfresco Repository server (fully qualified domain name)${ques} [$SHARE_HOSTNAME] " -i "$SHARE_HOSTNAME" REPO_HOSTNAME

	# Add default alfresco-global.propertis
	ALFRESCO_GLOBAL_PROPERTIES=$TMPFOLDER/alfresco-global.properties
	$SUDO curl -# -o $ALFRESCO_GLOBAL_PROPERTIES $BASE_DOWNLOAD/tomcat-alfresco/alfresco-global.properties
	sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
	sed -i "s/@@ALFRESCO_SHARE_SERVER_PORT@@/$SHARE_PORT/g" $ALFRESCO_GLOBAL_PROPERTIES
	sed -i "s/@@ALFRESCO_SHARE_SERVER_PROTOCOL@@/$SHARE_PROTOCOL/g" $ALFRESCO_GLOBAL_PROPERTIES
	sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
	$SUDO mv $ALFRESCO_GLOBAL_PROPERTIES $CATALINA_BASE/shared/classes/

	read -e -p "Install Share config file (recommended)${ques} [y/n] " -i "y" installshareconfig
	if [ "$installshareconfig" = "y" ]; then
		SHARE_CONFIG_CUSTOM=$TMPFOLDER/share-config-custom.xml
		$SUDO curl -# -o $SHARE_CONFIG_CUSTOM $BASE_DOWNLOAD/tomcat-alfresco/share-config-custom.xml
		sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
		sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
		$SUDO mv $SHARE_CONFIG_CUSTOM $CATALINA_BASE/shared/classes/alfresco/web-extension/
	fi

	echo
	echogreen "Finished installing Tomcat"
	echo
}