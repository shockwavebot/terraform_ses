# Global
suffix = "qa-"
storage_pool = "VM"
image = "/VM/sles12sp3_tf_img.qcow2"
libvirt_uri = "qemu:///system"

# SSH
remote_user = "root"

# DNS
dns_zone_name = "qatest.local"

# Cluster nodes
ses = 5
ses_flavor = {
  vcpu = 1
  memory = 1024
}

# OSD disks
osd_count = 15
osd_disk_size = 32212254720

