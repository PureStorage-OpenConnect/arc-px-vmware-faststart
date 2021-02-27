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

- Azure subscription
- An on-premises kubernetes cluster to deploy PX Backup to

# Portworx Spec Creation

# Variables

The minimum set of variables that need to be configured consists of those with no default values.

| Name                          | Data type | Description / Notes                                                 | Mandatory (Y/N) | Default Value                   |
|-------------------------------|-----------|---------------------------------------------------------------------|-----------------|---------------------------------|
| helm_chart_version            | string    | PX Backup helm chart version to be deployed                         |        Y        | 1.2.2                           |
| storage_class                 | string    | Store class to use for PX Backup metadata state                     |        Y        | portworx-sc                     |
| namespace                     | string    | Namespace to create PX Backup objects in                            |        Y        | px-backup                       |
| azure_subscription_id         | string    | Azure subscription to use for when creating Azure objects           |        Y        | **No default value**           |
| azure_resource_group          | string    | Resource group to associate Azure objects with                      |        Y        | px-backup-rg                    |
| azure_location                | string    | Azure location to create Azure objects in                           |        Y        | uksouth                         | 
| azure_storage_account_name    | string    | Name to give Azure storage account                                  |        Y        | portworxpxbackup                |
| azure_storage_account_tier    | string    | Azure storage tier to use                                           |        Y        | Standard                        |
| azure_storage_data_redundancy | string    | Azure storage redundancy                                            |        Y        | LRS                             |
| azure_storage_blob_container  | string    | Name to create Azure blob container with                            |        Y        | pxbackup                        |
| application_name              | string    | Application name to create for PX Backup in Azure Ad                |        Y        | portworx_px_backup              |
| password_length               | number    | Length of password to create for Azure Ad principal                 |        Y        | 16                              |
| password_special              | string    | Special characters to use for principal password                    |        Y        | \_\%\@                          |            | password_override_special     | boolean   | Override for use of supplied special characters for password        |        Y        | true                            |

# Example

This walkthough covers the full installation of PX Backup via this module and its use to backup and resdtore a SQL Server 2019 Big Data Cluster storage pool.

1. Modify the values in the `Arc-PX-VMware-Faststart/kubernetes/modules/px_backup/variables.tf` file as appropriate and then run:
```
terraform apply -target=module.px_backup --auto-approve 
```
   When this has completed it will display information required later for the configuration of Azure as a backup location, **make a note of this information**:
```
Outputs:

client_id = "a12bcde3-f456-789g-12h3-4ij56lm78no9"
client_secret = "XVMk1iqnrFWly6cj"
subscription_id = "/subscriptions/fg9z3eca-e3bb-7581-86e9-xz9f675f927w"
tenant_id = "1a2b3456-c78d-9123-efgh-456789i123jk"
```

2. Once the module has been successfully applied, assuming the namespace used is `px-backup`, issue:
```
kubectl get po -n px-backup
```
   The state of the PX Backup pods should appear as follows:
```
NAME                                       READY   STATUS      RESTARTS   AGE
px-backup-7947f877fd-7cktf                 1/1     Running     2          7m43s
pxc-backup-etcd-0                          1/1     Running     0          7m43s
pxc-backup-etcd-1                          1/1     Running     0          7m43s
pxc-backup-etcd-2                          1/1     Running     0          7m43s
pxcentral-apiserver-5d55fd855c-5rvr4       1/1     Running     0          7m43s
pxcentral-backend-849c9c8579-flrxk         1/1     Running     0          6m18s
pxcentral-frontend-6866f4646-mf78t         1/1     Running     0          6m18s
pxcentral-keycloak-0                       1/1     Running     0          7m43s
pxcentral-keycloak-postgresql-0            1/1     Running     0          7m43s
pxcentral-lh-middleware-58f95d767d-nn8qb   1/1     Running     0          6m18s
pxcentral-mysql-0                          1/1     Running     0          7m43s
pxcentral-post-install-hook-2fkws          0/1     Completed   0          7m43s
```
2. Issue the following command from a machine capable of supporting a web browser:
```
kubectl port-forward service/px-backup-ui 8080:80 --namespace px-backup
```
  **Note** if you have not already set up a connection context on this machine, copy the config file from the .kube directory of the machine that you run
  terraform commands from, e.g.
```
  scp azuser@<hostname>:/home/azuser/.kube/config C:\Users\cadkin\.kube\config
```
3. Enter the following in the browser URL address bar enter:
```
localhost:8080
```
4. Enter `admin` for the username and `admin` for the password on the initial login screen, then hit enter

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/px_backup/pb1.PNG?raw=true">

5. Enter a new password and confirm this as instructed:

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/px_backup/pb2.PNG?raw=true">

6. Update your user profile information to activate your account:

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/px_backup/pb3.PNG?raw=true">

7. Click on the **Add Cluster** button in the top right corner

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/px_backup/pb4.PNG?raw=true">

8. Give the cluster a name (a label), browse to the `.kube/config` file containing the connection context for the cluster, otherwise run the `kubectl` command as advised and 
   paste the output into the Kubeconfig box, finally - hit **Submit**

<img style="float: left; margin: 0px 15px 15px 0px;" src="https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/images/px_backup/pb5.PNG?raw=true">

9. Your kubernetes cluster should now be registered with PX Backup - called ca-bdc in this example:

10. Click on **Settings** in the top right corner and then cloud settings in order to make the cloud settings screen appear:

11. Click on **Add** in the top right corner and select Azure from the Cloud provider list of values. You will now be presented with a screen prompting for Azure account
    information:
-  Cloud Account Name:
-  Azure Account Name:
-  Azure Account Key :
-  Client Id         :
-  Client Secret     :
-  Tenant Id         :
-  Subscription Id   : 

# Known Issues / Limitations

None noted.

[Back to root module](https://github.com/PureStorage-OpenConnect/arc-px-vmware-faststart/blob/main/README.md)
