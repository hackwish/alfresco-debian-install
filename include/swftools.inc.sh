#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------



function AskForSwfTools() {
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
	  cd $TMPFOLDER
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
}