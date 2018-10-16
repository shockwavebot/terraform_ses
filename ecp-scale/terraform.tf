# REQUIREMENTS:
# 	- source ECP_provo.sh # with all shell vars to connect to openstack instance 
# 	- images available 					: openstack image list 
# 	- network sesci available 			: openstack network list 
# 	- flavor m1.medium available 		: openstack flavor list 
# 	- security group default available 	: openstack security group list 

provider "openstack" {
}

output "ip" {
   value = "${join(" ", openstack_networking_floatingip_v2.fip.*.address)}"
}

output "public-ip" {
   value = "${join(" ", openstack_networking_floatingip_v2.fip.*.address)}"
}

output "private-ip" {
   value = "${join(" ", openstack_compute_instance_v2.node.*.access_ip_v4)}"
}

output "salt-master" {
    value = "${openstack_networking_floatingip_v2.fip.0.address}"
}

output "salt-master-private" {
    value = "${openstack_compute_instance_v2.node.0.access_ip_v4}"
}

resource "openstack_compute_instance_v2" "node" {
    region = ""
    count = "1"
    name = "ses-tf-deploy"
    image_name = "CentOS-7"
    flavor_name = "m1.large"
    key_pair = "mstan"
    security_groups = ["default"]
    metadata {
        demo = "metadata"
    }
    network {
        name = "sesci"
    }
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = "1"
  pool = "floating"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  count = "1"
  floating_ip = "${element(openstack_networking_floatingip_v2.fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.node.*.id, count.index)}"
}

