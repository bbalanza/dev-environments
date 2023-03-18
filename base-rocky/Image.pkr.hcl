variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "iso_checksum" {
  type    = string
  default = "69fa71d69a07c9d204da81767719a2af183d113bc87ee5f533f98a194a5a1f8a"
}

variable "iso_url" {
  type    = string
  default = "https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.1-x86_64-dvd.iso"
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
  default = "packer"
}

variable "ssh_timeout" {
  type    = string
  default = "15m"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
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
  default = "rockylinux-9"
}

variable "headless" {
  type = bool
  default = true
}

source "virtualbox-iso" "vbox" {
  guest_os_type          = "RedHat_64"
  shutdown_command       = "echo '${var.ssh_username}'|sudo -S /sbin/halt -h -p"
  ssh_password           = "${var.ssh_password}"
  ssh_timeout            = "${var.ssh_timeout}"
  ssh_username           = "${var.ssh_username}"
  ssh_handshake_attempts = "${var.ssh_handshake_attempts}"
  ssh_port               = "${var.ssh_port}"
  cpus                   = "${var.cpus}"
  memory                 = "${var.memory}"
  disk_size              = "${var.disk_size}"
  /* headless               = "${var.headless}" */
  http_directory         = "http"
  boot_wait              = "${var.boot_wait}"
  iso_url                = "${var.iso_url}"
  iso_checksum           = "${var.iso_checksum}"
  vm_name                = "${var.vm_name}"
  boot_command           =  [
          "<tab><bs><bs><bs><bs><bs>inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
        ]
}

build {
  sources = ["source.virtualbox-iso.vbox"]

  provisioner "ansible" {
    playbook_file = "provisioning/ansible.yml"
    command = "ansible-playbook"
    user = "vagrant"
    inventory_file_template = "base ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }}\n"
    ansible_ssh_extra_args = ["-oHostKeyAlgorithms=+ssh-rsa", "-oPubkeyAcceptedKeyTypes=+ssh-rsa", "-o IdentitiesOnly=yes"]
    extra_arguments = ["--scp-extra-args", "'-O'"]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
    }
  }
}
