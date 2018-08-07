#!/bin/bash
# 
# - refresh local hosts file
# - refresh local ansible hosts file
# - generate hosts file entries in /tmp/hosts for future distribution

# source common variables
source common_VARS.sh

> ~/.ssh/known_hosts

# ansible 
[ -d /etc/ansible ] || sudo mkdir /etc/ansible
[ -e /etc/ansible/hosts ] || sudo touch /etc/ansible/hosts
sudo sed -i "/ses-nodes/d" /etc/ansible/hosts
echo "[ses-nodes]" | sudo tee -a /etc/ansible/hosts

HOSTSFILE=/tmp/hosts
rm -rf $HOSTSFILE||true;touch $HOSTSFILE
i=0
for ipa in $(terraform output ip)
do 
  echo $ipa ${BASENAME}-${i}.${DOMNAME} ${BASENAME}-${i} >> $HOSTSFILE
  # clean local hosts file
  sudo sed -i "/$ipa /d" /etc/hosts 
  sudo sed -i "/${BASENAME}-${i}.${DOMNAME} /d" /etc/hosts 
  # clean local ansible hosts file
  sudo sed -i "/$ipa/d" /etc/ansible/hosts 
  echo $ipa | sudo tee -a /etc/ansible/hosts
  let i+=1
done 

# private IPs are used for /etc/hosts on the nodes 
HOSTSFILE_PRIV=/tmp/hosts_priv
rm -rf $HOSTSFILE_PRIV||true;touch $HOSTSFILE_PRIV
i=0
for ipa in $(terraform output private-ip)
do
  echo $ipa ${BASENAME}-${i}.${DOMNAME} ${BASENAME}-${i} >> $HOSTSFILE_PRIV
  let i+=1
done

cat $HOSTSFILE | sudo tee -a /etc/hosts
