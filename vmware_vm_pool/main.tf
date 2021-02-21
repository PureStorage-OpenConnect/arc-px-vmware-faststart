provider "vsphere" {
  user           = var.vsphere_user
  password       = var.VSPHERE_PASSWORD
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

module "virtual_machine" {
  source = "./modules/virtual_machine"
}
