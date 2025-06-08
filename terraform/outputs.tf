// kubeship/terraform/outputs.tf

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster"
}

output "waf_web_acl_arn" {
  value       = module.waf.web_acl_arn
  description = "ARN of the WAF WebACL"
}

output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the ALB for routing"
}
