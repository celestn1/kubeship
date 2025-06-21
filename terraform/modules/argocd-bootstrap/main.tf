// kubeship/terraform/modules/argocd-bootstrap/main.tf

// Ensure namespace exists before installing ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = false
  
  timeout = 1200
  wait    = true
  atomic  = false

  values = [
    file("${path.module}/values.yaml")
  ]
  depends_on = [ kubernetes_namespace.argocd ]
}

resource "null_resource" "apply_app_manifests" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/${var.argocd_app_manifest_path} -n ${var.argocd_namespace}"
  }

  depends_on = [helm_release.argocd]
}
