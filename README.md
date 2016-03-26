# scriptBackup
Trabalho de Serviços de Rede

This script enable you to create scheduled backups when added into the crontab. You can save your backup in the removable device or in the cloud (Google Drive).

This script assumes that your removable device is located in /dev/sdb1, so if you use a different path you must change it directly in the script.

There are some default config that can be changed in the script:

Folder that will be backup : /root/compartilhamentos/
Path of the removable device : /dev/sdb1
Path where the device will be mounted : /media/pendrive_backup
The name of the gdrive binary : drive-linux-x64



**Cloud**

In order to use the cloud function enable by https://github.com/prasmussen/gdrive you must follow the tutorial bellow:

http://linuxnewbieguide.org/?p=1078