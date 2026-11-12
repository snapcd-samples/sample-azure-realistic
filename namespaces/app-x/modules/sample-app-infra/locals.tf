locals {
  mssql_name                        = "sample-app"
  mssql_sku                         = "Basic"
  mssql_zone_redundant              = false
  mssql_max_size_gb                 = 2
  mssql_creation_source_database_id = ""
  name                              = "sample-app"
  demo_secret_name                  = "demo-message"
}
