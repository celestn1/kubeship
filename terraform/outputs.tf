// kubeship/terraform/outputs.tf
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF WebACL"
  value       = module.waf.web_acl_arn
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB for routing"
  value       = module.alb.alb_dns_name
}

output "cluster_endpoint" {
  description = "API endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA cert data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "terraform_caller_arn" {
  description = "IAM role ARN used by Terraform (for CI jobs)"
  value       = var.terraform_caller_arn
}

output "auth_image_digest" {
  description = "SHA256 digest for the auth-service image"
  value       = var.auth_image_digest
}

output "frontend_image_digest" {
  description = "SHA256 digest for the frontend image"
  value       = var.frontend_image_digest
}

output "nginx_image_digest" {
  description = "SHA256 digest for the nginx-gateway image"
  value       = var.nginx_image_digest
}
