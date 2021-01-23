terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }
  }
}

variable "proxmox_url" {}
variable "proxmox_password" {}
variable "proxmox_username" {}
variable "proxmox_hosts" {}
variable "gateway" {}
variable "clone_from" {
  default = "debianGold"
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url = var.proxmox_url
  pm_password = var.proxmox_password
  pm_user = var.proxmox_username
  pm_otp = ""
  pm_parallel = 3
}

resource "proxmox_vm_qemu" "k8s-server" {
  for_each = var.proxmox_hosts
  memory = each.value.memory
  name = each.key
  cores = "4"
  sockets = "1"
  cpu = "host"
  target_node = each.value.name
  os_type = "cloud-init"
  clone = var.clone_from
  ciuser = "root"
  cipassword = ""
  ipconfig0 = "ip=${each.value.ip}/24,gw=${var.gateway}"
  nameserver = var.gateway
  sshkeys = <<EOF
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUCoQ5ZjHqe6wp8TfsTrwNkGoOP0IDftMrf3OS8fzgU martin@allmight
  EOF
  boot = "c"
  agent = 1
}

