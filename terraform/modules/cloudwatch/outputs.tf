// kubeship/terraform/modules/cloudwatch/outputs.tf

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.eks.name
}
