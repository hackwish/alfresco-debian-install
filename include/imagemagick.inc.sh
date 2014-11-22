#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForImageMagick() {
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
}