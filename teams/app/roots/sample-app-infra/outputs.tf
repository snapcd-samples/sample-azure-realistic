output "sample_app_mssql_server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "sample_app_mssql_database_name" {
  value = azurerm_mssql_database.this.name
}

output "sample_app_mssql_database_id" {
  value = azurerm_mssql_database.this.id
}

output "sample_app_akv_id" {
  value = module.akv.id
}

output "sample_app_akv_name" {
  value = module.akv.name
}

output "sample_app_akv_url" {
  value = module.akv.vault_uri
}

output "sample_app_akv_role_assignment_ids" {
  value = module.akv.role_assignment_ids
}

output "sample_app_akv_resource_group_name" {
  value = module.akv.resource_group_name
}

output "sample_app_demo_secret_name" {
  value = azurerm_key_vault_secret.demo.name
}

output "sample_app_identity_client_id" {
  value = module.workload_identity.client_id
}

output "sample_app_identity_principal_id" {
  value = module.workload_identity.principal_id
}

output "sample_app_service_account_name" {
  value = local.name
}
