# Overview

This module deploys Portworx to the target kubernetes cluster and creates a storage class

# Usage

```
terraform apply -target=module.portworx --auto-approve 
```

Currently the only reversal action for this module is to recreate the kubernetes cluster.

# Dependencies

- Context in .kube/config file of the home directory of the current user with which kubectl can connect to a kubernetes cluster
- Portworx spec created via [PX-Central](https://central.portworx.com/specGen/wizard)

# Variables

The minimum set of variables that need to be configured consists of those with no default values.

| Name                        | Data type | Description / Notes                                                 | Mandatory (Y/N) | Default Value                   |
|-----------------------------|-----------|---------------------------------------------------------------------|-----------------|---------------------------------|
| use_csi                     | boolean   | Set to true if the Portworx spec has been created with              |        Y        | false                           |
| px_repl_factor              | number    | Number of persistent volume replicas to create for HA purposes      |        Y        | 2                               |
| px_spec                     | string    | URL for Portworx spec YAML manifest file                            |        Y        | **No default value**            |
| use_stork                   | boolean   | Determines whether the storage aware schedule should be used       |        Y        | true                            |

**Note:** Stork is not relevant when shared SAN type storage is in use.

# Known Issues / Limitations

Destroy provisioner yet be implemented for the null resource that deploys Portworx to the kubernetes cluster. 

[Back to root module](https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/README.md)
