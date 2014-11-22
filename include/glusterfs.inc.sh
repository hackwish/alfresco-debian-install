#!/bin/bash
# -------
# Script for install of Alfresco
#
# This script is a fork of the original script : https://github.com/loftuxab/alfresco-ubuntu-install
# Updated by ADN SYSTEMES / DIXINFOR, Yannick Molinet
# Copyright 2013-2014 Loftux AB, Peter Löfgren
# Distributed under the Creative Commons Attribution-ShareAlike 3.0 Unported License (CC BY-SA 3.0)
# -------

function AskForGlusterFSServer() {
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
		InstallGlusterFSServer
	fi
}
function InstallGlusterFSServer() {
	server=()
	echo
	read -e -p "How many remote server to install in the GlusterFS Cluster${ques} [1] " -i "1" glustercount
	for (( i = 0 ; i < $glustercount ; i++ )) do
		read -e -p "Enter the Peer's IP:" peerip
		WaitForNetwork $peerip
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
		
	cd $TMPFOLDER
	if [ ! -f "$TMPFOLDER/remote-script.sh" ]; then
		echo "Downloading script to install remotly ..."
		$SUDO curl -# -o $TMPFOLDER/remote-script.sh $BASE_DOWNLOAD/scripts/remote-script.sh
	fi

	if [ ! -f "$TMPFOLDER/glusterfs.sh" ]; then
		echo "Downloading script to install glusterfs ..."
		$SUDO curl -# -o $TMPFOLDER/glusterfs-slave.sh $BASE_DOWNLOAD/scripts/glusterfs.sh
	fi
		
	$SUDO chmod u+x $TMPFOLDER/*.sh
		
	sed -i.bak -e "s/GLUSTERPEERS=.*/GLUSTERPEERS=$server/g" $TMPFOLDER/glusterfs-slave.sh
	sed -i.bak -e "s/ALFRESCOSERVER=.*/ALFRESCOSERVER=$localip/g" $TMPFOLDER/glusterfs-slave.sh
	sed -i.bak -e "s;GLUSTERFOLDER=.*;GLUSTERFOLDER=$GLUSTERFOLDER;g" $TMPFOLDER/glusterfs-slave.sh
	sed -i.bak -e "s/GLUSTERVOLUME=.*/GLUSTERVOLUME=$GLUSTERVOLUME/g" $TMPFOLDER/glusterfs-slave.sh

	cp $TMPFOLDER/glusterfs-slave.sh $TMPFOLDER/glusterfs-master.sh

	sed -i.bak -e "s/GLUSTERMASTER=.*/GLUSTERMASTER=y/g" $TMPFOLDER/glusterfs-master.sh
	sed -i.bak -e "s/GLUSTERTYPE=.*/GLUSTERTYPE=$GLUSTERTYPE/g"  $TMPFOLDER/glusterfs-master.sh
		
	cp $TMPFOLDER/remote-script.sh $TMPFOLDER/remote-glusterfs-master.sh
	cp $TMPFOLDER/remote-script.sh $TMPFOLDER/remote-glusterfs-slave.sh
	$SUDO chmod u+x $TMPFOLDER/*.sh
		
	sed -i.bak -e "s/set rootpassword.*/set rootpassword $glusterpwd/g" $TMPFOLDER/remote-glusterfs-master.sh
	sed -i.bak -e "s/set rootpassword.*/set rootpassword $glusterpwd/g" $TMPFOLDER/remote-glusterfs-slave.sh
		
	sed -i.bak -e "s/set filename.*/set filename glusterfs-master.sh/g" $TMPFOLDER/remote-glusterfs-master.sh
	sed -i.bak -e "s;set fullpath.*;set fullpath $TMPFOLDER/glusterfs-master.sh;g" $TMPFOLDER/remote-glusterfs-master.sh

	sed -i.bak -e "s/set filename.*/set filename glusterfs-slase.sh/g" $TMPFOLDER/remote-glusterfs-slave.sh
	sed -i.bak -e "s;set fullpath.*;set fullpath $TMPFOLDER/glusterfs-slave.sh;g" $TMPFOLDER/remote-glusterfs-slave.sh
		
	echogreen "Number of peers found:  ${#server[@]}"

	for (( i = ${#server[@]}; i > 0 ; i-- )) do
		if [[ $i -eq 1 ]]
		then
			echogreen "Execute GlusterFS Server Installation Script on 'Master' Server: ${server[$i-1]}"
			WaitForNetwork ${server[$i-1]}
			sed -i.bak -e "s/set remoteip.*/set remoteip ${server[$i-1]}/g" $TMPFOLDER/remote-glusterfs-master.sh
			$TMPFOLDER/remote-glusterfs-master.sh
		else
			echogreen "Execute GlusterFS Server Installation Script on 'Slave' Server: ${server[$i-1]}"
			WaitForNetwork ${server[$i-1]}
			sed -i.bak -e "s/set remoteip.*/set remoteip ${server[$i-1]}/g" $TMPFOLDER/remote-glusterfs-slave.sh
			$TMPFOLDER/remote-glusterfs-slave.sh
		fi
	done
}

function AskForMountGlusterFS() {
	echo
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	echo " Do you want to mount Alfresco Primary ContentStore on a GlusterFS mount point ($ALF_HOME/alf_data)? "
	echo " This part don't install any remote service. You must have a valid GlusterFS server available with correct permissions set"
	echoblue "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
	echo
	read -e -p "Do you want to mount alf_data on remote GlusterFS ? [y/n]" -i "n" mount
	if [ "$mount" = "y" ]; then
		MountGlusterFS
	fi
}
function MountGlusterFS (){
	examplehost="GFS-SRV01"
	examplevol="gfsvol"
	
	if [ "$glusterfsserver" = "y" ]; then
		examplehost="${server[0]}"
		examplevol="$GLUSTERVOLUME"
	fi
		
	read -e -p "Specify Hostname or IP Address of a GlusterFS Server (ex. $examplehost): " gfshost
	WaitForNetwork $gfshost
	read -e -p "Specify GlusterFS Volume Name (ex. $examplevol): " gfsvol
	gfspath="$gfshost:$gfsvol"
	
	$SUDO apt-get $APTVERBOSITY install glusterfs-client
	mkdir -p $ALF_HOME/alf_data
	mount -t glusterfs $gfspath $ALF_HOME/alf_data
	echo "$gfspath  $ALF_HOME/alf_data    glusterfs       defaults,_netdev        0       0" >> /etc/fstab
}