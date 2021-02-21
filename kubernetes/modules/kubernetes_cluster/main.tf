locals {
   all_nodes_verbose_etcd = [for k, v in var.node_hosts: 
                               format("%s ip=%s etcd_instance=%s", v.name, v.ipv4_address, v.etcd_instance)
                               if length(v.etcd_instance) > 0]

   all_nodes_verbose      = [for k, v in var.node_hosts:
                               format("%s ip=%s", v.name, v.ipv4_address) 
                               if length(v.etcd_instance) == 0] 

   master_nodes           = [for k, v in var.node_hosts:
                               v.name
                               if v.compute_node != true] 

   etcd_nodes             = [for k, v in var.node_hosts:
                               v.name 
                               if length(v.etcd_instance) > 0] 

   all_nodes              = values(var.node_hosts)[*].name

   kubernetes_conf_file = format("%s/kubespray/inventory/%s/group_vars/k8s-cluster/k8s-cluster.yml", pathexpand("~"), var.kubespray_inventory)
   kubespray_inv_file   = format("%s/kubespray/inventory/%s/inventory.ini", pathexpand("~"), var.kubespray_inventory)
   context_artifact     = format("%s/kubespray/inventory/%s/artifacts/admin.conf", pathexpand("~"), var.kubespray_inventory)
}

resource "null_resource" "kubespray" {
  provisioner "local-exec" {
    command = <<-EOT
      if [ ! -d ~/kubespray ]; then
        git clone https://github.com/kubernetes-sigs/kubespray.git ~/kubespray
        sudo apt-get autoremove -y
        sudo apt-get update
        sudo apt-get install python3-pip -y
        sudo -H pip3 install -r ~/kubespray/requirements.txt
      fi
      if [ -d ~/kubespray/inventory/$KI]; then
        mv ~/kubespray/inventory/$KI ~/kubespray/inventory/$KI.$(date "+%Y%m%d-%H%M%S")
      fi
      cp -r ~/kubespray/inventory/sample ~/kubespray/inventory/$KI
    EOT

    environment = {
      KI = var.kubespray_inventory
    }
  }
}

resource "local_file" "kubespray_inventory" {
  content = templatefile("${path.module}/templates/kubespray_inventory.tpl", {
    k8s_node_host_verbose_etcd = replace(join("\", \"\n", local.all_nodes_verbose_etcd), "\", \"", "") 
    k8s_node_host_verbose      = replace(join("\", \"\n", local.all_nodes_verbose), "\", \"", "") 
    k8s_master_host            = replace(join("\", \"\n", local.master_nodes), "\", \"", "") 
    k8s_etcd_host              = replace(join("\", \"\n", local.etcd_nodes), "\", \"", "") 
    k8s_node_host              = replace(join("\", \"\n", local.all_nodes), "\", \"", "") 
  })
  filename = local.kubespray_inv_file

  depends_on = [
    null_resource.kubespray
  ]
}

resource "local_file" "kubernetes_config" {
  content = templatefile("${path.module}/templates/k8s_cluster.tpl", {
    kube_version = var.kubernetes_version 
  })
  filename = local.kubernetes_conf_file
  
  depends_on = [
    local_file.kubespray_inventory 
  ]
}

resource "null_resource" "kubernetes_cluster" {
  provisioner "local-exec" {
    command = "cd ~/kubespray && ansible-playbook -i $KIP --become --become-user=root cluster.yml"

    environment = {
      KIP = local.kubespray_inv_file
    }
  }

  depends_on = [
    local_file.kubernetes_config
  ]
}

resource "null_resource" "kubernetes_context" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p -m=775 ~/.kube

      if [ -f ~/.kube/config ]; then
        mv ~/.kube/config ~/.kube/config.$(date "+%Y%m%d-%H%M%S")
      fi

      if [ $(which kubectl | wc -l) -eq 0 ]; then
        sudo snap install kubectl --classic
      fi

      sudo chmod 755 $CA 
      cp $CA ~/.kube/config
    EOT

    environment = {
      CA = local.context_artifact
    }
  }

  depends_on = [
    null_resource.kubernetes_cluster
  ]
}

resource "null_resource" "taint_control_nodes" {
  for_each = var.node_hosts
    provisioner "local-exec" {
      command = (each.value.compute_node ?
                     "echo 'compute node - no NoSchedule taint to apply'" 
                   : "kubectl taint node ${each.value.name} node-role.kubernetes.io/master:NoSchedule --overwrite")
    }
 
  depends_on = [
    null_resource.kubernetes_context
  ]
}
