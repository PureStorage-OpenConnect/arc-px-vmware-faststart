terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.48.0"
    }
    helm = {
      source  = "hashicorp/helm"
      # FIXME: Pinned version due to Helm provider bug in 2.0.0 & 2.0.1 regarding existing Terraform state
      # "Warning: Release does not exist"
      # See: https://github.com/hashicorp/terraform-provider-helm/issues/662
      version = "= 1.3.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "kubernetes_cluster" {
  source = "./modules/kubernetes_cluster"
}
  
module "px_store" {
  source = "./modules/px_store"
}

module "px_backup" {
  source = "./modules/px_backup"
}

module "metallb" {
  source = "./modules/metallb"
}
