#!/bin/bash
# 
# - clear local known_hosts file 
# - generate hosts file entries in /tmp/hosts for distribution to all nodes
# - generate hosts file entries in /tmp/ansible_hosts for distribution to all nodes

# source common variables
source common_VARS.sh

> ~/.ssh/known_hosts

ANSBL_HOSTS=/etc/ansible/hosts
sudo rm -f $ANSBL_HOSTS||true;sudo touch $ANSBL_HOSTS

HOSTSFILE=/tmp/hosts
rm -f $HOSTSFILE||true;touch $HOSTSFILE

echo "[ses-nodes]" | sudo tee -a $ANSBL_HOSTS

i=0
for ipa in $(terraform output private-ip-mon)
do 
  echo $ipa mon${BASENAME}${i}.${DOMNAME} mon${BASENAME}${i} >> $HOSTSFILE
  echo $ipa | sudo tee -a $ANSBL_HOSTS
  let i+=1
done 

i=0
for ipa in $(terraform output private-ip-osd)
do
  echo $ipa ${BASENAME}osd-${i}.${DOMNAME} ${BASENAME}osd-${i} >> $HOSTSFILE
  echo $ipa | sudo tee -a $ANSBL_HOSTS
  let i+=1
done

# add salt-master to ansible hosts file 
SALT_MASTER_IP_PRIVATE=$(terraform output salt-master-private)
echo "[salt-master]" | sudo tee -a $ANSBL_HOSTS
echo $SALT_MASTER_IP_PRIVATE | sudo tee -a $ANSBL_HOSTS
sed -i "/salt_master_ip/c\salt_master_ip: $SALT_MASTER_IP_PRIVATE" ansible/vars.yaml

# local hosts file 
sudo rm -f /etc/hosts
sudo touch /etc/hosts
cat $HOSTSFILE | sudo tee -a /etc/hosts


