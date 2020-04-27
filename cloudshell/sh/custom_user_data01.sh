#!/bin/bash
sed -i '/^\W*#/ ! s/.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config > /tmp/userdata.log 2>&1
echo $? >> /tmp/userdata.log 2>&1

systemctl restart sshd >> /tmp/userdata.log 2>&1
echo $? >> /tmp/userdata.log 2>&1

IPADDRESS=`ifconfig | grep inet | grep -v 127.0.0.1 | awk ' { print $2 } '`
INSTANCE_NAME=`hostname`
DOMAIN_NAME=resource.local
echo "$IPADDRESS ${INSTANCE_NAME}.${DOMAIN_NAME} ${INSTANCE_NAME}" >> /etc/hosts
echo $? >> /tmp/userdata.log 2>&1 
