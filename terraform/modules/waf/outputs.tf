// kubeship/terraform/modules/waf/outputs.tf

output "web_acl_arn" {
  description = "The ARN of the created WAF WebACL"
  value       = aws_wafv2_web_acl.this.arn
}
