#!/bin/bash
# -------
# Script for install of JASIG CAS to be used with Alfresco
# 
# Copyright 2014 ADN SYSTEMES / DIXINFOR, Yannick MOLINET
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
	SUDO=''
else
	SUDO='sudo'
fi

BASE_DOWNLOAD=https://raw.githubusercontent.com/dixinfor/alfresco-debian-install/master
JASIG_GIT=https://github.com/Jasig/cas.git
CATALINA_CONF="/etc/tomcat7"
APTVERBOSITY="-qq -y"
FQDN="adnprproxy01.systeme-d.local"
JASIG_WORK="/opt/work"

echoblue
echoblue "-----------------------------------------------------------------------"
echoblue "This script will install JASIG CAS Server"
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
echo "Installing Tomcat 7 ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install tomcat7 libtcnative-1

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing OpenJDK 7 ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install openjdk-7-jre openjdk-7-jdk

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Removing OpenJDK 6 ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY autoremove openjdk-6-jre-headless openjdk-6-jre-lib openjdk-6-jre

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing Apache2 with openssl, mod-jk, mod-auth-cas, ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install apache2 openssl libapache2-mod-jk libapache2-mod-auth-cas

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing Maven ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install maven 

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Installing Git ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
$SUDO apt-get $APTVERBOSITY install git 

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Retrieve auth-cas.conf ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
mkdir -p /var/cache/apache2/mod_auth_cas_cookies
$SUDO curl -# -o /etc/apache2/mods-available/auth_cas.conf $BASE_DOWNLOAD/apache2/auth_cas.conf
sed -i.bak -e "s;@@FQDN@@;$FQDN;g" /etc/apache2/mods-available/auth_cas.conf

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Update Apache2 mod_jk for Tomcat 7 ..."
echo "mod_jk is configured to use tomcat6 by default. Update path"
echo "mod_jk already have a worker, named ajp13_worker, define for localhost"
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sed -i.bak -e "s/tomcat6/tomcat7/g" /etc/libapache2-mod-jk/workers.properties

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Apache 2 Module Activation ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
a2enmod ssl
a2enmod auth_cas
a2enmod jk
a2ensite default-ssl

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Restart Apache 2 to load module ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
service apache2 restart

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Reconfiguration Tomcat 7 ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Stop Tomcat7 ..."
service tomcat7 stop

echo
echo "Update Tomcat 7 server.xml"
$SUDO curl -# -o $CATALINA_CONF/server.xml $BASE_DOWNLOAD/tomcat-alfresco/server.xml

echo "Generate keystore"
keytool -genkey -alias tomcat -keyalg RSA -storepass changeit -noprompt -validity 365 -keystore /usr/share/tomcat7/.keystore

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Downloading JASIG CAS ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
mkdir -p $JASIG_WORK
cd $JASIG_WORK
git clone https://github.com/UniconLabs/simple-cas4-overlay-template.git
cd $JASIG_WORK/simple-cas4-overlay-template

#TODO : Adjust log path
#TODO : Configuration for LDAP

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Compiling JASIG CAS ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
cd $JASIG_WORK/simple-cas4-overlay-template
mvn clean package

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Copying JASIG CAS ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
if [ -e $CATALINA_BASE/webapps/cas.war ]; then
	echo "Backing up existing cas.war"
	mv $CATALINA_BASE/webapps/cas.war $CATALINA_BASE/webapps/cas.war.old
fi
echo "Moving new cas.war to tomcat..."
mv $JASIG_WORK/simple-cas4-overlay-template/target/cas.war $CATALINA_BASE/webapps/cas.war

mkdir -p /etc/cas
cp $JASIG_WORK/simple-cas4-overlay-template/etc/cas.properties /etc/cas/cas.properties
cp $JASIG_WORK/simple-cas4-overlay-template/etc/log4j.xml /etc/cas/log4j.xml

echo
echo
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "Starting Tomcat ..."
echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
service tomcat7 start

