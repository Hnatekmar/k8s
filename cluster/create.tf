terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }
  }
}

variable "proxmox_password" {}
variable "proxmox_username" {}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = "https://ps2:8006/api2/json"
  pm_password = var.proxmox_password
  pm_user = var.proxmox_username
  pm_otp = ""
  pm_parallel = 1
}

resource "proxmox_vm_qemu" "master" {
  name = "k8s-master"
  cores = "4"
  memory = 4096
  sockets = "1"
  vcpus = "0"
  cpu = "host"
  target_node = "proxmox"
  os_type = "cloud-init"
  clone = "debian-base"
  ciuser = "root"
  cipassword = ""
  nameserver = "172.16.100.1"
  sshkeys = <<EOF
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUCoQ5ZjHqe6wp8TfsTrwNkGoOP0IDftMrf3OS8fzgU martin@allmight
  EOF
  boot = "c"
  agent = 1
}

resource "proxmox_vm_qemu" "worker" {
  for_each = toset( ["proxmox", "worker0", "worker1"] )
  memory = 8096
  name = "k8s-worker-${each.key}"
  cores = "4"
  sockets = "1"
  vcpus = "0"
  cpu = "host"
  target_node = each.key
  os_type = "cloud-init"
  clone = "debian-base"
  ciuser = "root"
  cipassword = ""
  nameserver = "172.16.100.1"
  sshkeys = <<EOF
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUCoQ5ZjHqe6wp8TfsTrwNkGoOP0IDftMrf3OS8fzgU martin@allmight
  EOF
  boot = "c"
  agent = 1
}

