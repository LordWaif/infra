locals {
  index        = 0
  proxmox_host = "172.16.255.1"
  vm_id        = 9000
}

resource "local_file" "cloud_config" {
  content  = file("./cloud-config.yaml")
  filename = "./cloud-config.yaml"
}

resource "null_resource" "upload_cloud_config" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-rsa -i ~/.ssh/cloud_init ${path.module}/cloud-config.yaml root@${local.proxmox_host}:/var/lib/vz/snippets/cloud-config.yaml"
  }
}

resource "proxmox_vm_qemu" "cloud-init-test" {
  depends_on = [null_resource.upload_cloud_config]

  name        = "excalibur"
  boot        = "order=scsi0;net0"
  vmid        = local.vm_id
  target_node = "castor"
  clone       = "ubuntu-2204-cloud-init"
  full_clone  = true

  os_type = "ubuntu"
  scsihw  = "virtio-scsi-pci"
  serial {
    id   = 0
    type = "socket"
  }

  disk {
    slot = 0
  }

  agent      = 0
  ipconfig0  = "ip=${element(values(var.vm_ips), local.index)}/24,gw=10.2.50.1"
  ciuser     = local.cloud_init["user"]
  cipassword = local.cloud_init["password"]
  sshkeys    = local.cloud_init["ssh_public_key"]

  # cicustom = "user=local:snippets/cloud-config.yaml"

  # connection {
  #   type     = "ssh"
  #   host     = element(values(var.vm_ips), local.index)
  #   user     = local.cloud_init["user"]
  #   password = local.cloud_init["password"]
  #   # private_key = file("~/.ssh/cloud_init")
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "cloud-init status --wait"
  #   ]
  # }
}
