#!/bin/bash

#Setting up the variables
incoming_folder_path=/root/compartilhamentos/
mount_object=/dev/sdb1
mount_path=/media/pendrive_backup
drive_binary="drive-linux-x64";

#Creating files name
date=$(date +%d%m%Y);
backup_file_name="backups-$date.tar.bz2";
log_path="/root/log_backup-$date";

#Getting the parameters

destiny_device=$1;
will_remove_old_files=$2;

function help_func(){
	echo "";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                               Backup Script                                 |";
	echo "+-----------------------------------------------------------------------------+";
	echo "|                                                                             |";
	echo "| SINOPSE                                                                     |";
	echo "|  This script is used to provide scheduled backups from shared files in the  |";
	echo "|  server                                                                     |";
	echo "|                                                                             |";
	echo "| Use**:                                                                      |";
	echo "|     ./backup.sh <destiny> <remove old files>                                |";
	echo "|                                                                             |";
	echo "| Parameters                                                                  |";
	echo "|                                                                             |";
	echo "|     -destiny                                                                |";
	echo "|          device                                                             |";
	echo "|          cloud*                                                             |";
	echo "|                                                                             |";
	echo "|     -remove old files                                                       |";
	echo "|          yes                                                                |";
	echo "|          no                                                                 |";
	echo "|                                                                             |";
	echo "|  *Make sure you have configured gdrive in this server(README)               |";
	echo "|  **Both parameters are required                                             |";
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

	#If it is about a physical device
	if [ "$destiny_device" == "device" ]
		then
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
	fi

	#If it is about cloud
	if [ "$destiny_device" == "cloud" ]
		then
			insertlog "Verifying if the gdrie is configured..."
			number_conf_files=`find / -type d -name '.gdrive' | grep 'gdrive' -o | grep 'gdrive' -c`
			if [ $number_conf_files -eq 0 ]
				then
					insertlog "There wasn't found any config folder about gdrive configuration '~/.gdrive'!"
					finishScript "Unable to find gdrive config folder!"
			fi
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
	if [ $? -eq 127 ]
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
#*******ONLY FOR MOUNTED DEVICES
function removing_old_files(){
	insertlog "Removing older files..."
	`find $mount_path -type f -mtime +15 -exec rm -f {} \\;`
	if [ $? -eq 0 ]
		then
			insertlog "OK - The backup files older than 15 days has been removed"
			else
				insertlog "Unable to remove the oldest files from the device"
				finishScript "Unable to remove old files!"
	fi
}

#End script
function finishScript(){
	reason=$1
	insertlog "Fatal error:$reason"
	insertlog "------------------------------------------------Finished-------------------------------------------------------"
 	exit;
}

#Get the Date
function datetime(){
	now=$(date +%d/%m/%Y-%H:%M:%S);
	echo $now;
}

#Script end
function endScript(){
	insertlog $(date +%d/%m/%Y-%H:%M.%S)
	insertlog "------------------------------------------------End-------------------------------------------------------"
	exit;
}

#Script Start
function startScript(){
	insertlog $(date +%d/%m/%Y-%H:%M.%S)
	insertlog "------------------------------------------------Start-------------------------------------------------------"
}

#____________________________________________________________________________________________________________________________________



#Validating Parameter
if [ $# -eq 0 ]
	then
	echo "No arguments provided, please check the Read me file or user the paramter 'help'";
	exit
fi

if [ "$destiny_device" == "device" ]
	then
		destiny_device="device";
	elif [ "$destiny_device" == "cloud" ]
		then
			destiny_device="cloud";
		elif [ "$destiny_device" == "help" ]
			then
				clear
				help_func
				exit
				else
					echo "Unable to recognize the parameters please check the Read me file or user the paramter 'help'";
					exit
fi

startScript
#Starting routines
if [ "$destiny_device" == "device" ]
	then
		environment_checking
		create_backup_file
		move_to_pendrive
	elif [ "$destiny_device" == "cloud" ] 
		then
			environment_checking
			create_backup_file
			move_to_cloud
fi

if [ "$will_remove_old_files" == "yes" ]
	then
		removing_old_files
fi
endScript