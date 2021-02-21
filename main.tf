provider "vsphere" {
  user           = var.vsphere_user
  password       = var.VSPHERE_PASSWORD
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "kubernetes_cluster_vm_pool" {
  source = "./modules/kubernetes_cluster_vm_pool"
}

module "kubernetes_cluster" {
  source = "./modules/kubernetes_cluster"
}

module "portworx" {
  source = "./modules/portworx"
}

module "big_data_cluster" {
  source = "./modules/big_data_cluster"
  AZDATA_PASSWORD = var.AZDATA_PASSWORD
}

module "azure_arc_ds_controller" {
  source = "./modules/azure_arc_ds_controller"
  AZDATA_PASSWORD = var.AZDATA_PASSWORD
}