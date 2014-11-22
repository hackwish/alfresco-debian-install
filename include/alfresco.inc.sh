#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function InstallAlfresco() {
	echo
	echoblue "Adding basic support files. Always installed if not present."
	echo
	# Always add the addons dir and scripts
	  $SUDO mkdir -p $ALF_HOME/addons/war
	  $SUDO mkdir -p $ALF_HOME/addons/share
	  $SUDO mkdir -p $ALF_HOME/addons/alfresco
	  if [ ! -f "$ALF_HOME/addons/apply.sh" ]; then
		echo "Downloading apply.sh script..."
		$SUDO curl -# -o $ALF_HOME/addons/apply.sh $BASE_DOWNLOAD/scripts/apply.sh
		$SUDO chmod u+x $ALF_HOME/addons/apply.sh

		sed -i.bak -e "s;export ALF_HOME=.*$;export ALF_HOME=${ALF_HOME};g" $ALF_HOME/addons/apply.sh
		sed -i.bak -e "s;export CATALINA_HOME=.*$;export CATALINA_HOME=${CATALINA_HOME};g"  $ALF_HOME/addons/apply.sh
		sed -i.bak -e "s;export CATALINA_BASE=.*$;export CATALINA_BASE=${CATALINA_BASE};g"  $ALF_HOME/addons/apply.sh
		sed -i.bak -e "s;export CATALINA_CONF=.*$;export CATALINA_CONF=${CATALINA_CONF};g"  $ALF_HOME/addons/apply.sh	
		sed -i.bak -e "s;export CATALINA_PID=.*$;export CATALINA_PID=${CATALINA_PID};g"  $ALF_HOME/addons/apply.sh
		sed -i.bak -e "s;export ALF_USER=.*$;export ALF_USER=${ALF_USER};g"  $ALF_HOME/addons/apply.sh
		
		fi
	  if [ ! -f "$ALF_HOME/addons/alfresco-mmt.jar" ]; then
		$SUDO curl -# -o $ALF_HOME/addons/alfresco-mmt.jar $BASE_DOWNLOAD/scripts/alfresco-mmt.jar
	  fi

	  # Keystore
	  $SUDO mkdir -p $ALF_HOME/alf_data/keystore
	  # Only check for precesence of one file, assume all the rest exists as well if so.
	  if [ ! -f "$ALF_HOME/alf_data/keystore/ssl.keystore" ]; then
		echo "Downloading keystore files..."
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/browser.p12 $KEYSTOREBASE/browser.p12
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/generate_keystores.sh $KEYSTOREBASE/generate_keystores.sh
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/keystore $KEYSTOREBASE/keystore
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/keystore-passwords.properties $KEYSTOREBASE/keystore-passwords.properties
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/ssl-keystore-passwords.properties $KEYSTOREBASE/ssl-keystore-passwords.properties
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/ssl-truststore-passwords.properties $KEYSTOREBASE/ssl-truststore-passwords.properties
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/ssl.keystore $KEYSTOREBASE/ssl.keystore
		$SUDO curl -# -o $ALF_HOME/alf_data/keystore/ssl.truststore $KEYSTOREBASE/ssl.truststore
	  fi

	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Install Alfresco war files."
	echo "Download war files and optional addons."
	echo "If you have downloaded your war files you can skip this step add them manually."
	echo "This install place downloaded files in the $ALF_HOME/addons and then use the"
	echo "apply.sh script to add them to tomcat/webapps. Se this script for more info."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Add Alfresco war files${ques} [y/n] " -i "y" installwar
	if [ "$installwar" = "y" ]; then

	  # Make extract dir
	  mkdir -p $TMPFOLDER/war
	  cd $TMPFOLDER/war

	  $SUDO apt-get $APTVERBOSITY install unzip
	  echo "Downloading war files..."
	  curl -# -o $TMPFOLDER/war/alfwar.zip $ALFWARZIP
	  unzip -q -j alfwar.zip
	  $SUDO cp $TMPFOLDER/war/*.war $ALF_HOME/addons/war/
	  $SUDO rm -rf $TMPFOLDER/war

	  cd $TMPFOLDER
	  read -e -p "Add Google docs integration${ques} [y/n] " -i "y" installgoogledocs
	  if [ "$installgoogledocs" = "y" ]; then
		echo "Downloading Google docs addon..."
		curl -# -O $GOOGLEDOCSREPO
		$SUDO mv alfresco-googledocs-repo*.amp $ALF_HOME/addons/alfresco/
		curl -# -O $GOOGLEDOCSSHARE
		$SUDO mv alfresco-googledocs-share* $ALF_HOME/addons/share/
	  fi

	  read -e -p "Add Sharepoint plugin${ques} [y/n] " -i "y" installspp
	  if [ "$installspp" = "y" ]; then
		echo "Downloading Sharepoint addon..."
		curl -# -O $SPP
		$SUDO mv alfresco-spp*.amp $ALF_HOME/addons/alfresco/
	  fi

	  $SUDO $ALF_HOME/addons/apply.sh all

	  echo
	  echogreen "Finished adding Alfresco war files"
	  echo
	else
	  echo
	  echo "Skipping adding Alfresco war files"
	  echo
	fi

	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "Install Solr indexing engine."
	echo "You have a choice lucene (default) or Solr as indexing engine."
	echo "Solr runs as a separate application and is slightly more complex to configure."
	echo "As Solr is more advanced and handle multilingual better it is recommended that"
	echo "you install Solr."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Install Solr indexing engine${ques} [y/n] " -i "y" installsolr
	if [ "$installsolr" = "y" ]; then

	  $SUDO mkdir -p $ALF_HOME/solr
	  $SUDO mkdir -p $CATALINA_CONF/Catalina/localhost
	  $SUDO curl -# -o $ALF_HOME/solr/solr.zip $SOLR
	  $SUDO curl -# -o $ALF_HOME/solr/apache-solr-1.4.1.war $SOLRWAR
	  $SUDO curl -# -o $CATALINA_CONF/tomcat-users.xml $BASE_DOWNLOAD/tomcat-alfresco/tomcat-users.xml
	  cd $ALF_HOME/solr/

	  $SUDO unzip -q solr.zip
	  # Set the solr data path
	  SOLRDATAPATH="$ALF_HOME/alf_data/solr"
	  # Escape for sed
	  SOLRDATAPATH="${SOLRDATAPATH//\//\\/}"

	  $SUDO mv $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties.orig
	  $SUDO mv $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties.orig
	  sed "s/@@ALFRESCO_SOLR_DIR@@/$SOLRDATAPATH/g" $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties.orig > $TMPFOLDER/solrcore.properties
	  $SUDO mv $TMPFOLDER/solrcore.properties $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties
	  sed "s/@@ALFRESCO_SOLR_DIR@@/$SOLRDATAPATH/g" $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties.orig > $TMPFOLDER/solrcore.properties
	  $SUDO mv $TMPFOLDER/solrcore.properties $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties
	  SOLRDATAPATH="$ALF_HOME/solr"

	  echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $TMPFOLDER/solr.xml
	  echo "<Context docBase=\"$ALF_HOME/solr/apache-solr-1.4.1.war\" debug=\"0\" crossContext=\"true\">" >> $TMPFOLDER/solr.xml
	  echo "  <Environment name=\"solr/home\" type=\"java.lang.String\" value=\"$ALF_HOME/solr\" override=\"true\"/>" >> $TMPFOLDER/solr.xml
	  echo "</Context>" >> $TMPFOLDER/solr.xml
	  $SUDO mv $TMPFOLDER/solr.xml $CATALINA_CONF/Catalina/localhost/solr.xml

	  # Remove some unused stuff
	  $SUDO rm $ALF_HOME/solr/solr.zip

	  sed -i.bak -e "s/index.subsystem.name=.*/index.subsystem.name=solr/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
	  
	  echo
	  echogreen "Finished installing Solr engine."
	  echo
	else
	  echo
	  echo "Skipping installing Solr."
	  echo "You can always install Solr at a later time."
	  echo
	fi

	$SUDO chown -R $ALF_USER:$ALF_USER $ALF_HOME
	if [ -d "$ALF_HOME/www" ]; then
	   $SUDO chown -R www-data:root $ALF_HOME/www
	fi

	read -e -p "Enable Alfresco IMAP Server ${ques} [y/n] " -i "y" imap
	if [ "$imap" = "y" ]; then
		read -e -p "On which interface (eth0) ${ques}" -i "eth0" ifmap
		bindimap=`ifconfig $ifmap | grep -Eo 'inet (adr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
		
		sed -i.bak "s/#imap.server.enabled=.*/imap.server.enabled=true/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		sed -i.bak "s/#imap.server.port=.*/imap.server.port=143/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		sed -i.bak "s/#imap.server.host=.*/imap.server.host=$bindimap/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
	fi

	read -e -p "Keep default port for CIFS ? [y/n] " -i "y" cifsports
	if [ "$cifsports" = "y" ]; then
		sed -i.bak -e "s/cifs.tcpipSMB.port=1445/cifs.tcpipSMB.port=445/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		sed -i.bak -e "s/cifs.netBIOSSMB.sessionPort=1139/cifs.netBIOSSMB.sessionPort=139/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		sed -i.bak -e "s/cifs.netBIOSSMB.namePort=1137/cifs.netBIOSSMB.namePort=137/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		sed -i.bak -e "s/cifs.netBIOSSMB.datagramPort=1138/cifs.netBIOSSMB.datagramPort=1138/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
	else
		echored "Keep CIFS ports providing by Loftuxab !";
	fi

	read -e -p "Enable FTP Server ? [y/n] " -i "y" ftp
	if [ "$ftp" = "y" ]; then
		sed -i.bak -e "s/ftp.enabled=false/ftp.enabled=true/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		read -e -p "Keep default port for FTP ? [y/n] " -i "y" ftpports
		if [ "$ftpports" = "y" ]; then
			sed -i.bak -e "s/ftp.port=2021/ftp.port=21/g" $CATALINA_BASE/shared/classes/alfresco-global.properties
		else
			echored "Keep ports providing by Loftusab !";
		fi
	else
		echored "FTP Server disabled !"
	fi
}

function UpdateAlfrescoGlobalProperties() {
	echoblue "Update alfresco-global.properties"
	if [ "$installpsql" = "y" ]; then
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
	fi
}