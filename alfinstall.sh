#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

export BASE_DOWNLOAD=https://raw.githubusercontent.com/dixinfor/alfresco-debian-install/master
export KEYSTOREBASE=http://svn.alfresco.com/repos/alfresco-open-mirror/alfresco/HEAD/root/projects/repository/config/alfresco/keystore

#Change this to prefered locale to make sure it exists. This has impact on LibreOffice transformations
export LOCALESUPPORT=sv_SE.utf8

export TOMCAT_DOWNLOAD=http://apache.mirrors.spacedump.net/tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56.tar.gz
export JDBCPOSTGRESURL=http://jdbc.postgresql.org/download
export JDBCPOSTGRES=postgresql-9.3-1102.jdbc41.jar
export JDBCMYSQLURL=http://cdn.mysql.com/Downloads/Connector-J
export JDBCMYSQL=mysql-connector-java-5.1.32.tar.gz

export LIBREOFFICE=http://download.documentfoundation.org/libreoffice/stable/4.2.6/deb/x86_64/LibreOffice_4.2.6-secfix_Linux_x86-64_deb.tar.gz

export SWFTOOLS=http://www.swftools.org/swftools-2013-04-09-1007.tar.gz

# Alfresco CE 5.0.b contains a bug with GoogleDocs not ready for use now : 
#	https://forums.alfresco.com/forum/installation-upgrades-configuration-integration/installation-upgrades/googledocs-failed-start
#	https://issues.alfresco.com/jira/browse/ACE-2320
# export GOOGLEDOCSREPO=http://dl.alfresco.com/release/community/5.0.b-build-00092/alfresco-googledocs-repo-2.0.7.amp
# export GOOGLEDOCSSHARE=http://dl.alfresco.com/release/community/5.0.b-build-00092/alfresco-googledocs-share-2.0.7.amp
# export ALFWARZIP=http://dl.alfresco.com/release/community/5.0.b-build-00092/alfresco-community-5.0.b.zip
# export SOLR=https://artifacts.alfresco.com/nexus/content/groups/public/org/alfresco/alfresco-solr/5.0.b/alfresco-solr-5.0.b-config.zip
# export SOLRWAR=https://artifacts.alfresco.com/nexus/content/groups/public/org/alfresco/alfresco-solr/5.0.b/alfresco-solr-5.0.b.war
# export SPP=https://artifacts.alfresco.com/nexus/content/groups/public/org/alfresco/alfresco-spp/5.0.b/alfresco-spp-5.0.b.amp

export ALFWARZIP=http://dl.alfresco.com/release/community/5.0.a-build-00023/alfresco-community-5.0.a.zip
export GOOGLEDOCSREPO=http://dl.alfresco.com/release/community/5.0.a-build-00023/alfresco-googledocs-repo-2.0.7.amp
export GOOGLEDOCSSHARE=http://dl.alfresco.com/release/community/5.0.a-build-00023/alfresco-googledocs-share-2.0.7.amp
export SOLR=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-solr/5.0.a/alfresco-solr-5.0.a-config.zip
export SOLRWAR=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-solr/5.0.a/alfresco-solr-5.0.a.war
export SPP=https://artifacts.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-spp/5.0.a/alfresco-spp-5.0.a.amp


export APTVERBOSITY="-qq -y"

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

echogreen "Cleanup Alfresco Install Temp Folder"
cd /tmp
if [ -d "alfrescoinstall" ]; then
	rm -rf alfrescoinstall
fi
mkdir alfrescoinstall
cd ./alfrescoinstall

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echogreen "Alfresco Ubuntu installer by Loftux AB."
echogreen "Updated by ADN SYSTEMES / DIXINFOR (Yannick MOLINET) to used on debian,"
echogreen "with more deb package, manage sudo capacities, and installed some services remotly"
echogreen "Please read the documentation at"
echogreen "Original: https://github.com/loftuxab/alfresco-ubuntu-install"
echogreen "Fork : https://github.com/dixinfor/alfresco-debian-install"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Using sudo ? ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
read -e -p "Use sudo${ques} [y/n] " -i "n" usesudo
if [ "$usepack" = "y" ]; then
	if [ "`which sudo`" = "" ]; then
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "You need to install sudo."
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		apt-get $APTVERBOSITY install sudo;
	else
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		echo "sudo detected ..."
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	fi
	SUDO=`sudo`
