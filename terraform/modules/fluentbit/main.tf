// kubeship/terraform/modules/fluentbit/main.tf

resource "helm_release" "fluentbit" {
  name       = "aws-for-fluent-bit"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.21"

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [var.iam_role_arn]
}
