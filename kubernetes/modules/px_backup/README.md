# Overview

This module deploys Portworx PX Backup and Azure objects: service principal, storage account and container neccessary for backing up kubernetes cluster objects to the 
Azure cloud.

# Usage

## Apply

Execute the following command from the `Arc-PX-VMware-Faststart/kubernetes` directory
```
terraform apply -target=module.px_backup --auto-approve 
```

## Destroy

```
terraform destroy -target=module.px_backup --auto-approve 
```

# Dependencies

- Azure account
- An on-premises kubernetes cluster to deploy PX Backup to

# Portworx Spec Creation

# Variables

The minimum set of variables that need to be configured consists of those with no default values.

| Name                          | Data type | Description / Notes                                                 | Mandatory (Y/N) | Default Value                   |
|-------------------------------|-----------|---------------------------------------------------------------------|-----------------|---------------------------------|
| helm_chart_version            | string    | PX Backup helm chart version to be deployed                         |        Y        | 1.2.2                           |
| storage_class                 | string    | Store class to use for PX Backup metadata state                     |        Y        | portworx-sc                     |
| namespace                     | string    | Namespace to create PX Backup objects in                            |        Y        | px-backup                       |
| azure_subscription_id         | string    | Azure subscription to use for when creating Azure objects           |        Y        | **No defaulkt value**           |                            |
| azure_resource_group          | string    | Resource group to associate Azure objects with                      |        Y        | px-backup-rg                    |
| azure_location                | string    | Azure location to create Azure objects in                           |        Y        | uksouth                         | 
| azure_storage_account_name    | string    | Name to give Azure storage account                                  |        Y        | portworxpxbackup                |
| azure_storage_account_tier    | string    | Azure storage tier to use                                           |        Y        | Standard                        |
| azure_storage_data_redundancy | string    | Azure storage redundancy                                            |        Y        | LRS                             |
| azure_storage_blob_container  | string    | Name to create Azure blob container with                            |        Y        | pxbackup                        |
| application_name              | string    | Application name to create for PX Backup in Azure Ad                |        Y        | portworx_px_backup              |
| password_length               | number    | Length of password to create for Azure Ad principal                 |        Y        | 16                              |
| password_special              | string    | Special characters to use for principal password                    |        Y        | \_\%\@                          |                            
| password_override_special     | boolean   | Override for use of supplied special characters for password        |        Y        | true                            |

# Example

This walkthough covers the full installation of PX Backup via this module and its use to backup and resdtore a SQL Server 2019 Big Data Cluster storage pool.

TBC

# Known Issues / Limitations

None noted.

[Back to root module](https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/README.md)
