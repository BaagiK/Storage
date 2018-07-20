###########################################################
This script will collect data from a remote server and
 provide device creation scripts for all BCV's from AF array

 Usage:
 Two parameters should be passed while running the script
 Ex: /Storageteam_Share/scripts/migration_data_collection.sh <your login ID> <Server name>

 There are two types of output files
 1. <server name>_final will have all information about mount points along with sizes in cylinders
 2. <server name>_create_devs_* will have device creation scripts
####################################################################
