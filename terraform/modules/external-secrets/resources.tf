# modules/external-secrets/resources.tf
resource "kubernetes_manifest" "external_secret" {
  for_each = var.secrets_map

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.key
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets"       # assume you created a SecretStore named aws-secrets
        kind = "ClusterSecretStore"
      }
      target = {
        name = each.key            # creates a K8s Secret with the same name
      }
      data = [
        {
          secretKey = each.key     # K8s Secret data key
          remoteRef = {
            key = each.key         # AWS SM secret name
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.cluster_secret_store]

}
