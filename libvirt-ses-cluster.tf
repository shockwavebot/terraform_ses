provider "libvirt" {
  uri = "${var.libvirt_uri}"
}

variable "ses" {}
variable "suffix" {}
variable "remote_user" {}
variable "dns_zone_name" {}
variable "ses_flavor" { type = "map" }
variable "libvirt_uri" {}
variable "storage_pool" {}
variable "image" {}
variable "osd_count" {}
variable "osd_disk_size" {}

#####################
# GLOBAL PARAMETERS #
#####################

# SLES12 SP3 Image
resource "libvirt_volume" "sles12sp3" {
  name   = "sles12sp3_img"
  source = "${var.image}"
  pool   = "${var.storage_pool}"
}

###################
#     SES         #
###################

resource "libvirt_volume" "ses" {
  count          = "${var.ses}"
  name           = "${format("ceph-ses-${var.suffix}%02d", count.index + 1)}.qcow2"
  pool           = "${var.storage_pool}"
  base_volume_id = "${libvirt_volume.sles12sp3.id}"
}

resource "libvirt_volume" "osd" {
  count          = "${var.osd_count}"
  name           = "${format("osd-disk-%02d", count.index + 1)}"
  size           = "${var.osd_disk_size}"
  pool           = "${var.storage_pool}"
}

resource "libvirt_domain" "ses" {
  count     = "${var.ses}"
  name      = "${format("ceph-ses-${var.suffix}%02d", count.index + 1)}"
  memory    = "${var.ses_flavor["memory"]}"
  vcpu      = "${var.ses_flavor["vcpu"]}"

  disk {
    volume_id = "${element(libvirt_volume.ses.*.id, count.index)}"
  }

  disk {
    volume_id = "${element(libvirt_volume.osd.*.id, 3 * count.index )}"
  }

  disk {
    volume_id = "${element(libvirt_volume.osd.*.id, 3 * count.index +1)}"
  }

  disk {
    volume_id = "${element(libvirt_volume.osd.*.id, 3 * count.index +2)}"
  }

  network_interface {
    network_name   = "vnet1"
    wait_for_lease = 1
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = 0
  }

  connection {
    user = "${var.remote_user}"
    agent = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname --static ${format("ceph-ses-${var.suffix}%02d.${var.dns_zone_name}", count.index + 1)}",
      "echo \"127.0.0.1 ${format("ceph-ses-${var.suffix}%02d.${var.dns_zone_name}", count.index + 1)}  localhost\" >/etc/hosts"
    ]
  }
}

output "ses_ip" {
  value = ["${libvirt_domain.ses.*.network_interface.0.addresses.0}" , "${libvirt_domain.ses.*.name}"]
}

