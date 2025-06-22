# modules/external-secrets/resources.tf

resource "kubectl_manifest" "external_secret" {
  for_each = var.secrets_map

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      # Ensure resource name is DNS compliant
      name      = lower(replace(basename(each.key), "_", "-"))
      namespace = var.namespace
      labels = {
        managed-by = "terraform"
        source     = "aws-secrets-manager"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = lower(replace(basename(each.key), "_", "-"))
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = upper(basename(each.key))  # e.g. JWT_SECRET_KEY
          remoteRef = {
            key = each.key  # full path like /kubeship/auth/jwt_secret
          }
        }
      ]
    }
  })

  depends_on = [kubectl_manifest.cluster_secret_store]
}
