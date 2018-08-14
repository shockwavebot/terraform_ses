# ECP scale 

## High level work flow

- Create one VM (scale-deploy running on CenOS-7) that will run all other commands and that will have floting IP
- From there run the rest of the terraform and ansible to setup the salt cluster

## Config settings

Edit before run:

- number of MON and OSD nodes: remote_tf/terraform.tfvars
- ECP_provo.sh credentials

## Run 

`source ECP_provo.sh`

`terraform apply -auto-approve`

`./prepare_deploy_host.sh`

#### To login to scale-deploy host:

`ssh centos@$(terraform output salt-master)`

To destroy the env: `cd remote_tf;source ECP_provo.sh;terraform destroy -auto-approve`

