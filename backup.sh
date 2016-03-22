#!/bin/bash

#Setting up the variables
incoming_folder_path=/root/compartilhamentos
output_backup_path=''
log_path=/root/log_backup

mount_object=0

#Getting the Date
RIGHT_NOW=$(date +%d%m%Y)
	
echo $RIGHT_NOW;



function inicio(){
	clear
	echo "";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                               Script de backup                              |";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                                                                             |";
	echo "|                             Options:                                        |";
	echo "|                                                                             |";
	echo "|                                                                             |";
	echo "| SINOPSE                                                                     |";
	echo "|                                                                             |";
	echo "|                                                                             |";
	echo "| DESCRIPTION                                                                 |";
	echo "|     Script to perform updates on Groups information.                        |";
	echo "|                                                                             |";
	echo "| OPTIONS                                                                     |";
	echo "|                                                                             |";
	echo "|     -v                                                                      |";
	echo "|          Debug mode.                                                        |";
	echo "|                                                                             |";
	echo "|     -V                                                                      |";
	echo "|          Script current version.                                            |";
	echo "|                                                                             |";
	echo "|     -F                                                                      |";
	echo "|          Name of the file containing the original Group data.               |";
	echo "|                                                                             |";
	echo "|     -e                                                                      |";
	echo "|          Internet Address from the requester of this action                 |";
	echo "|                                                                             |";
	echo "|     -f                                                                      |";
	echo "|          Feedback ticket number associated to this action                   |";
	echo "|                                                                             |";
	echo "+-----------------------------------------------------------------------------+";
	echo " ";
}



#Insert Log into the file
function insertlog(){
	echo "$1 `date +%d/%m/%Y-%H:%M`";
}

#Check if there is available space to create the tem file and if there is enough space in the destiny
function environment_checking(){

	echo "Checking if the environment is prepared for the backup";
	insertlog "Checking if the environment is prepared for the backup"

	#Getting available space in the disk
	available_space_disk=`df . | tail -1 | awk '{print $4}'`;
	
	#Getting the current usage space
	current_usage_space=`ls -lR $backup_path | grep -v '^d' | awk '{total += $5} END {print total}'`;
	
	insertlog "Cheking if there is enough space to create the temporary file"

	#Check if the amount of files is bigger than the available space
	if [ $current_usage_space -ge $available_space_disk ]
		then
			$missing_space=expr $current_usage_space - $available_space_disk;
			insertlog "Not enough space. Missing space: $missing_space"
			echo "There isn't enough space on the disk to create the temporary file";
			$?=100;
	fi

	#Checking if the pen drive is connected

	#Cheking if the device has enough space to receive the file

}

#Move temporary file to a Mount Device
function move_temporary_file_local(){
 echo 0;
}


function move_temporary_file_cloud(){
 echo 0;
}

#Remove files older than 15 days
function removing_old_files(){
 echo 0;
}
