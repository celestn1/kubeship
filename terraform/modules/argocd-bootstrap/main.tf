// kubeship/terraform/modules/argocd-bootstrap/main.tf

// Ensure namespace exists before installing ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = var.argocd_namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  create_namespace = false
  
  timeout = 1200
  wait    = true
  atomic  = false

  values = [
    file("${path.module}/values.yaml")
  ]
  depends_on = [ kubernetes_namespace.argocd ]
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
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}
