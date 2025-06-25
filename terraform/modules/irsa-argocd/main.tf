# kubeship/terraform/modules/irsa-argocd/main.tf

data "aws_iam_openid_connect_provider" "eks" {
  arn = var.eks_oidc_provider_arn
}

resource "aws_iam_policy" "argocd_elb_read" {
  name        = "${var.project_name}-argocd-elb-readonly"
  description = "Allow ArgoCD server to Describe ELBs and related EC2 resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeListeners",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs"
      ]
      Resource = ["*"]
    }]
  })
}

data "aws_iam_policy_document" "argocd_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.argocd_namespace}:argocd-server"]
    }
  }
}

resource "aws_iam_role" "argocd_server" {
  name               = "${var.project_name}-argocd-server-role"
  assume_role_policy = data.aws_iam_policy_document.argocd_assume.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [assume_role_policy]
  }
}

resource "aws_iam_role_policy_attachment" "argocd_elb_attach" {
  role       = aws_iam_role.argocd_server.name
  policy_arn = aws_iam_policy.argocd_elb_read.arn
}