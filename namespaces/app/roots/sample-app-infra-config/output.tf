output "sample_app_mssql_user_name" {
  value = mssql_azuread_service_principal.this.name
}
