# Usage

- Configure the variables in the `vmware_vm_pool\modules\virtual_machine\variables.tf` file per the instructions below
- Execute the following commands from within the `vmware_vm_pool` directory: 
```
terraform init
terraform apply -target=module.virtual_machine --auto-approve 
```
To reverse this action, execute:
```
terraform destroy -target=module.virtual_machine 
```

# Overview

This module creates virtual machines based on a template via the terraform VMware vSphere provider

# Dependencies

- a VMware vSphere cluster is available 
- a template virtual machine created per the instructions in the [README.md](https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/README.md) 
  file in the root of this repository

# Variables

The minimum set of variables that need to be configured consists of those with no default values.

| Name                        | Data type | Description / Notes                                             | Mandatory (Y/N) | Default Value         |
|-----------------------------|-----------|-----------------------------------------------------------------|-----------------|-----------------------|
| vsphere_dc                  | string    | VMware vSphere datacenter object name                           |        Y        | **No default value**  |     
| vsphere_cluster             | string    | VMware vSphere datacenter cluster name                          |        Y        | **No default value**  |
| vsphere_host                | string    | Server in the vSphere cluster that virtual machines will run on |        Y        | **No default value**  |
| vsphere_datastore           | string    | Datastore for virtual machine storage                           |        Y        | **No default value**  |
| vsphere_network             | string    | Virtulized network for use by virtual machines                  |        Y        | **No default value**  |
| vsphere_resource_pool       | string    | Resource pool that virtual machines are to be allocated to      |        Y        | **No default value**  |
| vm_template                 | string    | Template used for virtual machine creation                      |        Y        | ubuntu-18.04-template |
| vm_domain                   | string    |                                                                 |        Y        |                       |
| vm_linked_clone             | boolean   | Specifies whether a virtual machine shares disk(s) with a parent|        Y        | false                 |

The copnfiguration information for the virtual machines created by this module is stored in the `virtual_machines` variable:
```
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
```
In addtion to these variables the following variables in the `variables.tf` to be found in the root of this repo also need to be set 

| Name                        | Data type | Description / Notes                                             | Mandatory (Y/N) | Default Value         |
|-----------------------------|-----------|-----------------------------------------------------------------|-----------------|-----------------------|
| vsphere_user                | string    | Name of user used to connect to VMware vSphere with             |        Y        | **No default value**  |     
| vsphere_server              | string    | VMware vSphere vCenter IP address                               |        Y        | **No default value**  |

**VSPHERE_PASSWORD** - the password for the user used to connect to vSphere vCenter with can be specified via the TF_VAR_VSPHERE_PASSWORD environment
variable, alternatively it can be specified when prompted for after issuing `terraform apply`

**AZDATA_PASSWORD** - can be specified via the TF_VAR_AZDATA_PASSWORD environment variable, alternatively it can be specified when prompted for after
issuing `terraform apply`

To reiterate the point made earlier, if all you are interested in is deploying this one module and none of the other related modules, execute the 
terraform commands in the directory containing the HCL code for this module - this removes the need to specify variables in the `variables.tf` files
for all of the other modules.

**Note**
- The compute node attribute should be set to true for virtual machine that host worker nodes, otherwise it should be set to false
- 120GB for the OS disk size was found to be the smallest size that could accomodated big data cluster container images, when configuring the guest OS, 
  half of this is allocated to the root filesystem, the rest is left free in reserve - a negligable overhead for datastores backed by thin provisioned
  storage 
- only assign the `px_disk_size` attribute a value for virtual machines that host worker nodes (`compute_node = true`)

# Known Issues / Limitations

None noted

[Back to root module](https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/README.md)
