# modules/external-secrets/main.tf

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = var.namespace
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.8.0"

  values = [
    yamlencode({
      installCRDs = true
      env = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]
    })
  ]

  depends_on = [kubernetes_namespace.external_secrets]
}
