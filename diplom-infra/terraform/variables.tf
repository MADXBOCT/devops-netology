# PKI
variable "PATH_TO_PRIVATE_KEY" {
  description = "Exact path to Private Key file location"
  default     = "~/.ssh/cicd"
  type        = string
}
variable "PATH_TO_PUBLIC_KEY" {
  description = "Exact path to Public Key file location"
  default     = "~/.ssh/cicd.pub"
  type        = string
}
# SSH
variable "SSH_USER" {
  description = "SSH User on remote VM"
  default     = "ubuntu"
  type        = string
}

variable "zones_master" {
  type    = list(string)
  default = ["ru-central1-a"]
}

variable "zones_worker" {
  type    = list(string)
  default = ["ru-central1-b", "ru-central1-d"]
}

variable "cidr" {
  type = list(string)
  default = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]

}