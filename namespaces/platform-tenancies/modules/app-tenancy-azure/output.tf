output "app_resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "app_akv_name" {
  value = module.akv.name
}

output "app_akv_url" {
  value      = module.akv.vault_uri
  depends_on = [time_sleep.role_propagation]
}

output "app_workload_identity_client_id" {
  value = module.workload_identity.client_id
}

output "app_workload_identity_principal_id" {
  value = module.workload_identity.principal_id
}
