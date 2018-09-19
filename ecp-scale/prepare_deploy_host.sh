#!/bin/bash

DEPLOY_HOST=$(terraform output public-ip)

> ~/.ssh/known_hosts

# install ansible and other sw
ssh centos@$DEPLOY_HOST sudo yum install -y ansible wget unzip --nogpgcheck
# install terraform
ssh centos@$DEPLOY_HOST rm -f terraform*
ssh centos@$DEPLOY_HOST sudo rm -f /usr/local/bin/terraform
ssh centos@$DEPLOY_HOST wget -q https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
ssh centos@$DEPLOY_HOST sudo unzip -d /usr/local/bin/ terraform_0.11.7_linux_amd64.zip

# copy tf directory
ssh centos@$DEPLOY_HOST rm -rf remote_tf/
scp -r remote_tf/ centos@$DEPLOY_HOST:~/

# copy ssh keys
scp ~/.ssh/mstan centos@$DEPLOY_HOST:~/.ssh/id_rsa
scp ~/.ssh/mstan.pub centos@$DEPLOY_HOST:~/.ssh/id_rsa.pub

OSD_NODES=$(cat remote_tf/terraform.tfvars|grep osd_nodes|awk -F '"' '{print $4}')
let SLEEP=10*$OSD_NODES

cat <<EOF > /tmp/prepare
sex -ex
sudo sed -i "/StrictHostKeyChecking/c\StrictHostKeyChecking no" /etc/ssh/ssh_config

cd remote_tf
source ECP_provo.sh
terraform init
terraform apply -auto-approve

sleep $SLEEP

./tf_set_hosts_ansbl_hosts_files.sh

cd ansible
ansible-playbook disable_ipv6.yaml
ansible-playbook disable_firewall.yaml
ansible-playbook hosts_file.yaml
ansible-playbook set_hostname.yaml
ansible-playbook repos.yaml
ansible-playbook ntp.yaml
ansible-playbook salt.yaml

# TODO
# @salt-master sed -i "/ipv6-loopback/c\::1             localhost ipv6-localhost ipv6-loopback $(hostname)" /etc/hosts
set +ex

EOF

ssh centos@$DEPLOY_HOST 'bash -s' < /tmp/prepare

echo 'ssh centos@$(terraform output salt-master)'
