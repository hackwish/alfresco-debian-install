#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Updated by ADN SYSTEMES / DIXINFOR, Yannick Molinet
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForPostgresql() {
	if [ "$installpg" = "y" ]; then
		echo
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "Install PostgreSQL Engine."
		echo "You have choice to use PSQL Connector, do you want to install a PSQL Server ? "
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

		read -e -p "Do you want install PostgreSQL Server${ques} [y/n] " -i "y" installpsql
		if [ "$installpsql" = "y" ]; then
			read -e -p "Where (127.0.0.1 for local installation) ?" -i "127.0.0.1" psqlserver
			read -e -p "Root password for $psqlserver ?" psqlroot
			read -e -p "Network interface to accessing to psql server (eth0) ?" -i "eth0" psqliface
			read -e -p "Create Alfresco User ? [y/n] " -i "y" createuser
			read -e -p "Create Alfresco Database ? [y/n] " -i "y" createdb
			read -e -p "Set password for postgresql admin account ? [y/n]" -i "n"  setadminpwd

			sed -i.bak -e "s/createdb=y/createdb=$createdb/g" $ALF_HOME/scripts/postgresql.sh
			sed -i.bak -e "s/createuser=y/createuser=$createuser/g"  $ALF_HOME/scripts/postgresql.sh
			sed -i.bak -e "s/setadminpwd=y/setadminpwd=$setadminpwd/g" $ALF_HOME/scripts/postgresql.sh

			localip=`ifconfig $psqliface | grep -Eo 'inet (adr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
			localmask=`ifconfig $psqliface | sed -rn '2s/ .*:(.*)$/\1/p'`
			
			localcidr="$localip/32"
		
			#Update postgresl script with correct vars
			if [ -f $ALF_HOME/scripts/postgresql.sh ]; then
				# Prepare PSQL script installer
				
				read -e -p "Alfresco Database Name ? [alfresco] " -i "alfresco" ALFRESCODB
				read -e -p "Alfresco Database Username ? [alfresco] " -i "alfresco" ALFRESCOUSER
				read -e -p "Alfresco Database Password for user $ALFRESCOUSER ? [alfresco] " -i "alfresco" ALFRESCOPWD

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
			else
				echored "postgresql installation script not found."
				echored "You must install it manually".
			fi

			
			echoblue "Update alfresco-global.properties"
			sed -i.bak "s/db.username=.*/db.username=alfresco/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
			sed -i.bak "s/db.password=.*/db.password=alfresco/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
			sed -i.bak "s/db.name=.*/db.name=alfresco/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
			sed -i.bak "s/db.host=.*/db.host=$psqlserver/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
							
			sed -i.bak "s/db.driver=com.mysql.jdbc.Driver/#db.driver=com.mysql.jdbc.Driver/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
			sed -i.bak "s/#db.driver=org.postgresql.Driver/db.driver=org.postgresql.Driver/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
				
			sed -i.bak "s/db.port=3306/#db.port=3306/g"  $CATALINA_BASE/shared/classes/alfresco-global.properties
			sed -i.bak "s/#db.port=5432/db.port=5432/g"  $CATALINA_BASE/shared/classes/alfresco-global.properties
				
			sed -i.bak "s/db.url=jdbc:mysql.*/#db.url=jdbc:mysql/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
			sed -i.bak "s;#db.url=jdbc:postgresql.*;db.url=jdbc:postgresql://${db.host}:${db.port}/${db.name};g" $CATALINA_BASE/shared/classes/alfresco-global.properties
			
			sed -i.bak "s/db.pool.validate.query=.*/#db.pool.validate.query=/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		else 
			echored "You have installed and/or configured your PSQL Server manually"
		fi
	fi
}