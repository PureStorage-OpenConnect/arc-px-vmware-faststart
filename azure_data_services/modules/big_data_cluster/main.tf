resource "null_resource" "big_data_cluster" {
  provisioner "local-exec" {
    command = <<-EOT
      if [ $(dpkg-query -W azure-cli | wc -l) -eq 0 ]; then
        sudo apt-get install gnupg ca-certificates curl wget software-properties-common apt-transport-https lsb-release -y
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
        sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/prod.list)"
        sudo apt-get install -y azdata-cli
      fi

      if [ -d ~/$PD ]; then
        sudo mv ~/$PD ~/$PD.$(date "+%Y%m%d-%H%M%S")
      fi

      azdata bdc config init --source kubeadm-dev-test --path ~/$PD
      azdata bdc config replace --path ~/$PD/control.json --json-values "metadata.name=$BN"
      azdata bdc config replace --path ~/$PD/bdc.json --json-values "metadata.name=$BN"
      azdata bdc config replace --path ~/$PD/control.json --json-values \
        "spec.storage={\"accessMode\":\"ReadWriteOnce\",\"className\":\"$SC\",\"size\":\"10Gi\"}"
      export AZDATA_USERNAME=$AU
      export AZDATA_PASSWORD=$AP
      azdata bdc create --accept-eula yes --config-profile ~/$PD 
    EOT

    environment = {
      PD = var.bdc_profile_dir
      BN = var.bdc_name
      AU = var.azdata_username
      AP = var.AZDATA_PASSWORD
      SC = var.bdc_storage_class
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete ns $(kubectl get po --all-namespaces | grep master-0 | awk '{ print $1 }')"
  }
}
