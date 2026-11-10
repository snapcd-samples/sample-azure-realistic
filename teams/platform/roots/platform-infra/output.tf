output "platform_akv_name" {
  value = module.akv.name
}

output "platform_akv_url" {
  value      = module.akv.vault_uri
  depends_on = [time_sleep.role_propagation]
}

output "backend_akv_url" {
  value = data.azurerm_key_vault.backend.vault_uri
}

output "platform_workload_identity_client_id" {
  value = module.workload_identity.client_id
}

output "platform_workload_identity_principal_id" {
  value = module.workload_identity.principal_id
}
