# kubeship/terraform/modules/external-secrets/cluster-secretstore.tf

resource "null_resource" "wait_for_external_secrets_crd" {
  provisioner "local-exec" {
    command = <<EOT
for i in $(seq 1 12); do
  kubectl get crd clustersecretstores.external-secrets.io && exit 0
  echo "Waiting for ClusterSecretStore CRD..."
  sleep 5
done
exit 1
EOT
  }
}


resource "kubectl_manifest" "cluster_secret_store" {
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
    helm_release.external_secrets,
    null_resource.wait_for_external_secrets_crd
  ]
}