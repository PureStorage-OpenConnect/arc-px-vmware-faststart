resource "null_resource" "portworx" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f $PX_SPEC
      until [ $(kubectl get po -n kube-system | egrep '(stork|px|portworx)' | \
                    awk '{ s += substr($2,1,1); t +=substr($2,3,1) } END { print s - t}') -eq 0 ]; do
        echo "."
        echo "Waiting for portworx pods to be ready"
        echo "."
        kubectl get po -n kube-system | egrep '(stork|px|portworx)'
        sleep 10
      done
      echo " "
      PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o jsonpath='{.items[0].metadata.name}')
      kubectl exec $PX_POD -n kube-system -- /opt/pwx/bin/pxctl status
    EOT

    environment = {
      PX_SPEC = var.px_spec
    }
  }
}

resource "null_resource" "kubernetes_scheduler" {
  count = var.use_stork ? 1 : 0
  provisioner "local-exec" {
    command = <<-EOT
      kubectl get deployment stork -n kube-system -o yaml | perl -pe "s/--webhook-controller=false/--webhook-controller=true/g" | kubectl apply -f -
    EOT
  }
  depends_on = [
    null_resource.portworx
  ]
}

resource "local_file" "storage_class_spec" {
  content = templatefile("${path.module}/templates/storage_class.tpl", {
    provisioner = var.use_csi ? "pxd.portworx.com" : "kubernetes.io/portworx-volume"
    px_repl_factor = var.px_repl_factor
  })
  filename = "storage-class.yml" 

  depends_on = [
    null_resource.kubernetes_scheduler
  ]
}

resource "null_resource" "storage_class" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./storage-class.yml"
  }

  depends_on = [
    local_file.storage_class_spec 
  ]
}
