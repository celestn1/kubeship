# kubeship/terraform/modules/cert-manager/main.tf

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = []
}
