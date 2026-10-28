resource "snapcd_module" "sample_app_tenancy_snapcd" {
  name                 = "sample_app_tenancy_snapcd"
  namespace_id         = snapcd_namespace.platform.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/platform/roots/snapcd-sample-app-tenancy"
  runner_id            = data.snapcd_runner.platform.id
}

resource "snapcd_module_input_from_namespace" "sample_app_tenancy_snapcd" {
  name               = "stack_id"
  namespace_input_id = snapcd_namespace_input_from_definition.platform["stack_id"].id
  input_kind         = "Param"
  module_id          = snapcd_module.sample_app_tenancy_snapcd.id
}

resource "snapcd_module_input_from_literal" "sample_app_tenancy_snapcd" {
  for_each = {
    namespace_name                = local.app_namespace_name
    organization_id               = var.snapcd_organization_id
    snapcd_server_url_from_runner = var.snapcd_server_url_from_runner
    app_runner_name               = var.app_runner_name
    app_runner_client_id          = var.app_runner_client_id
    app_team_client_id            = var.app_team_client_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.sample_app_tenancy_snapcd.id
}
