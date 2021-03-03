provider "azuread" {
  alias   = "azure_ad"
}

provider "azurerm" {
  features {}
  alias   = "azure_rm"
}

data "azurerm_subscription" "primary" {
  provider = azurerm.azure_rm
}

resource "azuread_application" "auth" {
  display_name  = var.application_name
}

resource "azuread_service_principal" "auth" {
  application_id = azuread_application.auth.application_id
}

resource "azuread_service_principal_password" "auth" {
  service_principal_id = azuread_service_principal.auth.id
  value                = random_string.password.result
  end_date_relative    = "240h" 
}

resource "random_string" "password" {
  length               = var.password_length
  special              = var.password_special
  override_special     = var.password_override_special
}

resource "azurerm_role_assignment" "contributor" {
  provider             = azurerm.azure_rm
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.auth.id
}

resource "azurerm_role_assignment" "portworx_px_backup" {
  provider             = azurerm.azure_rm
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_service_principal.auth.id
}

resource "azurerm_resource_group" "pxbackuprg" {
  provider = azurerm.azure_rm
  name     = var.azure_resource_group 
  location = var.azure_location
}    

resource "azurerm_storage_account" "pxbackup" {
  provider                 = azurerm.azure_rm
  name                     = var.azure_storage_account_name 
  resource_group_name      = azurerm_resource_group.pxbackuprg.name
  location                 = var.azure_location
  account_tier             = var.azure_storage_account_tier
  account_replication_type = var.azure_storage_data_redundancy 
}

resource "azurerm_storage_container" "pxbackup" {
  provider              = azurerm.azure_rm
  name                  = "content"
  storage_account_name  = azurerm_storage_account.pxbackup.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "pxbackup" {
  provider               = azurerm.azure_rm
  name                   = var.azure_storage_blob_container 
  storage_account_name   = azurerm_storage_account.pxbackup.name
  storage_container_name = azurerm_storage_container.pxbackup.name
  type                   = "Block"
}

resource "kubernetes_namespace" "px_backup" {
  metadata {
    name = var.namespace 
  }
}

resource "helm_release" "px_backup" {
  name       = "px-backup"
  repository = "http://charts.portworx.io"
  chart      = "px-backup"
  namespace  = kubernetes_namespace.px_backup.metadata.0.name

  set {
    name  = "version"
    value = var.helm_chart_version
  }

  set {
    name  = "persistentStorage.enabled"
    value = true 
  }

  set {
    name  = "persistentStorage.storageClassName"
    value = var.storage_class 
  }

  depends_on = [
    kubernetes_namespace.px_backup
  ]
}

resource "null_resource" "pxbackupctl" {
  provisioner "local-exec" {
    command = <<EOF
      alias BACKUP_POD='kubectl get pods -n px-backup -l app=px-backup -o jsonpath='{.items[0].metadata.name}' 2>/dev/null'
      sudo kubectl cp -n $NS $(BACKUP_POD):pxbackupctl/linux/pxbackupctl /usr/local/bin/pxbackupctl
      sudo chmod 775 /usr/local/bin/pxbackupctl 
    EOF

    environment = {
      NS = var.namespace
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "sudo rm -rf /usr/local/bin/pxbackupctl"
  }

  depends_on = [
    helm_release.px_backup
  ]
}
