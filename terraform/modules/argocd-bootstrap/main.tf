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
  
  timeout = 600
  wait    = true
  atomic  = true

  values = [
    file("${path.module}/values.yaml")
  ]
  depends_on = [ kubernetes_namespace.argocd ]
}
