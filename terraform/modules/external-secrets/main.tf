# kubeship/terraform/modules/external-secrets/main.tf

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.8.0"

  values = [
    yamlencode({
      installCRDs = true
      serviceAccount = {
        create = true
        name   = "external-secrets"
        annotations = {
          "eks.amazonaws.com/role-arn" = var.irsa_role_arn
        }
      }
      env = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]
    })
  ]
}
