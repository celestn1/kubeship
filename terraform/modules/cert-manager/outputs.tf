# kubeship/terraform/modules/cert-manager/outputs.tf

output "cert_manager_status" {
  value = helm_release.cert_manager.status
}
