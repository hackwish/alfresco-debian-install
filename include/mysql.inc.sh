#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------


function AskForMysqlServer() {
	echo	
}

function InstallMysqlServer() {
	echo
}

function InstallMysqlJBDC() {
	if [ "$usepack" = "y" ]; then
		$SUDO apt-get $APTVERBOSITY install libmysql-java
	else
		cd $TMPFOLDER
		curl -# -L -O $JDBCMYSQLURL/$JDBCMYSQL
		tar xf $JDBCMYSQL
		cd "$(find . -type d -name "mysql-connector*")"
		$SUDO mv mysql-connector*.jar $CATALINA_HOME/lib
	fi
	
	echo
	echogreen "Finished installing JDBC Connector for Mysql"
	echo

}