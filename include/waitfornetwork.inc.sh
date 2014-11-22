#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Copyright 2013-2014 ADN SYSTEMES / Dixinfor, Yannick Molinet
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------



WaitForNetwork()
{
	# http://smartcoding.wordpress.com/2010/11/14/linux-shell-scripting-wait-for-network-to-be-available/
	# http://stackoverflow.com/questions/18123211/checking-host-availability-by-using-ping-in-bash-scripts
	# http://ubuntuforums.org/archive/index.php/t-1005871.html
	# Wait for Network to be available.
	while true
	do
		result=`ifconfig | grep "inet ad" | grep 255.255.255.0`
		if [[ $result != "" ]];
		then
			echo "Network connectivity available."
			ping -c 1 $1 > null
			if [[ $? == 0 ]];
			then
				echo "Host $1 available."
				break;
			else
				echo "Host $1 is not available, waiting 10s and retry ..."
				sleep 10
			fi
		else
			echo "Network connectivity is not available, waiting 10s and retry ..."
			sleep 10
		fi
	done
}
