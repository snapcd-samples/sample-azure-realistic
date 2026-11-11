locals {
  subscription = "/subscriptions/${var.subscription_id}"

  // Roles a tenancy hands out. Built-in role definition IDs.
  assignable_roles = {
    contributor                             = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    role_based_access_control_administrator = "f58310d9-a9f6-439a-9e8d-f62e7b41a168"
    key_vault_administrator                 = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
    key_vault_secrets_user                  = "4633458b-17de-408a-b874-0445c86b69e6"
    aks_cluster_user                        = "4abbcc35-e782-43d8-92c5-2d3f1bd2253f"
  }
  assignable = join(", ", values(local.assignable_roles))
}

data "azurerm_client_config" "current" {}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.cluster_resource_group_name
}

// Suffixed: the cluster's own resource group may already carry the platform's name.
resource "azurerm_resource_group" "this" {
  name     = "${var.name}-team"
  location = var.location
}

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
  // The identity running this job writes the generated SSH key in platform_infra_config.
  administrator_object_ids = distinct([var.administrator_object_id, data.azurerm_client_config.current.object_id])
}

resource "azurerm_role_assignment" "akv_secrets_user" {
  scope                = module.akv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.workload_identity.principal_id
}

/////////////////////////////////////////////////////////////////
// What the platform Runner may do in Azure: create tenancies
/////////////////////////////////////////////////////////////////

resource "azurerm_role_definition" "tenancy_creator" {
  name        = "${var.name} tenancy creator"
  scope       = local.subscription
  description = "Creates app tenancies: resource groups, managed identities and role assignments limited to the roles a tenancy hands out."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/subscriptions/resourceGroups/write",
      "Microsoft.Resources/subscriptions/resourceGroups/delete",
      "Microsoft.ManagedIdentity/userAssignedIdentities/*",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
      "Microsoft.Authorization/roleDefinitions/read",
      "Microsoft.ContainerService/managedClusters/read",
    ]
  }

  assignable_scopes = [local.subscription]
}

// The condition limits role assignments, created or deleted, to the roles in local.assignable_roles.
resource "azurerm_role_assignment" "tenancy_creator" {
  scope              = local.subscription
  role_definition_id = azurerm_role_definition.tenancy_creator.role_definition_resource_id
  principal_id       = module.workload_identity.principal_id
  condition_version  = "2.0"
  condition          = <<-EOT
    (
     (
      !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
     )
     OR
     (
      @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.assignable}}
     )
    )
    AND
    (
     (
      !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
     )
     OR
     (
      @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.assignable}}
     )
    )
  EOT
}

// Lets kubelogin fetch the cluster's credentials; what it may do inside comes from platform_k8s.
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
