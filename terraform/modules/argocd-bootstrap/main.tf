// kubeship/terraform/modules/argocd-bootstrap/main.tf

// 1) Ensure namespace exists
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

// 2) Pre-create the ServiceAccount with IRSA annotation
resource "kubernetes_service_account" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.argocd_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.argocd_server_role_arn
    }
  }
}

// 3) Install (or upgrade) ArgoCD via Helm, but don’t recreate the SA
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = false
  timeout          = 1200
  wait             = true
  atomic           = false

  values = [
    yamlencode(
      merge(
        yamldecode(file("${path.module}/values.yaml")),
        {
          server = {
            service         = { type = "LoadBalancer" }
            ingress         = { enabled = false }
            serviceAccount = {
              create = false             
              name   = kubernetes_service_account.argocd_server.metadata[0].name
            }
          }
        }
      )
    )
  ]

  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_service_account.argocd_server,
  ]
}

resource "helm_release" "ebs_csi" {
  count      = var.install_ebs_csi ? 1 : 0
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.30.0"

  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = "ebs-csi-controller-sa"
          annotations = {
            "eks.amazonaws.com/role-arn" = var.ebs_csi_controller_role_arn
          }
        }
      }
    })
  ]
}


resource "kubernetes_storage_class" "gp3" {
  count = var.install_ebs_csi ? 1 : 0

  metadata {
    name = "gp3"
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}
