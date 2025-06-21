# kubeship/terraform/modules/eks-irsa-ebs/outputs.tf

output "ebs_csi_controller_role_arn" {
  value = aws_iam_role.ebs_csi_controller_role.arn
}
