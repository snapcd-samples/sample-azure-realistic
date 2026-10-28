/////////////////////////////////////////////////////////////////
// SQL Database user/login
/////////////////////////////////////////////////////////////////

data "mssql_database" "this" {
  name = var.sample_app_mssql_database_name
}

data "mssql_database_role" "db_owner" {
  name        = "db_owner"
  database_id = data.mssql_database.this.id
}

resource "mssql_azuread_service_principal" "this" {
  name        = "sample-app"
  database_id = data.mssql_database.this.id
  client_id   = var.sample_app_identity_client_id
}

resource "mssql_database_role_member" "this" {
  role_id   = data.mssql_database_role.db_owner.id
  member_id = mssql_azuread_service_principal.this.id
}
