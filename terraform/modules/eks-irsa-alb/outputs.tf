# kubeship/terraform/modules/eks-irsa-alb/outputs.tf

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller_role.arn
}
