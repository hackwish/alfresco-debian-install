#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForPostgresqlServer() {
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Install PostgreSQL Database Engine."
	echo "Do you want to install a PSQL Server ? "
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

	read -e -p "Do you want install PostgreSQL Server${ques} [y/n] " -i "y" installpsql
	if [ "$installpsql" = "y" ]; then
		read -e -p "Where (127.0.0.1 for local installation)? " -i "127.0.0.1" psqlserver
		read -e -p "Root password for $psqlserver ?" psqlroot
		read -e -p "Network interface to accessing to psql server (eth0) ?" -i "eth0" psqliface
		read -e -p "Create Alfresco User ? [y/n] " -i "y" createuser
		read -e -p "Create Alfresco Database ? [y/n] " -i "y" createdb
		read -e -p "Set password for postgresql admin account ? [y/n]" -i "n"  setadminpwd
		read -e -p "Alfresco Database Name ? [alfresco] " -i "alfresco" ALFRESCODB
		read -e -p "Alfresco Database Username ? [alfresco] " -i "alfresco" ALFRESCOUSER
		read -e -p "Alfresco Database Password for user $ALFRESCOUSER ? [alfresco] " -i "alfresco" ALFRESCOPWD

		InstallPostgresqlServer
	fi
}

function InstallPostgresqlServer() {
		if [ "$psqlserver" != "127.0.0.1" ]; then
			WaitForNetwork $psqlserver
		fi
			
		sed -i.bak -e "s/createdb=y/createdb=$createdb/g" $ALF_HOME/scripts/postgresql.sh
		sed -i.bak -e "s/createuser=y/createuser=$createuser/g"  $ALF_HOME/scripts/postgresql.sh
		sed -i.bak -e "s/setadminpwd=y/setadminpwd=$setadminpwd/g" $ALF_HOME/scripts/postgresql.sh

		localip=`ifconfig $psqliface | grep -Eo 'inet (adr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
		localmask=`ifconfig $psqliface | sed -rn '2s/ .*:(.*)$/\1/p'`
			
		localcidr="$localip/32"
		
		#Update postgresl script with correct vars
		if [ -f $ALF_HOME/scripts/postgresql.sh ]; then
			# Prepare PSQL script installer
			sed -i.bak -e "s;export ALFRESCOSERVER=.*$;export ALFRESCOSERVER="${localcidr}";g" $ALF_HOME/scripts/postgresql.sh
			sed -i.bak -e "s;export ALFRESCOUSER=.*$;export ALFRESCOUSER="${ALFRESCOUSER}";g" $ALF_HOME/scripts/postgresql.sh
			sed -i.bak -e "s;export ALFRESCOPWD=.*$;export ALFRESCOPWD="${ALFRESCOPWD}";g" $ALF_HOME/scripts/postgresql.sh
			sed -i.bak -e "s;export ALFRESCODB=.*$;export ALFRESCODB="${ALFRESCODB}";g" $ALF_HOME/scripts/postgresql.sh

			# Prepare SEND-SCRIPT
			fullpath="$ALF_HOME/scripts/postgresql.sh"
				
			# Add \ before each / for sed
			if [ "$psqlserver" != "127.0.0.1" ]; then
				cp $ALF_HOME/scripts/remote-script.sh $ALF_HOME/scripts/remote-psql.sh
				chmod a+x $ALF_HOME/scripts/remote-psql.sh
				echoblue "Installing postgresql remotly"
				if [ -f $ALF_HOME/scripts/remote-psql.sh ]; then
					sed -i.bak -e "s/set remoteip.*/set remoteip $psqlserver/g" $ALF_HOME/scripts/remote-psql.sh
					sed -i.bak -e "s/set rootpassword.*/set rootpassword $psqlroot/g" $ALF_HOME/scripts/remote-psql.sh
					sed -i.bak -e "s/set filename.*/set filename postgresql.sh/g" $ALF_HOME/scripts/remote-psql.sh
					sed -i.bak -e "s;set fullpath.*$;set fullpath ${fullpath};g" $ALF_HOME/scripts/remote-psql.sh
						
					# send file and execute to remote server
					$ALF_HOME/scripts/remote-psql.sh
				else
					echored "remote-script.sh is missing !"
					echored "You must install Postgresql manually"
				fi
			else
				echoblue "Install postgresl locally ..."
				$ALF_HOME/scripts/postgresql.sh
			fi
			
			echo
			echogreen "Finished installing Postgresql Server"
			echo

		else
			echored "postgresql installation script not found."
			echored "You must install it manually".
		fi
}

function AskForPostgresqlJBDC() {
	if [ "$installpsql" = "y" ]; then
		InstallPostgresqlJBDC
	else
	    read -e -p "Install Postgres JDBC Connector${ques} [y/n] " -i "n" installpgjbdc
	    if [ "$installpgjbdc" = "y" ]; then
		    InstallPostgresqlJBDC
	    fi
    fi
}

function InstallPostgresqlJBDC() {
	if [ "$usepack" = "y" ]; then
		$SUDO apt-get $APTVERBOSITY install libpostgresql-jdbc-java
		ln -s /usr/share/java/postgresql.jar /usr/share/tomcat7/lib/postgresql.jar
    else
		curl -# -O $JDBCPOSTGRESURL/$JDBCPOSTGRES
		$SUDO mv $JDBCPOSTGRES $CATALINA_HOME/lib
	fi
	
	echo
	echogreen "Finished installing JDBC Connector for Postgresql"
	echo

}

