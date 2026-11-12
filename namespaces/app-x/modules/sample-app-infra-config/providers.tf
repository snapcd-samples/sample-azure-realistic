provider "mssql" {
  hostname   = var.sample_app_mssql_server_fqdn
  port       = 1433
  azure_auth = {}
}
