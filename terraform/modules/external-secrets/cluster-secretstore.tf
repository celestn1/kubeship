# kubeship/terraform/modules/external-secrets/cluster-secretstore.tf

# pause long enough for Helm to install the CRDs
resource "time_sleep" "wait_for_crds" {
  depends_on       = [ helm_release.external_secrets ]
  create_duration  = "15s"   # or "30s" if your cluster is slow
}

resource "kubectl_manifest" "cluster_secret_store" {
  apply_only = true

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
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
    helm_release.external_secrets,
    time_sleep.wait_for_crds
  ]
}