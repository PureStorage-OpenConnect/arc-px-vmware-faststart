# Introduction

This repository contains terraform files that will create a Kubernetes cluster on VMware vSphere using a virtual machine template. The ultimate aim of this work is to 
be able to deploy an Azure Arc for Data Services controller or SQL Server 2019 Big Data Cluster to a virtualized infrastrutcure with little or no human intervention.

# Workflow

- Create virtual machines to host the Kubnernetes cluster master and worker nodes
- Git clone kubespray 
- Create an ansible inventory file for kubespray
- Execute `ansible-playbook` in order to create the Kubernete cluster

# Prerequisites

- VMware vSphere cluster
- Linux host that can talk to the vSphere endpoint, referred to as "the client machine" hereafter 
- Terraform and git installed on client machine
- The user under which terraform is executed as is a member of the sudo-ers group on the client machine (use visudo)
- Template virtual machine
  - OS user with ssh keys copied from client machine that terraform is instigated from - the same user that `terraform apply` is run as
  - `/etc/sshd_config` configured such that ssh does not prompt for passwords
  - No YAML file present in `/etc/netplan` directory
  - `preserve_hostname` set to true in `/etc/cloud/cloud.cfg` 

# Environment Config Has Been Tested With

- VMware vSphere 7.0.1
- Terraform v0.14.5 with the following providers
  - registry.terraform.io/hashicorp/local v2.0.0
  - registry.terraform.io/hashicorp/null v3.0.0
  - registry.terraform.io/hashicorp/template v2.2.0
  - provider registry.terraform.io/hashicorp/vsphere v1.24.3
- Linux client: Ubuntu 18.04
- Virtual machine template guest OS: Ubuntu 18.04
- Kubespray 2.15.0

# Instructions

This section assumes the use of Ubuntu 18.04.

1. Make the Hashicorp package repository trusted:

   `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`

2. Add the Hashicorp repository:

   `sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`

3. Install git and terraform:

   `sudo apt-get install terraform git`

4. Git clone this repo:

`git clone xxx`

5. Edit the virtual_machines.tf file, some salient points:
- Only worker nodes require px_disk_size to be set to a value greater than zero (disk Portworx volumes are created on), set this to 0 for master nodes
- The ipv4 subnet mask is in CIDR format
- In the example file provided, memory and logical CPU are specified for the minimum worker node requirement for Portworx and SQL Server 2019 Big Data Cluster nodes.

6. Edit the vsphere.tf file, pay special attention to the format of the `vsphere_resource_pool` variable, it is: 

   `/<data_center>/host/<cluster>/Resources/<resource_pool>`
  
7. Edit the kubernetes.tf file, this contains a single variable for the name of the subdirectory under which the kubespray (ansible) inventory directory will be created for your
   Kubernetes cluster. If for example this is set to `k8s_dev` and the user that `terraform apply` is executed under as is bdcuser, the inventory file will be contained in the
   directory:

   `/home/bdcuser/kubespray/inventory/k8s_dev`

8. Execute `terraform init` in order to download the terraform providers

9. Execute `terraform plan` in order to generate an execution plan, this also serves to check that variables are correct, for example if a VMware datastore has been
   specified that is incorrect, the VMware vSphere provider will report this.
  
10. Add the ip address, hostname pairs of the virtual machines in the `virtual_machines.tf` file to the `/etc/hosts` file on the client machine that terraform is to be run from. 
  
11. Execute `terraform apply`.

12. After approximately a minute and a half into the exection of the terraform config, a prompt will appear asking for the psuedo password for the Kubespray `ansible-playbook become-as-user`.

# To Do

Subsequent stages in in the development of this work inckudes:

- The deployment of Portworx to the Kubernetes cluster
- Deployment of an Azure Arc for Data Service controller or SQL Server 2019 Big Data Cluster to the cluster.
