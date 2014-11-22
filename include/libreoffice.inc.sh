#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForLibreOffice() {
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
			cd $TMPFOLDER
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
}
