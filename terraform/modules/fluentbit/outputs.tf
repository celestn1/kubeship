// kubeship/terraform/modules/fluentbit/outputs.tf

output "fluentbit_release_name" {
  value = helm_release.fluentbit.name
}
