// kubeship/terraform/modules/argocd-bootstrap/main.tf

/*
Notes:
This installs the latest stable ArgoCD Helm chart into the argocd namespace.

It expects a values.yaml file to exist in the same module folder for custom overrides (admin password, RBAC, etc).

The depends_on ensures the namespace is created before the Helm chart installs.*
*/

// kubeship/terraform/modules/argocd-bootstrap/main.tf

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
