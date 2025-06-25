# kubeship/terraform/modules/external-secrets/cluster-secretstore.tf

resource "kubectl_manifest" "cluster_secret_store" {
  apply_only = true

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = var.namespace
              }
            }
          }
        }
      }
    }
  })

  depends_on = [
    helm_release.external_secrets
  ]
}