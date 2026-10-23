resource "snapcd_module" "sample_app_tenancy_azure" {
  name                 = "sample_app_tenancy_azure"
  namespace_id         = snapcd_namespace.platform.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/platform/roots/azure-sample-app-tenancy"
  runner_id            = data.snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "sample_app_tenancy_azure" {
  for_each = {
    app_resource_group_name       = local.app_namespace_name
    app_azure_principal_object_id = var.app_azure_principal_object_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.sample_app_tenancy_azure.id
}
