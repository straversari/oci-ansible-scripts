#!/bin/bash

BATCH=$1

if [ "$BATCH" = "Y" ]
then
 CUSTOM_CONFIG_FILE=`realpath $2`
fi

CUSTOMSHNAME=`basename $0`
PATHSH=`echo $0 | sed s/.${CUSTOMSHNAME}//`
if [ "${PATHSH}" != "${CUSTOMSHNAME}" ]
then
 cd ${PATHSH}
fi
SHELLPATH=`pwd`
mkdir -p tmp 
mkdir -p conf 

if [ "$BATCH" != "Y" ]
then

 echo "Interactive Mode"
 echo
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering availability domain list..."
  oci iam availability-domain list --output table --query "data [*].{\"Availability Domain\":\"name\"}"
  echo -n "Please provide the availability domain: "
  read CUSTOM_AD_NAME
  echo "Validating availability domain..."
  oci iam availability-domain list --output table --query "data [*].{\"Availability Domain\":\"name\"}" | grep \ $CUSTOM_AD_NAME\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo -n "Please provide the instance type [linux]: "  
  read INSTANCE_TYPE 
  if [ "${INSTANCE_TYPE}" = "" ]
  then
   INSTANCE_TYPE=linux   
  fi  
  if [ "${INSTANCE_TYPE}" = "linux" ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering compartment list..."
  oci iam compartment list --output=table --query "data [?contains(\"lifecycle-state\",'ACTIVE')].{Name:\"name\",OCID:id,Description:description}" --compartment-id-in-subtree true --all
  echo -n "Please provide the instance compartment OCID: "
  read CUSTOM_COMPARTMENT_OCID
  echo "Validating compartment OCID..."
  oci iam compartment list --output=table --query "data [?contains(\"lifecycle-state\",'ACTIVE')].{OCID:id}" --compartment-id-in-subtree true --all | grep \ $CUSTOM_COMPARTMENT_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering compartment list..."  
  oci iam compartment list --output=table --query "data [?contains(\"lifecycle-state\",'ACTIVE')].{Name:\"name\",OCID:id,Description:description}" --compartment-id-in-subtree true --all
  oci iam availability-domain list --output table --query "data [?contains(\"name\",'AD-1')].{\"(root) OCID\":\"compartment-id\"}" 
  echo -n "Please provide the image compartment OCID (use root compartment for Oracle Provided images): "  
  read CUSTOM_IMAGE_COMPARTMENT_OCID
    
  echo "Validating compartment OCID..."
  oci iam compartment list --output=table --query "data [?contains(\"lifecycle-state\",'ACTIVE')].{OCID:id}" --compartment-id-in-subtree true --all | grep \ $CUSTOM_IMAGE_COMPARTMENT_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  fi
  oci iam availability-domain list --output table --query "data [?contains(\"name\",'AD-1')].{\"(root) OCID\":\"compartment-id\"}" | grep \ $CUSTOM_IMAGE_COMPARTMENT_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  fi
  if [ $CHECK = KO ]
  then
   echo "Bad input..."
  fi
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering image list..."  
  oci compute image list --compartment-id $CUSTOM_IMAGE_COMPARTMENT_OCID --all --output table --query "data [?contains(\"operating-system\",'CentOS') == \`false\`] | [?contains(\"display-name\",'GPU') == \`false\`] | [?contains(\"operating-system\",'Ubuntu') == \`false\`] | [?contains(\"operating-system\",'Windows') == \`false\`].{name:\"display-name\",version:\"operating-system-version\",size:\"size-in-mbs\",OCID:id,OS:\"operating-system\"}"
  echo -n "Please provide the image OCID: "
  read CUSTOM_IMAGE_OCID
    
  echo "Validating image OCID..."
  oci compute image list --compartment-id $CUSTOM_IMAGE_COMPARTMENT_OCID --all --output table --query "data [?contains(\"operating-system\",'CentOS') == \`false\`] | [?contains(\"display-name\",'GPU') == \`false\`] | [?contains(\"operating-system\",'Ubuntu') == \`false\`] | [?contains(\"operating-system\",'Windows') == \`false\`].{name:\"display-name\",version:\"operating-system-version\",size:\"size-in-mbs\",OCID:id,OS:\"operating-system\"}" | grep \ $CUSTOM_IMAGE_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO 
 
 echo "Please provide the instance name:"
 read CUSTOM_INSTANCE_NAME
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering instance shape list..."
  CUSTOM_ROOT_COMPARTMENT_OCID=`oci iam availability-domain list --output table --query "data [?contains(\"name\",'AD-1')].{\"(root) OCID\":\"compartment-id\"}" | grep ".tenancy." | awk ' { print $2 } '`
  oci compute shape list --compartment-id $CUSTOM_ROOT_COMPARTMENT_OCID --all --output table --availability-domain $CUSTOM_AD_NAME
  echo -n "Please provide the instance shape: "
  read CUSTOM_SHAPE
    
  echo "Validating shape..."
  oci compute shape list --compartment-id $CUSTOM_ROOT_COMPARTMENT_OCID --all --output table --availability-domain $CUSTOM_AD_NAME | grep \ $CUSTOM_SHAPE\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering compartment list..."    
  oci iam compartment list --output=table --query "data [?contains(\"lifecycle-state\",'ACTIVE')].{Name:\"name\",OCID:id,Description:description}" --compartment-id-in-subtree true --all  
  echo -n "Please provide the VCN compartment OCID: "
  read CUSTOM_VCN_COMPARTMENT_OCID
    
  echo "Validating compartment OCID..."
  oci iam compartment list --output=table --query "data [?contains(\"lifecycle-state\",'ACTIVE')].{OCID:id}" --compartment-id-in-subtree true --all | grep \ $CUSTOM_VCN_COMPARTMENT_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering VCN list..."  
  oci network vcn list --compartment-id $CUSTOM_VCN_COMPARTMENT_OCID --query "data [?contains(\"lifecycle-state\",'AVAILABLE')].{Name:\"display-name\",OCID:id,CIDR:\"cidr-block\"}" --all  --output=table
  echo -n "Please provide the VCN OCID: "
  read CUSTOM_VCN_OCID
    
  echo "Validating VCN OCID..."
  oci network vcn list --compartment-id $CUSTOM_VCN_COMPARTMENT_OCID --query "data [?contains(\"lifecycle-state\",'AVAILABLE')].{Name:\"display-name\",OCID:id,CIDR:\"cidr-block\"}" --all  --output=table | grep \ $CUSTOM_VCN_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Gathering subnet list..." 
  oci network subnet list --compartment-id $CUSTOM_VCN_COMPARTMENT_OCID --vcn-id $CUSTOM_VCN_OCID  --query "data [?contains(\"lifecycle-state\",'AVAILABLE')].{Name:\"display-name\",OCID:id,CIDR:\"cidr-block\",AD:\"availability-domain\",Private:\"prohibit-public-ip-on-vnic\"}" --all  --output=table
  echo -n "Please provide the subnet OCID: "
  read CUSTOM_SUBNET_OCID
    
  echo "Validating subnet OCID..."
  oci network subnet list --compartment-id $CUSTOM_VCN_COMPARTMENT_OCID --vcn-id $CUSTOM_VCN_OCID  --query "data [?contains(\"lifecycle-state\",'AVAILABLE')].{Name:\"display-name\",OCID:id,CIDR:\"cidr-block\",AD:\"availability-domain\",Private:\"prohibit-public-ip-on-vnic\"}" --all  --output=table | grep \ $CUSTOM_SUBNET_OCID\  > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO 
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Please provide the ssh public key file:"
  read CUSTOM_SSH_PUB_KEY_FILE
    
  echo "Validating ssh public key file..."
  ls -l .ssh/$CUSTOM_SSH_PUB_KEY_FILE > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO 
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo "Please provide the user data file:"
  read CUSTOM_USER_DATA_FILE
    
  echo "Validating ssh public key file..."
  ls -l sh/$CUSTOM_USER_DATA_FILE > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO 
 
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo -n "Please provide the number of block volume to be created [0]: "
  read CUSTOM_NEW_BLOCK_VOLUMES
  if [ "${CUSTOM_NEW_BLOCK_VOLUMES}" = "" ]
  then
   CUSTOM_NEW_BLOCK_VOLUMES=0
  fi
  
  if [ $CUSTOM_NEW_BLOCK_VOLUMES -ge 0 -a $CUSTOM_NEW_BLOCK_VOLUMES -le 9 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO
 
 CUSTOM_NEW_BLOCK_VOLUME_STRING=""
 MAXI=0
 for i in `seq $CUSTOM_NEW_BLOCK_VOLUMES`
 do
  echo
  echo "New Block Volume #"$i
  CUSTOM_VOLUME_NAME=${CUSTOM_INSTANCE_NAME}_disk000$i
  CUSTOM_DEVICE_NAME="/dev/oracleoci/oraclevd`echo $i | tr '[1-9]' '[b-j]'`"
  MAXI=$i
  echo -n "Please provide volume size in GB[50]: "
  CHECK=KO
  while [ "$CHECK" != "OK" ]
  do
   read VOLUME_SIZEGB
   if [ "${VOLUME_SIZEGB}" = "" ]
   then
    VOLUME_SIZEGB=50
   fi
  
   if [ $VOLUME_SIZEGB -ge 50 -a $VOLUME_SIZEGB -le 30000 ]
   then
    CHECK=OK
   else
    echo "Bad input..."
   fi  
  done
  CHECK=KO
  
  if [ "${CUSTOM_NEW_BLOCK_VOLUME_STRING}" = "" ]
  then
   CUSTOM_NEW_BLOCK_VOLUME_STRING=${CUSTOM_VOLUME_NAME}:${CUSTOM_DEVICE_NAME}:${VOLUME_SIZEGB}
  else
   CUSTOM_NEW_BLOCK_VOLUME_STRING=${CUSTOM_NEW_BLOCK_VOLUME_STRING},${CUSTOM_VOLUME_NAME}:${CUSTOM_DEVICE_NAME}:${VOLUME_SIZEGB}
  fi

 done  
  
 CHECK=KO
 while [ "$CHECK" != "OK" ]
 do
  echo -n "Please provide the number of block volume to be cloned from existing backup [0]: "
  read CUSTOM_NEW_BLOCK_VOLUMES_FROM_BACKUP
  if [ "${CUSTOM_NEW_BLOCK_VOLUMES_FROM_BACKUP}" = "" ]
  then
   CUSTOM_NEW_BLOCK_VOLUMES_FROM_BACKUP=0
  fi
  
  if [ $CUSTOM_NEW_BLOCK_VOLUMES_FROM_BACKUP -ge 0 -a $CUSTOM_NEW_BLOCK_VOLUMES_FROM_BACKUP -le 9 ]
  then
   CHECK=OK
  else
   echo "Bad input..."
  fi  
 done
 CHECK=KO
 
 CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP=""
 for i in `seq $CUSTOM_NEW_BLOCK_VOLUMES_FROM_BACKUP`
 do
  echo
  echo "New Block Volume #"$i" from backup"
  VOLUMESEQ=`expr $MAXI + $i`
  CUSTOM_CLONE_VOLUME_NAME=${CUSTOM_INSTANCE_NAME}_disk000$VOLUMESEQ
  VOLUMELETTER=( {b..z} )
  CUSTOM_CLONE_DEVICE_NAME="/dev/oracleoci/oraclevd${VOLUMELETTER[VOLUMESEQ+1]}"
  echo -n "Please provide the block volume backup OCID: "
  read CUSTOM_SOURCE_BACKUP_VOLUME_OCID
  
  if [ "${CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP}" = "" ]
  then
   CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP=${CUSTOM_CLONE_VOLUME_NAME}:${CUSTOM_CLONE_DEVICE_NAME}:${CUSTOM_SOURCE_BACKUP_VOLUME_OCID}
  else
   CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP=${CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP},${CUSTOM_CLONE_VOLUME_NAME}:${CUSTOM_CLONE_DEVICE_NAME}:${CUSTOM_SOURCE_BACKUP_VOLUME_OCID}
  fi
   
 done 
 
 CUSTOM_CONFIG_FILE=conf/${CUSTOM_INSTANCE_NAME}_$$.conf
 
 CUSTOM_CURRENT_PATH=`pwd`
 
 echo "Writing configuration file to ${CUSTOM_CONFIG_FILE}..."
 echo "export CUSTOM_AD_NAME=${CUSTOM_AD_NAME}" > $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_COMPARTMENT_OCID=${CUSTOM_COMPARTMENT_OCID}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_SUBNET_OCID=${CUSTOM_SUBNET_OCID}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_INSTANCE_NAME=${CUSTOM_INSTANCE_NAME}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_SHAPE=${CUSTOM_SHAPE}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_IMAGE_OCID=${CUSTOM_IMAGE_OCID}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_SSH_PUB_KEY_FILE=${CUSTOM_CURRENT_PATH}/.ssh/${CUSTOM_SSH_PUB_KEY_FILE}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_USER_DATA_FILE=${CUSTOM_CURRENT_PATH}/sh/${CUSTOM_USER_DATA_FILE}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_NEW_BLOCK_VOLUME_STRING=${CUSTOM_NEW_BLOCK_VOLUME_STRING}" >> $CUSTOM_CONFIG_FILE
 echo "export CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP=${CUSTOM_NEW_BLOCK_VOLUME_STRING}" >> $CUSTOM_CONFIG_FILE
  
 echo "### BEGIN DO NOT EDIT
export CUSTOM_USER_DATA=${CUSTOM_CURRENT_PATH}/sh/\`basename \$CUSTOM_USER_DATA_FILE\`.base64
base64 -i -w 0 \$CUSTOM_USER_DATA_FILE > \$CUSTOM_USER_DATA
### END DO NOT EDIT" >> $CUSTOM_CONFIG_FILE
  
else

 echo "Batch Mode"
 
 if [ ! -f "$CUSTOM_CONFIG_FILE" ]
 then
  echo "Custom file not found!"
  exit 1
 fi

fi

echo 
echo "Configuration:"
cat $CUSTOM_CONFIG_FILE

if [ "$BATCH" != "Y" ]
then
 echo "Do you want to proceed with instance creation? [y]"
 read CUSTOM_RESPONSE
fi

if [ "$CUSTOM_RESPONSE" = "" -o "$CUSTOM_RESPONSE" = "y" -o "$BATCH" = "Y" ]
then
 echo "Setting configuration file..."
 . $CUSTOM_CONFIG_FILE
 echo "Starting ansible to create instance..."
 sleep 5
 TMP_ANSIBLE_LOG=tmp/create_instance.yml.$$.tmp
 > $TMP_ANSIBLE_LOG
 ansible-playbook yml/create_instance.yml  2>&1 | tee -a $TMP_ANSIBLE_LOG
 ANSIBLE_RC=$?
 echo "Ansible Playbook return code = ${ANSIBLE_RC}"
 
 if [ ${ANSIBLE_RC} -ne 0 ]
 then
  exit 1
 fi
 
 echo "Ansible Playbook return variables:"
 CUSTOM_INSTANCE_OCID=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_INSTANCE_OCID | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
 CUSTOM_INSTANCE_PUBLIC_IP=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_INSTANCE_PUBLIC_IP | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
 CUSTOM_INSTANCE_PRIVATE_IP=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_INSTANCE_PRIVATE_IP | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
 
 if [ "${CUSTOM_INSTANCE_PUBLIC_IP}" = "" ]
 then
  echo "Instance ${CUSTOM_INSTANCE_NAME} created."
  echo "OCID = ${CUSTOM_INSTANCE_OCID}"
  echo "Private IP = ${CUSTOM_INSTANCE_PRIVATE_IP}"
 else
  echo "Instance ${CUSTOM_INSTANCE_NAME} created."
  echo "OCID = ${CUSTOM_INSTANCE_OCID}"
  echo "Private IP = ${CUSTOM_INSTANCE_PRIVATE_IP}"
  echo "Public IP = ${CUSTOM_INSTANCE_PUBLIC_IP}"
 fi 
 
 export CUSTOM_INSTANCE_OCID
 export CUSTOM_INSTANCE_PUBLIC_IP
 export CUSTOM_INSTANCE_PRIVATE_IP
 
 
 TMP_ANSIBLE_OUT=tmp/create_volume.yml.$$.iscsicmd.tmp
 > $TMP_ANSIBLE_OUT
 
 if [ "$CUSTOM_NEW_BLOCK_VOLUME_STRING" != "" ]
 then
  
  for CUSTOM_VOLUME_LINE in `echo $CUSTOM_NEW_BLOCK_VOLUME_STRING | sed s/\,/\ /g`
  do
   CUSTOM_VOLUME_NAME=`echo $CUSTOM_VOLUME_LINE | awk -F \: ' { print $1 } '`
   CUSTOM_DEVICE_NAME=`echo $CUSTOM_VOLUME_LINE | awk -F \: ' { print $2 } '`
   CUSTOM_VOLUME_SIZEGB=`echo $CUSTOM_VOLUME_LINE | awk -F \: ' { print $3 } '`
   export CUSTOM_VOLUME_NAME
   export CUSTOM_DEVICE_NAME
   export CUSTOM_VOLUME_SIZEGB
   
   echo "Starting ansible to create block volume..."
   sleep 5
   TMP_ANSIBLE_LOG=tmp/create_volume.yml.$$.${CUSTOM_VOLUME_NAME}.tmp
   > $TMP_ANSIBLE_LOG
   ansible-playbook yml/create_volume.yml  2>&1 | tee -a $TMP_ANSIBLE_LOG
   ANSIBLE_RC=$?
   echo "Ansible Playbook return code = ${ANSIBLE_RC}"
   
   echo "Ansible Playbook return variables:"
   CUSTOM_VOLUME_ID=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_VOLUME_ID | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
   CUSTOM_VOLUME_ATTACHMENT=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_VOLUME_ATTACHMENT | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
   
   echo ${CUSTOM_VOLUME_ATTACHMENT} | awk -F \' ' { print $2 "\n" $4 "\n" $6 } ' >> $TMP_ANSIBLE_OUT
   
  done
    
 fi 
 
 if [ "$CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP" != "" ]
 then

  for CUSTOM_VOLUME_LINE in `echo $CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP | sed s/\,/\ /g`
  do
   CUSTOM_CLONE_VOLUME_NAME=`echo $CUSTOM_VOLUME_LINE | awk -F \: ' { print $1 } '`
   CUSTOM_CLONE_DEVICE_NAME=`echo $CUSTOM_VOLUME_LINE | awk -F \: ' { print $2 } '`
   CUSTOM_SOURCE_BACKUP_VOLUME_OCID=`echo $CUSTOM_VOLUME_LINE | awk -F \: ' { print $3 } '`
   export CUSTOM_CLONE_VOLUME_NAME
   export CUSTOM_CLONE_DEVICE_NAME
   export CUSTOM_SOURCE_BACKUP_VOLUME_OCID
   
   echo "Starting ansible to clone block volume from backup..."
   sleep 5
   TMP_ANSIBLE_LOG=tmp/create_volume_backup.yml.$$.${CUSTOM_CLONE_VOLUME_NAME}.tmp
   > $TMP_ANSIBLE_LOG
   ansible-playbook yml/create_volume_backup.yml  2>&1 | tee -a $TMP_ANSIBLE_LOG
   ANSIBLE_RC=$?
   echo "Ansible Playbook return code = ${ANSIBLE_RC}"
   
   echo "Ansible Playbook return variables:"
   CUSTOM_VOLUME_ID=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_VOLUME_ID | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
   CUSTOM_VOLUME_ATTACHMENT=`cat $TMP_ANSIBLE_LOG | grep \@\@\@CUSTOM_VOLUME_ATTACHMENT | awk -F \=\  ' { print $2 } ' | awk -F \" ' { print $1 } '`
   
   echo ${CUSTOM_VOLUME_ATTACHMENT} | awk -F \' ' { print $2 "\n" $4 "\n" $6 } ' >> $TMP_ANSIBLE_OUT
   
  done
    
 fi 
 
 if [ "$CUSTOM_NEW_BLOCK_VOLUME_STRING" != "" -o "$CUSTOM_NEW_BLOCK_VOLUME_STRING_FROM_BACKUP" != "" ]
 then
 
  echo 
  echo "Ansible Script Completed."
  
  if [ "${CUSTOM_INSTANCE_PUBLIC_IP}" = "" ]
  then
   echo "Please connect to instance ${CUSTOM_INSTANCE_NAME} (private IP = ${CUSTOM_INSTANCE_PRIVATE_IP}) and execute the following commands as root user to attach block volumes:"
  else
   echo "Please connect to instance ${CUSTOM_INSTANCE_NAME} (private IP = ${CUSTOM_INSTANCE_PRIVATE_IP}, public IP = ${CUSTOM_INSTANCE_PUBLIC_IP}) and execute the following commands as root user to attach block volumes:"
  fi   
  
  cat $TMP_ANSIBLE_OUT
 
 else
 
  echo 
  echo "Ansible Script Completed."
  
  if [ "${CUSTOM_INSTANCE_PUBLIC_IP}" = "" ]
  then
   echo "Please connect to instance ${CUSTOM_INSTANCE_NAME} (private IP = ${CUSTOM_INSTANCE_PRIVATE_IP})."
  else
   echo "Please connect to instance ${CUSTOM_INSTANCE_NAME} (private IP = ${CUSTOM_INSTANCE_PRIVATE_IP}, public IP = ${CUSTOM_INSTANCE_PUBLIC_IP})."
  fi 
 
 fi
  
else
 echo "Instance creation skipped!"
fi

exit 0
