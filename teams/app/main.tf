// The sample app's Modules, in the tenancy's namespace, on the tenancy's Runner.

resource "snapcd_module" "sample_app_infra" {
  name                 = "sample_app_infra"
  namespace_id         = var.app_namespace_id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/app/roots/sample-app-infra"
  runner_id            = var.app_runner_id
}

resource "snapcd_module" "sample_app_infra_config" {
  name                 = "sample_app_infra_config"
  namespace_id         = var.app_namespace_id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/app/roots/sample-app-infra-config"
  runner_id            = var.app_runner_id
}

resource "snapcd_module_input_from_output_set" "sample_app_infra_config" {
  name             = "from_sample_app_infra"
  output_module_id = snapcd_module.sample_app_infra.id
  input_kind       = "Param"
  module_id        = snapcd_module.sample_app_infra_config.id
}

resource "snapcd_module" "sample_app" {
  name                 = "sample_app"
  namespace_id         = var.app_namespace_id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/app/roots/sample-app"
  runner_id            = var.app_runner_id
}

resource "snapcd_module_input_from_output_set" "sample_app" {
  for_each = {
    from_sample_app_infra        = snapcd_module.sample_app_infra.id
    from_sample_app_infra_config = snapcd_module.sample_app_infra_config.id
  }
  name             = each.key
  output_module_id = each.value
  input_kind       = "Param"
  module_id        = snapcd_module.sample_app.id
}
