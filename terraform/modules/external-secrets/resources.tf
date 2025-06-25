# modules/external-secrets/resources.tf

# pause long enough for Helm to install the CRDs
resource "time_sleep" "wait_for_crds" {
  depends_on       = [ helm_release.external_secrets ]
  create_duration  = "15s"   # or "30s" if your cluster is slow
}

resource "kubectl_manifest" "external_secret" {
  for_each = var.secrets_map

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = lower(replace(basename(each.key), "_", "-"))  # e.g. "auth"
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
        name           = lower(replace(basename(each.key), "_", "-"))  # same as metadata.name
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = each.key  # full path to the JSON secret, e.g. "/kubeship/auth"
          }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.cluster_secret_store,
    time_sleep.wait_for_crds
  ]
}