else
	SUDO=''
fi

echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "expect is required to execute remote ssh command."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

if [ "`which expect`" = "" ]; then
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to install expect."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	apt-get $APTVERBOSITY install expect
else
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "expect detected ..."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing Method ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
read -e -p "Use maximum system package (all except swftools)${ques} [y/n] " -i "y" usepack
if [ "$usepack" = "y" ]; then
	# export ALF_HOME=/opt/alfresco
	export CATALINA_HOME=/usr/share/tomcat7
	export CATALINA_BASE=/var/lib/tomcat7
	export CATALINA_CONF=/etc/tomcat7
	export CATALINA_PID=/var/run/tomcat7.pid
	export ALF_USER=tomcat7
	declare -a REMOTEFILES=($SWFTOOLS $ALFWARZIP $GOOGLEDOCSREPO $GOOGLEDOCSSHARE $SOLR $SPP)
else
	# export ALF_HOME=/opt/alfresco
	export CATALINA_HOME=$ALF_HOME/tomcat
	export CATALINA_BASE=$ALF_HOME/tomcat
	export CATALINA_CONF=$ALF_HOME/tomcat/conf
	export CATALINA_PID=$ALF_HOME/tomcat.pid
	export ALF_USER=alfresco
	declare -a REMOTEFILES=($TOMCAT_DOWNLOAD $JDBCPOSTGRESURL/$JDBCPOSTGRES $JDBCMYSQLURL/$JDBCMYSQL $LIBREOFFICE $SWFTOOLS $ALFWARZIP $GOOGLEDOCSREPO $GOOGLEDOCSSHARE $SOLR $SPP)
fi

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
	
	$SUDO curl -# -o /etc/init/alfresco.conf $BASE_DOWNLOAD/tomcat/alfresco.conf
	$SUDO sed -i "s/@@LOCALESUPPORT@@/$LOCALESUPPORT/g" /etc/init/alfresco.conf
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Preparing for install. Updating the apt package index files..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY update;
echo

if [ "`which curl`" = "" ]; then
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "You need to install curl. Curl is used for downloading components to install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install curl;
fi

# Only necessary when Tomcat is installed from source. User Tomcat7 is created with package installer
if [ "$usepack" = "n" ]; then
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "You need to add a system user that runs the tomcat Alfresco instance."
	echo "Also updates locale support."
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	read -e -p "Add alfresco system user${ques} [y/n] " -i "n" addalfresco
	if [ "$addalfresco" = "y" ]; then
	  $SUDO adduser --system --no-create-home --disabled-login --disabled-password --group $ALF_USER
	  echo
	  echo "Adding locale support"
	  #install locale to support that locale date formats in open office transformations
	  $SUDO locale-gen $LOCALESUPPORT
	  echo
	  echogreen "Finished adding alfresco user"
	  echo
	else
	  echo "Skipping adding alfresco user"
	  echo
	fi
fi

echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
echo "Do you want to install remote GlusterFS Server ?"
echo "Each server must have the same root password"
echo "This script don't configure specific network configuration as Jumbo Frame"
echo "or specific file systeme configuration"
echo "It's recommended to put brick on a XFS FileSystem"
echo "Each GlusterFS Server mount a folder (brick) as part of the GlusterFS Volume"
echo "The first server you enter is consider as a 'Master' server"
echo "and is used to create GlusterFS Volume and probe other peer"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
read -e -p "Do you want to install remote GlusterFS Server${ques} [y/n] " -i "n" glusterfsserver
if [ "$glusterfsserver" = "y" ]; then
	server=()
	echo
	read -e -p "How many remote server to install in the GlusterFS Cluster${ques} [1] " -i "1" glustercount
	for (( i = 0 ; i < $glustercount ; i++ )) do
		read -e -p "Enter the Peer's IP:" peerip
		server+=($peerip)
	done
	
	GLUSTERTYPE=
	if [ $glustercount -gt 1 ]; then
		echo
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
		echo "You must defined the Volume Type for your storage environnement."
		echo "GlusterFS allow : Distributed, Replicated, Striped, Distributed Striped, Distributed Replicated."
		echo "See what you need on GlusterFS website : http://gluster.org/community/documentation/index.php/Gluster_3.2:_Setting_Up_GlusterFS_Server_Volumes"		
		echo
		echored "!!! ONLY Distributed, Replicated, Striped IS MANAGE BY THIS SCRIPT !!!"
		echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
		read -e -p "Define your volume type:" glustervoltype
		if [[ "$glustervoltype" = "distributed" || "$glustervoltype" = "Distributed" ]]
		then
			GLUSTERTYPE=""
		fi
		if [[ "$glustervoltype" = "replicated" || "$glustervoltype" = "Replicated" ]]
		then
			GLUSTERTYPE="replica $glustercount"
		fi
		if [[ "$glustervoltype" = "striped" || "$glustervoltype" = "Striped" ]]
		then
			GLUSTERTYPE="stripe $glustercount" 
		fi
		
		# Maybe be later ...
		#if [[ "$glustervoltype" = "Distributed Striped" || "$glustervoltype" = "distributed striped" || "$glustervoltype" = "Distributed striped" || "$glustervoltype" = "distributed Striped" ]];
		#fi
		#if [[ "$glustervoltype" = "Distributed Replicated" || "$glustervoltype" = "distributed replicated" || "$glustervoltype" = "Distributed replicated" || "$glustervoltype" = "distributed Replicated" ]];
		#fi
	else
		GLUSTERTYPE=""
	fi
	
	read -e -p "Brick location: " -i "/srv/brick" GLUSTERFOLDER
	read -e -p "Volume name: " -i "alfdata" GLUSTERVOLUME
	
	read -e -p "Which interface do you use to access GlusterFS Server ? (eth0) " -i "eth0" glusteriface
	localip=`ifconfig $glusteriface | grep -Eo 'inet (adr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
	
	read -e -p "Enter root password for GlusterFS Peers: " glusterpwd
	
	cd /tmp/alfrescoinstall
	if [ ! -f "/tmp/alfrescoinstall/remote-script.sh" ]; then
		echo "Downloading script to install remotly ..."
		$SUDO curl -# -o /tmp/alfrescoinstall/remote-script.sh $BASE_DOWNLOAD/scripts/remote-script.sh
	fi

	if [ ! -f "/tmp/alfrescoinstall/glusterfs.sh" ]; then
		echo "Downloading script to install glusterfs ..."
		$SUDO curl -# -o /tmp/alfrescoinstall/glusterfs-slave.sh $BASE_DOWNLOAD/scripts/glusterfs.sh
	fi
	
	$SUDO chmod u+x /tmp/alfrescoinstall/*.sh
	
	sed -i.bak -e "s/GLUSTERPEERS=.*/GLUSTERPEERS=$server/g" /tmp/alfrescoinstall/glusterfs-slave.sh
	sed -i.bak -e "s/ALFRESCOSERVER=.*/ALFRESCOSERVER=$localip/g" /tmp/alfrescoinstall/glusterfs-slave.sh
	sed -i.bak -e "s;GLUSTERFOLDER=.*;GLUSTERFOLDER=$GLUSTERFOLDER;g" /tmp/alfrescoinstall/glusterfs-slave.sh
	sed -i.bak -e "s/GLUSTERVOLUME=.*/GLUSTERVOLUME=$GLUSTERVOLUME/g" /tmp/alfrescoinstall/glusterfs-slave.sh

	cp /tmp/alfrescoinstall/glusterfs-slave.sh /tmp/alfrescoinstall/glusterfs-master.sh

	sed -i.bak -e "s/GLUSTERMASTER=.*/GLUSTERMASTER=y/g" /tmp/alfrescoinstall/glusterfs-master.sh
	sed -i.bak -e "s/GLUSTERTYPE=.*/GLUSTERTYPE=$GLUSTERTYPE/g"  /tmp/alfrescoinstall/glusterfs-master.sh
	
	cp /tmp/alfrescoinstall/remote-script.sh /tmp/alfrescoinstall/remote-glusterfs-master.sh
	cp /tmp/alfrescoinstall/remote-script.sh /tmp/alfrescoinstall/remote-glusterfs-slave.sh
	$SUDO chmod u+x /tmp/alfrescoinstall/*.sh
	
	sed -i.bak -e "s/set rootpassword.*/set rootpassword $glusterpwd/g" /tmp/alfrescoinstall/remote-glusterfs-master.sh
	sed -i.bak -e "s/set rootpassword.*/set rootpassword $glusterpwd/g" /tmp/alfrescoinstall/remote-glusterfs-slave.sh
	
	sed -i.bak -e "s/set filename.*/set filename glusterfs-master.sh/g" /tmp/alfrescoinstall/remote-glusterfs-master.sh
	sed -i.bak -e "s;set fullpath.*;set fullpath /tmp/alfrescoinstall/glusterfs-master.sh;g" /tmp/alfrescoinstall/remote-glusterfs-master.sh

	sed -i.bak -e "s/set filename.*/set filename glusterfs-slase.sh/g" /tmp/alfrescoinstall/remote-glusterfs-slave.sh
	sed -i.bak -e "s;set fullpath.*;set fullpath /tmp/alfrescoinstall/glusterfs-slave.sh;g" /tmp/alfrescoinstall/remote-glusterfs-slave.sh
	
	echogreen "Number of peers found:  ${#server[@]}"
	
	
	for (( i = ${#server[@]}; i > 0 ; i-- )) do
		if [[ $i -eq 1 ]]
		then
			echogreen "Execute GlusterFS Server Installation Script on 'Master' Server: ${server[$i-1]}"
			sed -i.bak -e "s/set remoteip.*/set remoteip ${server[$i-1]}/g" /tmp/alfrescoinstall/remote-glusterfs-master.sh
			/tmp/alfrescoinstall/remote-glusterfs-master.sh
		else
			echogreen "Execute GlusterFS Server Installation Script on 'Slave' Server: ${server[$i-1]}"
			sed -i.bak -e "s/set remoteip.*/set remoteip ${server[$i-1]}/g" /tmp/alfrescoinstall/remote-glusterfs-slave.sh
			/tmp/alfrescoinstall/remote-glusterfs-slave.sh
		fi
	done
	
fi
  

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Ubuntu/Debian default for number of allowed open files in the file system is too low"
echo "for alfresco use and tomcat may because of this stop with the error"
echo "\"too many open files\". You should update this value if you have not done so."
echo "Read more at http://wiki.alfresco.com/wiki/Too_many_open_files"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Add limits.conf${ques} [y/n] " -i "y" updatelimits
if [ "$updatelimits" = "y" ]; then
  echo "$ALF_USER  soft  nofile  8192" | $SUDO tee -a /etc/security/limits.conf
  echo "$ALF_USER  hard  nofile  65536" | $SUDO tee -a /etc/security/limits.conf
  echo
  echogreen "Updated limits.conf"
  echo
else
  echo "Skipped updating limits.conf"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo " Define Alfresco Home Path ..."
echo " You can change (not recommanded) default Alfresco Home Path"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo
read -e -p "Define the Alfresco Home Path (not recommanded, default is /opt/alfresco)${ques}" -i "/opt/alfresco" alfhome
export ALF_HOME=$alfhome
echo


echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
echo " Do you want to mount Alfresco Primary ContentStore on a GlusterFS mount point ($ALF_HOME/alf_data)? "
echo " This part don't install any remote service. You must have a valid GlusterFS server available with correct permissions set"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
echo
read -e -p "Do you want to mount alf_data on remote GlusterFS ? [y/n]" -i "n" mount
if [ "$mount" = "y" ]; then
	example="GFS-SRV01:gfsvol"
	if [ "$glusterfsserver" = "y" ]; then
		example="${server[0]}:$GLUSTERVOLUME"
	fi
	
	read -e -p "Specify remote GlusterFS path (ex. $example):" gfspath
	$SUDO apt-get $APTVERBOSITY install glusterfs-client
	mkdir -p $ALF_HOME/alf_data
	mount -t glusterfs $gfspath $ALF_HOME/alf_data
	echo "$gfspath  $ALF_HOME/alf_data    glusterfs       defaults,_netdev        0       0" >> /etc/fstab
fi
echo

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Tomcat is the application server that runs Alfresco."
echo "You will also get the option to install jdbc lib for Postgresql or MySql/MariaDB."
echo "Install the jdbc lib for the database you intend to use."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Tomcat${ques} [y/n] " -i "y" installtomcat

if [ "$installtomcat" = "y" ]; then
  echogreen "Installing Tomcat"
  if [ "$usepack" = "y" ]; then
		echo "Installing tomcat from package..."
		$SUDO apt-get $APTVERBOSITY install tomcat7 libtcnative-1
		service tomcat7 stop
		
		sed -i.bak -e "s/-Xmx128m/-Xms1G -Xmx2G -Xss1024k -XX:MaxPermSize=256m/g" /etc/default/tomcat7
	
  else
	  echo "Downloading tomcat..."
	  curl -# -L -O $TOMCAT_DOWNLOAD
	  # Make sure install dir exists
	  $SUDO mkdir -p $ALF_HOME
	  echo "Extracting..."
	  tar xf "$(find . -type f -name "apache-tomcat*")"
	  $SUDO mv "$(find . -type d -name "apache-tomcat*")" $CATALINA_HOME
  fi
  
  # Remove apps not needed -- Why, keep default files to check if tomcat is working.
  # $SUDO rm -rf $CATALINA_BASE/webapps/*
  
  # Get Alfresco config
  echo "Downloading tomcat configuration files..."
  $SUDO curl -# -o $CATALINA_CONF/server.xml $BASE_DOWNLOAD/tomcat/server.xml
  $SUDO curl -# -o $CATALINA_CONF/catalina.properties $BASE_DOWNLOAD/tomcat/catalina.properties

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
  ALFRESCO_GLOBAL_PROPERTIES=/tmp/alfrescoinstall/alfresco-global.properties
  $SUDO curl -# -o $ALFRESCO_GLOBAL_PROPERTIES $BASE_DOWNLOAD/tomcat/alfresco-global.properties
  sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_SHARE_SERVER_PORT@@/$SHARE_PORT/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_SHARE_SERVER_PROTOCOL@@/$SHARE_PROTOCOL/g" $ALFRESCO_GLOBAL_PROPERTIES
  sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $ALFRESCO_GLOBAL_PROPERTIES
  $SUDO mv $ALFRESCO_GLOBAL_PROPERTIES $CATALINA_BASE/shared/classes/

  read -e -p "Install Share config file (recommended)${ques} [y/n] " -i "y" installshareconfig
  if [ "$installshareconfig" = "y" ]; then
    SHARE_CONFIG_CUSTOM=/tmp/alfrescoinstall/share-config-custom.xml
    $SUDO curl -# -o $SHARE_CONFIG_CUSTOM $BASE_DOWNLOAD/tomcat/share-config-custom.xml
    sed -i "s/@@ALFRESCO_SHARE_SERVER@@/$SHARE_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
    sed -i "s/@@ALFRESCO_REPO_SERVER@@/$REPO_HOSTNAME/g" $SHARE_CONFIG_CUSTOM
    $SUDO mv $SHARE_CONFIG_CUSTOM $CATALINA_BASE/shared/classes/alfresco/web-extension/
  fi

  echo
  read -e -p "Install Postgres JDBC Connector${ques} [y/n] " -i "y" installpg
  if [ "$installpg" = "y" ]; then
	if [ "$usepack" = "y" ]; then
		$SUDO apt-get $APTVERBOSITY install libpostgresql-jdbc-java
		 ln -s /usr/share/java/postgresql.jar /usr/share/tomcat7/lib/postgresql.jar
	else
		curl -# -O $JDBCPOSTGRESURL/$JDBCPOSTGRES
		$SUDO mv $JDBCPOSTGRES $CATALINA_HOME/lib
	fi
  else
	echo
	read -e -p "Install Mysql JDBC Connector${ques} [y/n] " -i "n" installmy
	if [ "$installmy" = "y" ]; then
		if [ "$usepack" = "y" ]; then
			$SUDO apt-get $APTVERBOSITY install libmysql-java
		else
			cd /tmp/alfrescoinstall
			curl -# -L -O $JDBCMYSQLURL/$JDBCMYSQL
			tar xf $JDBCMYSQL
			cd "$(find . -type d -name "mysql-connector*")"
			$SUDO mv mysql-connector*.jar $CATALINA_HOME/lib
		fi
	fi
	$SUDO chown -R $ALF_USER:$ALF_USER $CATALINA_HOME
  fi
  echo
  echogreen "Finished installing Tomcat"
  echo
else
  echo "Skipping install of Tomcat"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Nginx can be used as frontend to Tomcat."
echo "This installation will add config default proxying to Alfresco tomcat."
echo "The config file also have sample config for ssl and proxying"
echo "to Sharepoint plugin."
echo "You can run Alfresco fine without installing nginx."
echo "If you prefer to use Apache, install that manually. Or you can use iptables"
echo "forwarding, sample script in $ALF_HOME/scripts/iptables.sh"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install nginx${ques} [y/n] " -i "n" installnginx
if [ "$installnginx" = "y" ]; then
  echoblue "Installing nginx. Fetching packages..."
  echo
$SUDO -s << EOF
  echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" >> /etc/apt/sources.list
  $SUDO curl -# -o /tmp/alfrescoinstall/nginx_signing.key http://nginx.org/keys/nginx_signing.key
  apt-key add /tmp/alfrescoinstall/nginx_signing.key
  #echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C
  # Alternate with spdy support and more, change  apt install -> nginx-custom
  #echo "deb http://ppa.launchpad.net/brianmercer/nginx/ubuntu $(lsb_release -cs) main" >> /etc/apt/sources.list
  #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D0DC64F
EOF
  $SUDO apt-get $APTVERBOSITY update && $SUDO apt-get $APTVERBOSITY install nginx
  $SUDO mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
  $SUDO curl -# -o /etc/nginx/nginx.conf $BASE_DOWNLOAD/nginx/nginx.conf
  $SUDO mkdir -p /var/cache/nginx/alfresco
  $SUDO mkdir -p $ALF_HOME/www
  if [ ! -f "$ALF_HOME/www/maintenance.html" ]; then
    echo "Downloading maintenance html page..."
    $SUDO curl -# -o $ALF_HOME/www/maintenance.html $BASE_DOWNLOAD/nginx/maintenance.html
  fi
  $SUDO chown -R www-data:root /var/cache/nginx/alfresco
  $SUDO chown -R www-data:root $ALF_HOME/www
  ## Reload config file
  $SUDO service nginx reload

  echo
  echogreen "Finished installing nginx"
  echo
else
  echo "Skipping install of nginx"
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Java JDK."
echo "This will install the OpenJDK 7 version of Java. If you prefer Oracle Java"
echo "you need to download and install that manually."
echo "If OpenJDK6 is installed, it will be removed".
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install OpenJDK7${ques} [y/n] " -i "y" installjdk
if [ "$installjdk" = "y" ]; then
  echoblue "Installing OpenJDK7. Fetching packages..."
  $SUDO apt-get $APTVERBOSITY install openjdk-7-jdk
  $SUDO apt-get $APTVERBOSITY autoremove openjdk-6-jre-headless openjdk-6-jre-lib openjdk-6-jre
  echo
  echogreen "Finished installing OpenJDK"
  echo
else
  echo "Skipping install of OpenJDK 7"
  echored "IMPORTANT: You need to install other JDK and adjust paths for the install to be complete"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install LibreOffice."
echo "This will download and install the latest LibreOffice from libreoffice.org"
echo "Newer version of Libreoffice has better document filters, and produce better"
echo "transformations. If you prefer to use Ubuntu standard packages you can skip"
echo "this install."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install LibreOffice${ques} [y/n] " -i "y" installibreoffice
if [ "$installibreoffice" = "y" ]; then
	if [ "$usepack" = "y" ]; then
		$SUDO apt-get $APTVERBOSITY install libreoffice
		OOOEXE="/usr/lib/libreoffice/program/soffice.bin"
	else
		cd /tmp/alfrescoinstall
		curl -# -L -O $LIBREOFFICE
		tar xf LibreOffice*.tar.gz
		cd "$(find . -type d -name "LibreOffice*")"
		cd DEBS
		$SUDO dpkg -i *.deb
		OOOEXE="/opt/libreoffice4.2/program/soffice.bin"
	fi
	echoblue "Update alfresco-global.properties"
	sed -i.bak -e "s;ooo.exe=.*;ooo.exe=$OOOEXE;g" $CATALINA_BASE/shared/classes/alfresco-global.properties
	echo
	
	echo
	echoblue "Installing some support fonts for better transformations."
	$SUDO apt-get $APTVERBOSITY install ttf-mscorefonts-installer fonts-droid
	echo
	echogreen "Finished installing LibreOffice"
	echo
else
  echo
  echo "Skipping install of LibreOffice"
  echored "If you install LibreOffice/OpenOffice separetely, remember to update alfresco-global.properties"
  echored "Also run: $SUDO apt-get install ttf-mscorefonts-installer fonts-droid"
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install ImageMagick."
echo "This will ImageMagick from Ubuntu packages."
echo "It is recommended that you install ImageMagick."
echo "If you prefer some other way of installing ImageMagick, skip this step."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install ImageMagick${ques} [y/n] " -i "y" installimagemagick
if [ "$installimagemagick" = "y" ]; then

  echoblue "Installing ImageMagick. Fetching packages..."
  $SUDO apt-get $APTVERBOSITY install imagemagick ghostscript libgs-dev libjpeg62 libpng3
  echo
  IMAGEMAGICKVERSION=`ls /usr/lib/|grep -i imagemagick`
  echoblue "Creating symbolic link for ImageMagick."
  $SUDO ln -s /usr/lib/$IMAGEMAGICKVERSION /usr/lib/ImageMagick
  echo
  echogreen "Finished installing ImageMagick"
  echo
else
  echo
  echo "Skipping install of ImageMagick"
  echored "Remember to install ImageMagick later. It is needed for thumbnail transformations."
  echo
fi

echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Install Swftools."
echo "This will download and install swftools used for transformations to Flash."
echo "Since the swftools Ubuntu package is not included in all versions of Ubuntu,"
echo "this install downloads from swftools.org and compiles."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
read -e -p "Install Swftools${ques} [y/n] " -i "y" installswftools

if [ "$installswftools" = "y" ]; then
  echoblue "Installing build tools and libraries needed to compile swftools. Fetching packages..."
  $SUDO apt-get $APTVERBOSITY install make build-essential ccache g++ libgif-dev libjpeg62-dev libfreetype6-dev libpng12-dev libt1-dev
  cd /tmp/alfrescoinstall
  echo "Downloading swftools..."
  curl -# -O $SWFTOOLS
  tar xf swftools*.tar.gz
  cd "$(find . -type d -name "swftools*")"
  ./configure
  $SUDO make && $SUDO make install
  echo
  echogreen "Finished installing Swftools"
  echo
else
  echo
  echo "Skipping install of Swftools."
  echored "Remember to install swftools via Ubuntu packages or by any other mean."
  echo
fi

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

  
  $SUDO chmod u+x $ALF_HOME/scripts/*.sh

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
  mkdir -p /tmp/alfrescoinstall/war
  cd /tmp/alfrescoinstall/war

  $SUDO apt-get $APTVERBOSITY install unzip
  echo "Downloading war files..."
  curl -# -o /tmp/alfrescoinstall/war/alfwar.zip $ALFWARZIP
  unzip -q -j alfwar.zip
  $SUDO cp /tmp/alfrescoinstall/war/*.war $ALF_HOME/addons/war/
  $SUDO rm -rf /tmp/alfrescoinstall/war

  cd /tmp/alfrescoinstall
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
  $SUDO curl -# -o $CATALINA_CONF/tomcat-users.xml $BASE_DOWNLOAD/tomcat/tomcat-users.xml
  cd $ALF_HOME/solr/

  $SUDO unzip -q solr.zip
  # Set the solr data path
  SOLRDATAPATH="$ALF_HOME/alf_data/solr"
  # Escape for sed
  SOLRDATAPATH="${SOLRDATAPATH//\//\\/}"

  $SUDO mv $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties.orig
  $SUDO mv $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties.orig
  sed "s/@@ALFRESCO_SOLR_DIR@@/$SOLRDATAPATH/g" $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties.orig > /tmp/alfrescoinstall/solrcore.properties
  $SUDO mv /tmp/alfrescoinstall/solrcore.properties $ALF_HOME/solr/workspace-SpacesStore/conf/solrcore.properties
  sed "s/@@ALFRESCO_SOLR_DIR@@/$SOLRDATAPATH/g" $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties.orig > /tmp/alfrescoinstall/solrcore.properties
  $SUDO mv /tmp/alfrescoinstall/solrcore.properties $ALF_HOME/solr/archive-SpacesStore/conf/solrcore.properties
  SOLRDATAPATH="$ALF_HOME/solr"

  echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > /tmp/alfrescoinstall/solr.xml
  echo "<Context docBase=\"$ALF_HOME/solr/apache-solr-1.4.1.war\" debug=\"0\" crossContext=\"true\">" >> /tmp/alfrescoinstall/solr.xml
  echo "  <Environment name=\"solr/home\" type=\"java.lang.String\" value=\"$ALF_HOME/solr\" override=\"true\"/>" >> /tmp/alfrescoinstall/solr.xml
  echo "</Context>" >> /tmp/alfrescoinstall/solr.xml
  $SUDO mv /tmp/alfrescoinstall/solr.xml $CATALINA_CONF/Catalina/localhost/solr.xml

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

echo
echogreen "- - - - - - - - - - - - - - - - -"
echo "Scripted install complete"
echored "Manual tasks remaining:"
if [ "$installpsql" = "n" ]; then
	echo "1. Add database. Install scripts available in $ALF_HOME/scripts"
	echored "   It is however recommended that you use a separate database server."
fi
echo "2. Verify Tomcat memory and locale settings in /etc/init/alfresco.conf (FOR UBUNTU)"
echo "   /etc/default/tomcat7 (FOR DEBIAN)"
echo "   Alfresco runs best with lots of memory. Add some more to \"lots\" and you will be fine!"
echo "   Match the locale LC_ALL (or remove) setting to the one used in this script."
echo "   Locale setting is needed for LibreOffice date handling support."
echo "3. Update database and other settings in alfresco-global.properties"
echo "   You will find this file in $CATALINA_BASE/shared/classes"
echo "4. Update cpu settings in $ALF_HOME/scripts/limitconvert.sh if you have more than 2 cores."
echo "5. Start nginx if you have installed it: /etc/init.d/nginx start"

read -e -p "Do you want to start tomcat now ?[y/n]" -i "y" start
if [ "$start" = "y" ]; then
	if [ "$usepack" = "y" ]; then
		service tomcat7 start
	else 
		service alfresco start
	fi
else
	echo "6. Start Alfresco/tomcat: $SUDO service alfresco start"
	echo
fi
