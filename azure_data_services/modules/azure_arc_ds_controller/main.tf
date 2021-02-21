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

resource "azurerm_role_assignment" "monitoring_metrics_publisher" {
  provider             = azurerm.azure_rm
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azuread_service_principal.auth.id
}

resource "null_resource" "arc_data_controller" {
  provisioner "local-exec" {
    command = <<EOF
      if [ $(dpkg-query -W azure-cli | wc -l) -eq 0 ]; then
        sudo apt-get install gnupg ca-certificates curl wget software-properties-common apt-transport-https lsb-release -y
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
        sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/prod.list)"
        sudo apt-get install -y azdata-cli
      fi

      cd ~
      export AZDATA_USERNAME=$AU
      export AZDATA_PASSWORD=$AP
      export SPN_CLIENT_ID=$CI
      export SPN_CLIENT_SECRET=$CS
      export SPN_TENANT_ID=$TN
      export SPN_AUTHORITY="https://login.microsoftonline.com"

      if [ -d ~/$PD ]; then
        sudo mv ~/$PD ~/$PD.$(date "+%Y%m%d-%H%M%S")
      fi

      azdata arc dc config init --source azure-arc-kubeadm --path $PD 
      azdata arc dc config replace --path $PD/control.json --json-values "spec.storage.data.className=$SD"
      azdata arc dc config replace --path $PD/control.json --json-values "spec.storage.logs.className=$SL"
      azdata arc dc create --path $PD --namespace $NS --name arc --subscription $SI --resource-group $RG --location $LC --connectivity-mode $CM
    EOF

    environment = {
      PD = var.arc_data_profile_dir 
      NS = var.arc_data_namespace
      SI = var.arc_data_az_subscription_id 
      RG = var.arc_data_resource_group
      LC = var.arc_data_az_location
      CM = var.arc_data_connectivity_mode 
      CI = azuread_application.auth.application_id
      CS = random_string.password.result
      TN = data.azurerm_subscription.primary.tenant_id
      AU = var.azdata_username
      AP = var.AZDATA_PASSWORD
      SD = var.arc_data_storage_class
      SL = var.arc_logs_storage_class
    }
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete ns $(kubectl get po --all-namespaces -o wide | grep bootstrapper- | awk '{ print $1 }')"
  }


  depends_on = [  azurerm_role_assignment.contributor
                 ,azurerm_role_assignment.monitoring_metrics_publisher 
               ]
}
