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

#### Prepare artifacts 

Make sure `remote_tf/ansible/artifacts.yaml` are updated with latest repos

```
- name: ceph_repo5
  delivery: mirror
  url: /mnt/dist/install/SUSE-Enterprise-Storage-5.5-M9/
  filters: x86_64 Media1 iso$
- name: base_repo5
  delivery: mirror
  url: /mnt/dist/ibs/SUSE:/SLE-12-SP3:/GA/images/repo/
  filters: Server-POOL-x86_64 Media1$

source VENV36/bin/activate
python lib/artifact.py deliver --input artifacts/desc/mstan-5.5-x86_64-product.yaml --delivery artifacts/delivery-prv.suse.net.conf
python lib/artifact.py determine --input artifacts/desc/mstan-5.5-x86_64-product.yaml --delivery artifacts/delivery-prv.suse.net.conf
```


