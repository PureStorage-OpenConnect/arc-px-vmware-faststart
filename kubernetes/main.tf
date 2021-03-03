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
