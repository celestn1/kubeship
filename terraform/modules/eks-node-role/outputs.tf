// kubeship/terraform/modules/eks-node-role/outputs.tf

output "iam_role_arn" {
  description = "IAM role ARN for EKS managed node group"
  value       = aws_iam_role.eks_node_group_role.arn
}
