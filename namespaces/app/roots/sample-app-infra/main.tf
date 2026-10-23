
data "azurerm_client_config" "current" {}


/////////////////////////////////////////////////////////////////
// MSSQL Server and Database
/////////////////////////////////////////////////////////////////

resource "random_string" "mssql_server_name" {
  length  = 10
  numeric = true
  lower   = true
  upper   = false
  special = false
}

// The identity running this module is the server's only administrator, so it can create the app's database user.
resource "azurerm_mssql_server" "this" {
  name                = "sample-app-${random_string.mssql_server_name.result}"
  location            = var.location
  resource_group_name = var.app_resource_group_name
  version             = "12.0"
  minimum_tls_version = "1.2"

  azuread_administrator {
    login_username              = "sample-app-runner"
    object_id                   = data.azurerm_client_config.current.object_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_firewall_rule" "all_ips" {
  name             = "${azurerm_mssql_server.this.name}-all"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_mssql_database" "this" {
  name                        = local.mssql_name
  server_id                   = azurerm_mssql_server.this.id
  sku_name                    = local.mssql_sku
  zone_redundant              = local.mssql_zone_redundant
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = local.mssql_max_size_gb
  creation_source_database_id = local.mssql_creation_source_database_id == "" ? null : local.mssql_creation_source_database_id
  create_mode                 = local.mssql_creation_source_database_id == "" ? "Default" : "Copy"
}



/////////////////////////////////////////////////////////////////
// Key Vault
/////////////////////////////////////////////////////////////////

// AKV name
resource "random_string" "akv" {
  length  = 10
  numeric = true
  lower   = true
  upper   = false
  special = false
}


// AKV
module "akv" {
  source                          = "../../../../modules/akv"
  name                            = "sample-app-${random_string.akv.result}"
  location                        = var.location
  resource_group_name             = var.app_resource_group_name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  administrator_object_ids        = [var.administrator_object_id, data.azurerm_client_config.current.object_id]

  providers = {
    azurerm = azurerm.default
  }
}


// Role assignments take a while to reach the Key Vault data plane.
resource "time_sleep" "akv_rbac_propagation" {
  depends_on      = [module.akv]
  create_duration = "120s"
}

resource "azurerm_key_vault_secret" "demo" {
  depends_on   = [time_sleep.akv_rbac_propagation]
  name         = local.demo_secret_name
  value        = "Hello from Azure Key Vault"
  key_vault_id = module.akv.id

  provider = azurerm.default
}


/////////////////////////////////////////////////////////////////
// Workload Identity
/////////////////////////////////////////////////////////////////


module "workload_identity" {
  source                  = "../../../../modules/workload-identity"
  resource_group_name     = var.app_resource_group_name
  location                = var.location
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  namespace               = local.namespace
  service_account         = local.name
}



/////////////////////////////////////////////////////////////////
// Role Assignments
/////////////////////////////////////////////////////////////////

resource "azurerm_role_assignment" "sample_app_akv_user" {
  scope                = module.akv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}
