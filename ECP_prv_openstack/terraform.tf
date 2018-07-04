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

output "client" {
    value = "${openstack_networking_floatingip_v2.fip.0.address}"
}

output "salt-master-private" {
    value = "${openstack_compute_instance_v2.node.0.access_ip_v4}"
}

output "ansible" {
    value = "[admin]\n${openstack_networking_floatingip_v2.fip.0.address}\n[nodes]\n${join("\n",slice(openstack_networking_floatingip_v2.fip.*.address, 1, length(openstack_networking_floatingip_v2.fip.*.address)))}\n[saltmaster]\n${openstack_compute_instance_v2.node.0.access_ip_v4}"
}
output "ansible-private" {
    value = "[admin]\n${openstack_compute_instance_v2.node.0.access_ip_v4}\n[nodes]\n${join("\n",slice(openstack_compute_instance_v2.node.*.access_ip_v4, 1, length(openstack_compute_instance_v2.node.*.access_ip_v4)))}"
}

variable "os_flavor" {}
variable "os_image" {}
variable "disk_size" {}
variable "disk_num" {}
variable "nodes" {}
variable "repos" {
  description = "Repos for zypper"
  type = "map"
  default = {
  }
}
variable "target_id" {
  default = "ses"
}

resource "openstack_blockstorage_volume_v2" "disk" {
    depends_on = ["openstack_compute_instance_v2.node"]
    name = "qa-volume-${var.target_id}-${ count.index / var.disk_num }-${ count.index % var.disk_num }"
    count = "${ var.nodes * var.disk_num }"
    size = "${var.disk_size}"
}

resource "openstack_compute_instance_v2" "node" {
    region = ""
    count = "${var.nodes}"
    name = "qa-${var.target_id}-${count.index}"
    image_name = "${var.os_image}"
    flavor_name = "${var.os_flavor}"
    key_pair = "sesqa-automation"
    security_groups = ["default"]
    metadata {
        demo = "metadata"
    }
    network {
        name = "sesci"
    }
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = "${var.nodes}"
  pool = "floating"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  count = "${var.nodes}"
  floating_ip = "${element(openstack_networking_floatingip_v2.fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.node.*.id, count.index)}"
}

resource "openstack_compute_volume_attach_v2" "attached" {
    count = "${ var.nodes * var.disk_num }"
    instance_id = "${element(openstack_compute_instance_v2.node.*.id, count.index / var.disk_num )}"
    volume_id = "${element(openstack_blockstorage_volume_v2.disk.*.id, count.index)}"
}

