#!/bin/bash

DEPLOY_HOST=$(terraform output public-ip)

# install ansible and other sw
ssh centos@$DEPLOY_HOST sudo yum install -y ansible wget unzip --nogpgcheck
# install terraform
ssh centos@$DEPLOY_HOST wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
ssh centos@$DEPLOY_HOST sudo unzip -d /usr/local/bin/ terraform_0.11.7_linux_amd64.zip

# copy tf directory
scp -r remote_tf/ centos@$DEPLOY_HOST:~/

# copy ssh keys
scp ~/.ssh/mstan centos@$DEPLOY_HOST:~/.ssh/id_rsa
scp ~/.ssh/mstan.pub centos@$DEPLOY_HOST:~/.ssh/id_rsa.pub

cat <<EOF > /tmp/prepare
sudo sed -i "/StrictHostKeyChecking/c\StrictHostKeyChecking no" /etc/ssh/ssh_config

cd remote_tf
source ECP_provo.sh
terraform init
terraform apply -auto-approve

sleep 180

./tf_set_hosts_ansbl_hosts_files.sh

cd ansible
ansible-playbook disable_firewall.yaml
ansible-playbook hosts_file.yaml
ansible-playbook set_hostname.yaml
ansible-playbook repos.yaml
ansible-playbook ntp.yaml
ansible-playbook salt.yaml
EOF

ssh centos@$DEPLOY_HOST 'bash -sxe' < /tmp/prepare
