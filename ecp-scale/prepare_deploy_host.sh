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
scp ~/.ssh/mstan* centos@$DEPLOY_HOST:~/.ssh/


