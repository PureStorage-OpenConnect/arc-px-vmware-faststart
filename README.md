# Introduction

This repository contains terraform configurations for deploying SQL Server 2019 Big Data Clusters and Azure Arc Enabled Data Services Controllers to infrastructure 
virtualized via VMware. The "Full stack" solution involves the deployment of four terraform configurations:

- [virtual_machine](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/vmware_vm_pool/modules/virtual_machine/README.md) module for creating 
  virtual machines to underpin a kubernetes cluster on, this requires that an Ubuntu 18.04 virtual machine template is created, as detailed in the instructions provided
  in this documentation. 

- [kubernetes_cluster](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/kubernetes/modules/kubernetes_cluster/README.md) module for creating am 
  kubernetes cluster.

- [portworx](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/kubernetes/modules/portworx/README.md) module for deploying portworx to a kubernetes
  cluster. Portworx is a 100% software defined Kubernetes storage solution that can deployed to Red Hat OpenShift, Kubernetes on-premises, Google Anthos, AKS, EKS or GKE. 
  **Note that [Portworx Essentials](https://docs.portworx.com/concepts/portworx-essentials/) is free to use.**
  
- [big_data_cluster](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/azure_data_services/modules/big_data_cluster/README.md) module for deploying
  a big data cluster to a kubernetes cluster.
  
- [azure_arc_ds_controller](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/azure_data_services/modules/azure_arc_ds_controller/README.md) module
  for deploying an Azure Arc enabled Data Services Controller to a kubernetes cluster.
  
**However**, each module can be deployed independantly, meaning - if you are using:

- GKE, EKS, OpenShift or a Kubernetes cluster deployed to (for example) a NUC based home lab, you can use the portworx, Big Data Cluster and Azure Arc Enabled Data
  Services Controller modules.
- Infrastructure you have already provisioned on Hyper-V or Linux KVM, you can still use the kubernetes, portworx, Big Data Cluster and Azure Arc Enabled Data Services
  Controller modules.  

# Prerequisites

- VMware vSphere cluster
- Linux host that can talk to the vSphere endpoint, referred to as **"The build server"** hereafter 
- Terraform and git installed on client machine
- The user under which terraform is executed as is a member of the sudo-ers group on the client machine (use visudo)
- Template virtual machine with Ubuntun 18.04 server as the guest OS
- An Azure account
- Azure CLI installed on the build server
  
# Environment Config Has Been Tested With

- Azure CLI 2.19.1 
- VMware vSphere 7.0.1
- Terraform v0.14.5 with the following providers
  - registry.terraform.io/hashicorp/local v2.0.0
  - registry.terraform.io/hashicorp/null v3.0.0
  - registry.terraform.io/hashicorp/template v2.2.0
  - registry.terraform.io/hashicorp/vsphere v1.24.3
  - registry.terraform.io/hashicorp/azuread v1.4.0
  - registry.terraform.io/hashicorp/azurerm v2.48.0
- Linux client: Ubuntu Server 18.04 LTS
- Virtual machine template guest OS: Ubuntu 18.04
- Kubespray 2.15.0

# Instructions

## Virtual Machine Template Creation

1. In VMware vSphere vCenter create a new virtual machine:

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware1.PNG?raw=true">

2. Give the virtual machine a name

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware2.PNG?raw=true">

3. Assign a compute resource to the virtual machine

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware3.PNG?raw=true">

4. Select a datastore for the virtual machine

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware4.PNG?raw=true">

5. Choose the compatibility level for the virtual machine, the latest version of vSphere available will suffice

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware5.PNG?raw=true">

6. Select the guest OS family of Linux and the guest OS type of Ubuntu 64

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware6.PNG?raw=true">

7. Set the logical CPU, memory, disk and CD/DVD resources for the virtual machine - connect the datastore ISO for Ubuntu 18.04 server LTS to the CD/DVD drive, this can
   be downloaded from this [link](https://ubuntu.com/download/server) 

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware7.PNG?raw=true">

8. Review the configuration of the virtual machine and hit Finish

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/vmware/vmware8.PNG?raw=true">

9. Power on the virtual machine and go to the guest OS console.

10. Whilst configuring the guest OS, use tab to navigate around the screen, space-bar to toggle through configuration options and enter to confirm choices.

11. Choose the guest OS language

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu1.PNG?raw=true">

12. Choose the option to update to the new installer

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu2.PNG?raw=true">

13. Select the desired keyboard layout

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu3.PNG?raw=true">

14. Accept the default NIC configuration

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu4.PNG?raw=true">

15. Enter a proxy on this screen if one is required to access the internet

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu5.PNG?raw=true">

16. Accept the default mirror site

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu6.PNG?raw=true">

17. Choose the default option to use entire disk when creating the root filesystem

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu7.PNG?raw=true">

18. Confirm that the default layout is to be used

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu8.PNG?raw=true">

19. Confirm that you wish the installation process to destroy anything that might be on the OS disk - because this is a clean install, there is nothing to destroy

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu9.PNG?raw=true">

20. Enter details for the username and machine name, azuser and ubuntu-1804-template respectively

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu10.PNG?raw=true">

21. Use the spacebar to tick the option to install the OpenSSH server

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu11.PNG?raw=true">

22. No optional packages and required, so go straight to Done

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu12.PNG?raw=true">

23. Ubuntu will now install

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu13.PNG?raw=true">

24. When the Reboot now option appears, select this

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu14.PNG?raw=true">

25. Disconnect the CD/DVD drive in vSphere vCenter and hit enter

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu15.PNG?raw=true">

26. Login as azuser using the password entered earlier in step 20

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/ubuntu/ubuntu16.PNG?raw=true">

27. Whilst still in the virtual machine console add azuser to the sudo-ers group:
- enter sudo visudo
- at the end of the file which will appear in the nano editor add the following line
`azuser ALL=(ALL:ALL) NOPASSED:ALL`
- CTRL+X then Y to save this change

28. Enable the azuser user on the main setup machine to ssh onto the virtual machines that will created from the template without having to provide a password:
- `sudo vi /etc/ssh/sshd_config` (alternatively you can use the nano editor)
- change the line `UsePAM yes` to `UsePAM no`
- change the line `#PasswordAuthentication yes` to `PasswordAuthentication no`
- change the line `ChallengeResponseAuthentication yes` to `ChallengeResponseAuthentication no`
- save the changes and exit the editor - `CTRL+[` , `SHIFT+:`, `wq!` (for vi)

29. Configure cloud init:
- `sudo vi /etc/cloud/cloud.cfg`
- change the line `preserve_hostname: false` to `preserve_hostname: true`
- save the changes and exit the editor - `CTRL+[` , `SHIFT+:`, `wq!` (for vi)

30. Configure the virtual machine's NIC with a static ip address
- `sudo vi /etc/netplan/00-installer-config.yaml`
- change the contents of the file to:
```
# This is the network config written by 'subiquity'
network:
  ethernets:
    ens160:
      addresses:
      - 192.168.123.45/22
      gateway4: 192.168.123.1
      nameservers:
        addresses:
        - 192.168.123.2
        search:
        - lab.myorg.com
  version: 2
```
- **NOTE** change the IP addresses to those that are appropriate to your network, the last octet for the gateway ip address is usually one, the main IP address is always in CIDR  format
- save the changes and exit the edit - CTRL+[ , SHIFT+:, wq! in te vi editor
- Check that your changes are correct by issuing `sudo netplan apply`

31. On the main machine that will be used to drive the creation of the Kubenetes cluster whilst logged in as azuser create a ssh public/private key pair:
- `ssh-keygen`
- you will be prompted for a password, for the purposes of simplicity use the same one that was used when azuser was specified during the guest OS installation for the template virtual machine
- copy the public key onto the template virtual machine: `ssh-copy-id azuser@192.168.123.45`, you will be prompted for the azuser password and confirmation as to whether you want the public
  key to be added to keystore for the template virtual machine, select te default option of yes

32. Log onto the template virtual machine and apply updates and upgrade the kernel:
- `sudo apt-get update`
- `sudo apt-get upgrade`
- `sudo apt-get install --install-recommends linux-generic-hwe-18.04` 

33. Remove the NIC config for the virtual machine template, log into the template virtual machine:

`sudo mv /etc/newtplan/00-installer-config.yaml ~/.`

34. Shutdown the template virtual machine:

`sudo shutdown now`

35. In VMware vCenter right click on the ubuntu-18.04-template virtual machine, select template and then the option to convert this to a template.

## Portworx Spec creation

1. Log into [Portworx Central](https://central.portworx.com/specGen/wizard)

2. Select te Portworx Essentials radio button

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px1.PNG?raw=true">

3. Enter the Kubernetes version in the Kubernetes version box, tis configuration uses version 1.19.7 by defualt

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px2.PNG?raw=true">

4. Click the "On Premises" radio button and place ticks in the boxes for:
- auto create journal device
- skip KVDB device

   Finally, hit next 

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px3.PNG?raw=true">

5. Accept the networking defaults by clicking on next

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px4.PNG?raw=true">

6. On the Customize tab check "Enable stork" and "Enable CSI" and then hit next

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px5.PNG?raw=true">

7. Accept the agreement for using Portworx

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px6.PNG?raw=true">

8. Enter a spec name and label 

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/portworx/px7.PNG?raw=true">

## Kubernetes and Azure Data Services Creation

The following steps are to be performed on the same machine used to copy the public ssh key onto the template virtual machine:

1. Make the Hashicorp package repository trusted:

   `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`

2. Add the Hashicorp repository:

   `sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`

3. Install git and terraform:

   `sudo apt-get install terraform git`

4. Git clone this repo:

   `git clone https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart.git`

5. Choose the configuration(s) to deploy, currently there are three subdirectories containing different `terraform` configurations in module form:

- vmware_vm_pool
  - use the [virtual_machine](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/vmware_vm_pool/modules/virtual_machine/README.md) module to create the virtual machines that underpin your kubernetes cluster - using the template created as per the instuctions provided earlier
    in this README 
  
- kubernetes
  - use the [kubernetes_cluster](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/kubernetes/modules/kubernetes_cluster/README.md) module for creating a kubernetes cluster
  - use the [portworx](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/kubernetes/modules/portworx/README.md) module for deploying portworx to a kubernetes cluster
  
- azure_data_services
  - use the [big_data_cluster](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/azure_data_services/modules/big_data_cluster/README.md) module for deploying a big data cluster to the kubernetes cluster
  - use the [azure_arc_ds_controller](https://github.com/PureStorage-OpenConnect/Arc-PX-VMware-Faststart/blob/main/azure_data_services/modules/azure_arc_ds_controller/README.md) module for deploying an Azure Arc enabled Data Services Controller to the kubernetes cluster

# Known Issues / Limitations

This configuration does not currently work with a virtual macine template based on Ubuntu versions 20.04/20.10

# Roadmap

Subsequent stages in in the development of this work includes:

- Ubuntu 20.04/20.10 support
- Deployment of a MetalLB load balancer
- Deployment of Azure Data Services with load balancer endpoints

# Feedback

Feedback is welcome and should be submitted via the creation of issues.

# Credits 
Credit goes to both the EMEA Solutions Architects; Eugenio Grosso and Joe Gardiner for helping in putting this work together.
