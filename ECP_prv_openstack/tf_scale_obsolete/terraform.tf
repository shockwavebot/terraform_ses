# REQUIREMENTS:
# 	- source ECP_provo.sh # with all shell vars to connect to openstack instance 
# 	- images available 					: openstack image list 
# 	- network sesci available 			: openstack network list 
# 	- flavor m1.medium available 		: openstack flavor list 
# 	- security group default available 	: openstack security group list 

provider "openstack" {
}

output "public-ip" {
   value = "${join(" ", openstack_networking_floatingip_v2.fip.*.address)}"
}

output "private-ip-mon" {
   value = "${join(" ", openstack_compute_instance_v2.mon_node.*.access_ip_v4)}"
}

output "private-ip-osd" {
   value = "${join(" ", openstack_compute_instance_v2.osd_node.*.access_ip_v4)}"
}

output "salt-master" {
    value = "${openstack_networking_floatingip_v2.fip.0.address}"
}

output "salt-master-private" {
    value = "${openstack_compute_instance_v2.mon_node.0.access_ip_v4}"
}

variable "os_flavor" {}
variable "os_image" {}
variable "disk_size" {}
variable "disk_num" {}
variable "mon_nodes" {}
variable "osd_nodes" {}
variable "repos" {
  description = "Repos for zypper"
  type = "map"
  default = {
  }
}
variable "target_id" {}

resource "openstack_blockstorage_volume_v2" "osd_disk" {
    depends_on = ["openstack_compute_instance_v2.osd_node"]
    name = "qa-volume-${var.target_id}-${ count.index / var.disk_num }-${ count.index % var.disk_num }"
    count = "${ var.osd_nodes * var.disk_num }"
    size = "${var.disk_size}"
}

resource "openstack_compute_instance_v2" "mon_node" {
    region = ""
    count = "${var.mon_nodes}"
    name = "mon-${var.target_id}-${count.index}"
    image_name = "${var.os_image}"
    flavor_name = "${var.os_flavor}"
    key_pair = "mstan"
    security_groups = ["default"]
    metadata {
        demo = "metadata"
    }
    network {
        name = "sesci"
    }
}

resource "openstack_compute_instance_v2" "osd_node" {
    region = ""
    count = "${var.osd_nodes}"
    name = "osd-${var.target_id}-${count.index}"
    image_name = "${var.os_image}"
    flavor_name = "${var.os_flavor}"
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
  count = "${var.mon_nodes}"
  pool = "floating"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  count = "${var.mon_nodes}"
  floating_ip = "${element(openstack_networking_floatingip_v2.fip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.mon_node.*.id, count.index)}"
}

resource "openstack_compute_volume_attach_v2" "attached-osd" {
    count = "${ var.osd_nodes * var.disk_num }"
    instance_id = "${element(openstack_compute_instance_v2.osd_node.*.id, count.index / var.disk_num )}"
    volume_id = "${element(openstack_blockstorage_volume_v2.osd_disk.*.id, count.index)}"
}
