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
