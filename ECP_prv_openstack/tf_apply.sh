#!/bin/bash

sript_start_time=$(date +%s)

set -ex

source ECP_provo.sh

terraform init
terraform apply -auto-approve || (sleep 5;terraform apply -auto-approve)

sleep 160 

./tf_set_hosts_ansbl_hosts_files.sh

cd ansible
source ANSBL/bin/activate

ansible-playbook disable_firewall.yaml
ansible-playbook hosts_file.yaml
ansible-playbook set_hostname.yaml
ansible-playbook repos.yaml
ansible-playbook ntp.yaml
ansible-playbook salt.yaml

deactivate

set +ex 
sript_end_time=$(date +%s);script_runtime=$(((sript_end_time-sript_start_time)/60))
echo
echo "============================"
echo "Runtime in minutes : " $script_runtime
echo "============================"
echo
