#!/bin/bash

sript_start_time=$(date +%s)

set -ex

source ECP_provo.sh

terraform init
terraform apply -auto-approve

sleep 180 

# generating /tmp/hosts and /tmp/ansible_hosts files 
./tf_set_hosts_ansbl_hosts_files.sh

MASTER=$(terraform output salt-master)

# TODO configure salt master
# 	- apply all playbooks 
# 	- transfer ssh keys 
# 	- transfer playbooks
# 	- transfer hosts and ansible_hosts files 

set +ex 
sript_end_time=$(date +%s);script_runtime=$(((sript_end_time-sript_start_time)/60))
echo
echo "============================"
echo "Runtime in minutes : " $script_runtime
echo "============================"
echo
