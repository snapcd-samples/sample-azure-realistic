output "namespace_id" {
  value = data.snapcd_namespace.this.id
}

output "sample_app_infra_module_id" {
  value = snapcd_module.sample_app_infra.id
}
output "sample_app_infra_config_module_id" {
  value = snapcd_module.sample_app_infra_config.id
}
output "sample_app_module_id" {
  value = snapcd_module.sample_app.id
}
