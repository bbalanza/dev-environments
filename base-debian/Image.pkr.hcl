variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "iso_checksum" {
  type    = string
  default = "41735b046219d74832e033205130bce4dbbc2aa72ae81d8143aea278618a638599e1d4b7a0d9ba04f3ff44431208845be3868e313f0c258d9b232423c3f52438"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-11.6.0-amd64-DVD-1.iso"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type = string
  default = "40960"
}

variable "ssh_password" {
  type    = string
  default = "vmnaut"
}

variable "ssh_timeout" {
  type    = string
  default = "15m"
}

variable "ssh_username" {
  type    = string
  default = "vmnaut"
}

variable "ssh_handshake_attempts" {
  type    = number
  default = 75
}

variable "ssh_port" {
  type = number
  default = 22
}

variable "vm_name" {
  type = string
  default = "debian-11.0.0-amd64"
}

variable "headless" {
  type = bool
  default = false
}

source "virtualbox-iso" "vbox" {
  guest_os_type          = "debian11-64"
  shutdown_command       = "echo 'packer'|sudo -S shutdown -P now"
  ssh_password           = "${var.ssh_password}"
  ssh_timeout            = "${var.ssh_timeout}"
  ssh_username           = "${var.ssh_username}"
  ssh_handshake_attempts = "${var.ssh_handshake_attempts}"
  ssh_port               = "${var.ssh_port}"
  cpus                   = "${var.cpus}"
  memory                 = "${var.memory}"
  disk_size              = "${var.disk_size}"
  headless               = "${var.headless}"
  http_directory         = "http"
  boot_wait              = "${var.boot_wait}"
  iso_url                = "${var.iso_url}"
  iso_checksum           = "${var.iso_checksum}"
  vm_name                = "${var.vm_name}"
  boot_command           =  [
          "<esc><wait>",
          "auto <wait>",
          "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <enter><wait>",
        ]
}

build {
  sources = ["source.virtualbox-iso.vbox"]

  provisioner "ansible" {
    playbook_file = "provisioning/ansible.yml"
    command = "ansible-playbook"
    user = "vmnaut"
    inventory_file_template = "base_debian ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }} ansible_sudo_pass={{ .User }}\n"
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
    }
  }
}
