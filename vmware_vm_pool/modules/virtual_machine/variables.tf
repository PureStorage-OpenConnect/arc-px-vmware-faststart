variable "vsphere_dc" {
  description = "vSphere data center name"
  type        = string
  default     = "lab"
}

variable "vsphere_cluster" {
  description = "vSphere cluster name"
  type        = string
  default     = "Development"
}

variable "vsphere_host" {
  description = "vSphere ESXi host"
  type        = string
  default     = "lab.myorg.com"
}

variable "vsphere_datastore" {
  description = "Datastore to be used for provisioning virtual disks from"
  type        = string
  default     = "datastore-VSI"
}

variable "vsphere_network" {
  description = "Network to use for virtual machine"
  type        = string
  default     = "VM Network"
}

variable "vsphere_resource_pool" {
  description = "Resource pool to allocate virtual machine to"
  type        = string
  default     = "/lab/host/Development/Resources/CA"
}

variable "vm_template" {
  default = "ubuntu-18.04-template"
}

variable "vm_domain" {
  default = "lab"
}

variable "vm_linked_clone" {
  default = "false"
}

variable "virtual_machines" {
  default = {
    "z-ca-bdc-control1" = {
       name          = "z-ca-bdc-control1"
       compute_node  = false
       ipv4_address  = "192.168.123.88"
       ipv4_netmask  = "22"
       ipv4_gateway  = "192.168.123.1"
       dns_server    = "192.168.123.2"
       ram           = 8192 
       logical_cpu   = 4
       os_disk_size  = 120
       px_disk_size  = 0
    },
    "z-ca-bdc-control2" =  {
       name          = "z-ca-bdc-control2"
       compute_node  = false
       ipv4_address  = "192.168.123.89"
       ipv4_netmask  = "22"
       ipv4_gateway  = "192.168.123.1"
       dns_server    = "192.168.123.2"
       ram           = 8192
       logical_cpu   = 4
       os_disk_size  = 120
       px_disk_size  = 0
    },
    "z-ca-bdc-compute1" = {
       name          = "z-ca-bdc-compute1"
       compute_node  = true
       ipv4_address  = "192.168.123.90"
       ipv4_netmask  = "22"
       ipv4_gateway  = "192.168.123.1"
       dns_server    = "192.168.123.2"
       ram           = 73728
       logical_cpu   = 12
       os_disk_size  = 120
       px_disk_size  = 120 
    },
    "z-ca-bdc-compute2" = {
       name          = "z-ca-bdc-compute2"
       compute_node  = true
       ipv4_address  = "192.168.123.91"
       ipv4_netmask  = "22"
       ipv4_gateway  = "192.168.123.1"
       dns_server    = "192.168.123.2"
       ram           = 73728
       logical_cpu   = 12
       os_disk_size  = 120
       px_disk_size  = 120
    },
    "z-ca-bdc-compute3" = {
       name          = "z-ca-bdc-compute3"
       compute_node  = true
       ipv4_address  = "192.168.123.92"
       ipv4_netmask  = "22"
       ipv4_gateway  = "192.168.123.1"
       dns_server    = "192.168.123.2"
       ram           = 73728 
       logical_cpu   = 12
       os_disk_size  = 120
       px_disk_size  = 120
    }
  }
}
