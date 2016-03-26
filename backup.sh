#!/bin/bash

#https://github.com/prasmussen/gdrive
#http://linuxnewbieguide.org/?p=1078
#Setting up the variables
incoming_folder_path=/root/compartilhamentos
output_backup_path=''
log_path=/root/log_backup
mount_object=/dev/sdb1
mount_path=/media/pendrive_backup
backup_file_name=


function inicio(){
	clear
	echo "";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                               Script de backup                              |";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                                                                             |";
	echo "| SINOPSE                                                                     |";
	echo "|  Esta script é utilizada para realizar backups dos compartilhamentos deste  |";
	echo "|  servidor                                                                   |";
	echo "|                                                                             |";
	echo "| Opções                                                                      |";
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
	echo ">>>>>>>>>>>>>>>";
	datetime >> $log_path;
	echo $1 >> $log_path;
	echo ">>>>>>>>>>>>>>>";
}

#Check if there is available space to create the tem file and if there is enough space in the destiny
function environment_checking(){

	insertlog "Checking if the environment is prepared for the backup..."

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
			finishScript "Insuficient Space to create temp file!"
			else
				insertlog "OK - Enough space to create temp file!"
	fi


	#Checking if it is able to mount the pen drive
	insertlog "Checking if it is able to mount the pen drive"

	`mkdir -p $mount_path && mount $mount_object $mount_path`

	if [ $? -eq 0 ]
		then
			insertlog "OK - Able to mount the pen drive into the system"
			else
				insertlog "Unable to mount $mount_object in mount_path!"
				finishScript "Unable to mount the pen drive!"
	fi

	
	#Cheking if the device has enough space to receive the file

	available_space_pendrive=`df $mount_path | tail -1 | awk '{print $4}'`;

	#Check if the amount of files is bigger than the available space
	if [ $current_usage_space -ge $available_space_pendrive ]
		then
			$missing_space=expr $current_usage_space - $available_space_pendrive;
			insertlog "Not enough space. Missing space: $missing_space"
			finishScript "Insuficient Space in the destiny device!"
			else
				insertlog "OK - Enough space in the destiny device"
	fi

}

#Prepare backup file
function create_backup_file(){
	insertlog "Inicializing backup file creation..."
	`tar -zcvf $backup_file_name $incoming_folder_path`
	if [ $? -eq 0 ]
		then
			insertlog "OK - The backup file has been created"
			else
				insertlog "Unable to tar and compress the folder $incoming_folder_path!"
				finishScript "Unbale to create the backup file!"
	fi
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

#Termina a script
function finishScript(){
	reason=$1
	insertlog "Fatal error:$reason"
	insertlog "------------------------------------------------fim-------------------------------------------------------"
 	exit;
}

function datetime(){
	#Getting the Date
	now=$(date +%d/%m/%Y-%H:%M.%S);
	echo $now;
}

environment_checking