locals {
  // Roles the app Runner may hand out in its own resource group.
  delegable_roles = {
    key_vault_administrator = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
    key_vault_secrets_user  = "4633458b-17de-408a-b874-0445c86b69e6"
  }
  delegable = join(", ", values(local.delegable_roles))
}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.cluster_resource_group_name
}

resource "azurerm_resource_group" "this" {
  name     = "${var.name}-team"
  location = var.location
}

// The app Runner signs in to Azure as this identity, from ServiceAccount <name>/<name>.
module "workload_identity" {
  source                  = "../../../../modules/workload-identity"
  resource_group_name     = azurerm_resource_group.this.name
  location                = var.location
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = data.azurerm_kubernetes_cluster.this.oidc_issuer_url
  namespace               = var.name
  service_account         = var.name
}

module "akv" {
  source                          = "../../../../modules/akv"
  name                            = var.name
  name_type                       = "prefix"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.this.name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  // The identity running this job writes the app Runner's SSH key in app_tenancy_azure_config.
  administrator_object_ids = distinct([var.administrator_object_id, data.azurerm_client_config.current.object_id])
}

resource "azurerm_role_assignment" "akv_secrets_user" {
  scope                = module.akv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}

/////////////////////////////////////////////////////////////////
// What the app Runner may do in Azure: its own resource group
/////////////////////////////////////////////////////////////////

resource "azurerm_role_assignment" "contributor" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = module.workload_identity.principal_id
}

// The condition limits the role assignments it makes, or deletes, to local.delegable_roles.
resource "azurerm_role_assignment" "rbac_administrator" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = module.workload_identity.principal_id
  condition_version    = "2.0"
  condition            = <<-EOT
    (
     (
      !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
     )
     OR
     (
      @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.delegable}}
     )
    )
    AND
    (
     (
      !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
     )
     OR
     (
      @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.delegable}}
     )
    )
  EOT
}

// Lets kubelogin fetch the cluster's credentials; what it may do inside comes from app_tenancy_k8s.
resource "azurerm_role_assignment" "aks_cluster_user" {
  scope                = data.azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.workload_identity.principal_id
}

// Key Vault data-plane role assignments take a few minutes to apply.
resource "time_sleep" "role_propagation" {
  depends_on      = [module.akv, azurerm_role_assignment.akv_secrets_user]
  create_duration = "120s"
}
