module "azure_arc_ds_controller" {
  source = "./modules/azure_arc_ds_controller"
  AZDATA_PASSWORD = var.AZDATA_PASSWORD
}

module "big_data_cluster" {
  source = "./modules/big_data_cluster"
  AZDATA_PASSWORD = var.AZDATA_PASSWORD
}
