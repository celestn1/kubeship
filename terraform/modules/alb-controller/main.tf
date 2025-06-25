# kubeship/terraform/modules/alb-controller/main.tf

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.3"

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  # Tell the chart not to create its own SA
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  # Bind to our existing, annotated SA
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}
