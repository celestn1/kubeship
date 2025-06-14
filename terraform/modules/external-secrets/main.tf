# modules/external-secrets/main.tf
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = "external-secrets"
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
}
