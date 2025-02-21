locals {
  cloud_init = {
    user           = "ubuntu"
    password       = "1234"
    ssh_public_key = file("~/.ssh/cloud_init.pub")
  }
}