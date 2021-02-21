# Declare TF variables
variable "kubernetes_version" {
  type        = string
  default     = "1.19.7"
}

variable "kubespray_inventory" {
  description = "Directory containing Kubespray (ansible) inventory file"
  type        = string
  default     = "ca_bdc"
}

variable "node_hosts" {
  default = {
    "z-ca-bdc-control1" = {
       name          = "z-ca-bdc-control1"
       compute_node   = false
       etcd_instance = "etcd1"
       ipv4_address  = "192.168.123.88"
    },
    "z-ca-bdc-control2" =  {
       name          = "z-ca-bdc-control2"
       compute_node   = false
       etcd_instance = "etcd2"
       ipv4_address  = "192.168.123.89"
    },
    "z-ca-bdc-compute1" = {
       name          = "z-ca-bdc-compute1"
       compute_node   = true
       etcd_instance = "etcd3"
       ipv4_address  = "192.168.123.90"
    },
    "z-ca-bdc-compute2" = {
       name          = "z-ca-bdc-compute2"
       compute_node   = true
       etcd_instance = ""
       ipv4_address  = "192.168.123.91"
    },
    "z-ca-bdc-compute3" = {
       name          = "z-ca-bdc-compute3"
       compute_node   = true
       etcd_instance = ""
       ipv4_address  = "192.168.123.92"
    }
  }
}
