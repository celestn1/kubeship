# kubeship/terraform/modules/external-secrets/wait-for-crd.tf

resource "null_resource" "wait_for_clustersecretstore_crd" {
  provisioner "local-exec" {
    command = <<EOT
      for i in {1..30}; do
        echo "Checking for ClusterSecretStore CRD..."
        kubectl get crd clustersecretstores.external-secrets.io && exit 0
        sleep 5
      done
      echo "ClusterSecretStore CRD not found after waiting." >&2
      exit 1
    EOT
  }

  depends_on = [
    helm_release.external_secrets
  ]
}
