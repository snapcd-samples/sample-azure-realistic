resource "snapcd_module" "app_landing_zone" {
  name                 = "app_landing_zone"
  namespace_id         = module.namespace[local.name].id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/platform/roots/app-landing-zone"
  runner_id            = data.snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "app_landing_zone" {
  for_each = {
    app_resource_group_name       = local.app_namespace_name
    app_azure_principal_object_id = var.app_azure_principal_object_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_landing_zone.id
}
