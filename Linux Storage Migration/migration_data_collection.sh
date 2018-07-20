###########################################################
# This script will collect date from a remote server and
# provide device creation scripts for all BCV's from AF array
#
# Usage:
# Two parameters should be passed while running the script
# Ex: /Storageteam_Share/scripts/migration_data_collection.sh <your login ID> <Server name>
#
# There are two types of output files
# 1. <server name>_final will have all information about mount points along with sizes in cylinders
# 2. <server name>_create_devs_* will have device creation scripts
####################################################################

#!/bin/bash
user_name=$1
server=$2
mkdir /home/${user_name}/script_output

# Clean output directory only related to the current server
rm -rf /home/${user_name}/script_output/${server}*

ssh ${user_name}@${server} sudo python -u - <  /Storageteam_Share/scripts/collect_san_storage_info.py >/home/${user_name}/script_output/${server}

# Only selecting the required columns from previous output
cat /home/${user_name}/script_output/${server} | grep emcpower | awk '{print $1 " " $2 " " $3 " " $4 " " $5}' >/home/${user_name}/script_output/${server}_temp

# Get the cylinder size for each device and generate device creation files
echo "fsmount pseudoname wwn array_id tdev tdev_cyl" >>/home/${user_name}/script_output/${server}_final

while IFS=" " read -r fsmount pseudo wwn array_id tdev
do
    tdev_cyl=`symdev -sid $array_id show $tdev | grep -iA 2 'Device Capacity' | grep 'Cylinders' | awk '{print $NF}'`
    echo $fsmount $pseudo $wwn $array_id $tdev $tdev_cyl >>/home/${user_name}/script_output/${server}_final

    fsmount_temp=`echo ${fsmount^^}| cut -d '/' -f 2`
    tdev_cyl_af=$((tdev_cyl/2))
    # Create Migration R2 devices
    echo "create dev count=1, emulation=FBA, config=TDEV, size="${tdev_cyl_af}", dynamic_capability=DYN_RDF, device_attr=SCSI3_PERSIST_RESERV, device_name=MIG-"${server}"-"${fsmount_temp}";" >>/home/${user_name}/script_output/${server}_create_devs_mig_r2

    # Create R2 Clone devices
    echo "create dev count=1, emulation=FBA, config=TDEV, size="${tdev_cyl_af}", dynamic_capability=DYN_RDF, device_attr=SCSI3_PERSIST_RESERV, device_name="${server}"-"${fsmount_temp}";" >>/home/${user_name}/script_output/${server}_create_devs_prod

    # Create PROD BCV1 devices
    echo "create dev count=1, emulation=FBA, config=TDEV, size="${tdev_cyl_af}", dynamic_capability=DYN_RDF, device_attr=SCSI3_PERSIST_RESERV, device_name=AFBCV1-"${server}"-"${fsmount_temp}";" >>/home/${user_name}/script_output/${server}_create_devs_prod_bcv1

    # Create PROD BCV2 devices
    echo "create dev count=1, emulation=FBA, config=TDEV, size="${tdev_cyl_af}", dynamic_capability=DYN_RDF, device_attr=SCSI3_PERSIST_RESERV, device_name=AFBCV2-"${server}"-"${fsmount_temp}";" >>/home/${user_name}/script_output/${server}_create_devs_prod_bcv2

    # Create DR R2 devices
    echo "create dev count=1, emulation=FBA, config=TDEV, size="${tdev_cyl_af}", dynamic_capability=DYN_RDF, device_attr=SCSI3_PERSIST_RESERV, device_name=AFR2-"${server}"-"${fsmount_temp}";" >>/home/${user_name}/script_output/${server}_create_devs_dr_r2

    # Create DR GOLD devices
    echo "create dev count=1, emulation=FBA, config=TDEV, size="${tdev_cyl_af}", dynamic_capability=DYN_RDF, device_attr=SCSI3_PERSIST_RESERV, device_name=AFGOLD-"${server}"-"${fsmount_temp}";" >>/home/${user_name}/script_output/${server}_create_devs_gold

done </home/${user_name}/script_output/${server}_temp

rm -rf /home/${user_name}/script_output/${server}
rm -rf /home/${user_name}/script_output/${server}_temp