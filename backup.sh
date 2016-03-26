#!/bin/bash

#https://github.com/prasmussen/gdrive
#http://linuxnewbieguide.org/?p=1078
#Setting up the variables
incoming_folder_path=/root/compartilhamentos/
output_backup_path=''
log_path=/root/log_backup
mount_object=/dev/sdb1
mount_path=/media/pendrive_backup
drive_binary='drive-linux-x64';

#Creating file name
date=$(date +%d%m%Y);
backup_file_name="backups-$date.tar.bz2";


function help(){
	clear
	echo "";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                               Backup Script                                 |";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                                                                             |";
	echo "| SINOPSE                                                                     |";
	echo "|  This script is used to provide scheduled backups from shared files in the  |";
	echo "|  server	                                                                    |";
	echo "|                                                                             |";
	echo "| Use:                                                                        |";
	echo "|                                                                             |";
	echo "|                                                                             |";
	echo "|                                                                             |";
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
	echo ">>>>>>>>>>>>>>>" >> $log_path;
	datetime >> $log_path;
	echo $1 >> $log_path;
	echo ">>>>>>>>>>>>>>>" >> $log_path;
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

	`mkdir -p $mount_path || mount $mount_object $mount_path`

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
	`tar -jcf /tmp/$backup_file_name $incoming_folder_path`;
	if [ $? -eq 0 ]
		then
			insertlog "OK - The backup file $backup_file_name has been created in /tmp"
			else
				insertlog "Unable to tar and compress the folder $incoming_folder_path!"
				finishScript "Unable to create the backup file!"
	fi
}

#Move backup file to a Mount Device
function move_to_pendrive(){
	insertlog "Moving backup file to pendrive..."
	`mv /tmp/$backup_file_name $mount_path`
	if [ $? -eq 0 ]
		then
			insertlog "OK - The backup file $backup_file_name has been moved to the pendrive"
			else
				insertlog "Unable to move the backup file into the mounted path $mount_path!"
				`mkdir -p /backup_transition_error || mv /tmp/$backup_file_name /backup_transition_error`
				if [ $? -eq 0 ]
				then
					insertlog "Warning - It wasn't possible to tranfer the backup file $backup_file_name to the pen drive to it was moved to /backup_transition_error"
					else
						insertlog "Unable to move the backup file $backup_file_name to any place!Please check!"
						finishScript "UNABLE TO MOVE THE BACKUP FILE!"
				fi
	fi
}

#Move the backup file into the Google Drive
function move_to_cloud(){
	insertlog "Moving backup file to the cloud..."
	`$drive_binary upload -f /tmp/$backup_file_name`
	if [ $? -eq 0 ]
		then
			insertlog "OK - The backup file $backup_file_name has been moved to the cloud"
			`rm -f /tmp/$backup_file_name`
			else
				insertlog "Unable to move the backup file into the cloud!"
				`mkdir -p /backup_transition_error || mv /tmp/$backup_file_name /backup_transition_error`
				if [ $? -eq 0 ]
				then
					insertlog "Warning - It wasn't possible to tranfer the backup file $backup_file_name to the pen drive to it was moved to /backup_transition_error"
					else
						insertlog "Unable to move the backup file $backup_file_name to any place!Please check!"
						finishScript "UNABLE TO MOVE THE BACKUP FILE!"
				fi
	fi
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

create_backup_file

move_to_pendrive

