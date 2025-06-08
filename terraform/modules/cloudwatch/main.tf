// kubeship/terraform/modules/cloudwatch/main.tf

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/eks/${var.cluster_name}/logs"
  retention_in_days = var.retention_in_days
  tags = {
    Project = var.project_name
    Environment = var.environment
  }
}
