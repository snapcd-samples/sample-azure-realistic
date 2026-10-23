/resource "azurerm_resource_group" "app" {
  name     = var.app_resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "app_contributor" {
  scope                = azurerm_resource_group.app.id
  role_definition_name = "Contributor"
  principal_id         = var.app_azure_principal_object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "app_rbac_administrator" {
  scope                = azurerm_resource_group.app.id
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = var.app_azure_principal_object_id
  principal_type       = "ServicePrincipal"
  condition_version    = "2.0"
  condition            = <<EOT
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
 )
 OR
 (
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.assignable_role_ids}}
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR
 (
  @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.assignable_role_ids}}
 )
)
EOT
}
