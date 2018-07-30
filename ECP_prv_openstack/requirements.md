# Requirements
## Install

- python3 virtual env 
```
python3 -m venv VENV
source VENV/bin/activate
python -m pip install --upgrade pip
python -m pip install python-openstackclient
```
- python-openstackclient 
- openstack VARS in file that need to be sourced
- openstack settings:
	- image present: 	`openstack image list|grep SLES12-SP3`
        - network present: 	`openstack network list|grep sesci`
	- flavour present:	`openstack flavor list|grep m1.medium`
	- security group:	`openstack security group list|grep default` and ssh port 20 added as rule 
	- keypair present: 	`openstack keypair list|grep mstan`

## Create VMs

`terraform init`
`terraform apply -auto-approve`
`#terraform destroy # to destroy`

## How to access:

`ssh -i ~/.ssh/mstan.pub root@10.86.1.71`
