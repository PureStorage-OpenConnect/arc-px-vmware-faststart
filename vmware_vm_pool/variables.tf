variable "vsphere_user" {
  description = "user for access vSphere vCenter appliance with"
  type        = string
  default     = "administrator@uklab.purestorage.com"
}

variable "VSPHERE_PASSWORD" {
  description = "Password associated with account for accessing vSphere vCenter appliance with"
  type        = string
}

variable "vsphere_server" {
  description = "vSphere server ip address"
  type        = string
  default     = "10.225.112.25"
}
