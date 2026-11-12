// Read by app-x from this configuration's state.

output "namespace_id" {
  value = module.namespace.id
}
output "stack_id" {
  value = data.snapcd_stack.this.id
}
output "app_tenancy_name" {
  value = var.app_tenancy_name
}
output "source_url" {
  value = var.source_url
}
output "source_revision" {
  value = var.source_revision
}

output "app_tenancy_azure_module_id" {
  value = snapcd_module.app_tenancy_azure.id
}
output "app_tenancy_azure_config_module_id" {
  value = snapcd_module.app_tenancy_azure_config.id
}
output "app_tenancy_k8s_module_id" {
  value = snapcd_module.app_tenancy_k8s.id
}
output "app_tenancy_snapcd_module_id" {
  value = snapcd_module.app_tenancy_snapcd.id
}
output "app_tenancy_k8s_runner_module_id" {
  value = snapcd_module.app_tenancy_k8s_runner.id
}
