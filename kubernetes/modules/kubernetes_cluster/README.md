# Overview

This module deploys a kubernetes cluster, installs kubectl and creates a context with which users can connect to the cluster with

# Usage

```
terraform apply -target=module.kubernetes_cluster --auto-approve 
```

There is currently no destroy provisioner built into the module by which this action can be reversed, the following command should therefore be used:
```
ansible-playbook -i <path to inventory.ini file> --become --become-user=root reset.yml
```

# Dependencies

- The user that terraform apply is executed under should be able to ssh onto each machine that will host a cluster node without being prompted for a password
- The user that terraform apply is executed under should be able a member of the sudoers groups
- The ip address/hostname pair for each cluster node host should be present in the `/etc/hosts` file on the machine that `terraform apply` is executed from

# Variables

The minimum set of variables that need to be configured consists of those with no default values.

| Name                        | Data type | Description / Notes                                                 | Mandatory (Y/N) | Default Value                   |
|-----------------------------|-----------|---------------------------------------------------------------------|-----------------|---------------------------------|
| use_csi                     | boolean   | Set to true if the Portworx spec has been created with              |        Y        | false                           |
| px_repl_factor              | number    | Number of persistent volume replicas to create for HA purposes      |        Y        | 2                               |
| px_spec                     | string    | URL for Portworx spec YAML manifest file                            |        Y        | **No default value**            |
| use_stork                   | boolean   | Determines whether the storage aware schedule should be used        |        Y        | true                            |

**Note:** Stork is not relevant when shared SAN type storage is in use.

# Known Issues / Limitations

Destroy provisioner yet be implemented for the null resource that deploys the kubernetes cluster. 

[Back to root module](https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/README.md)
