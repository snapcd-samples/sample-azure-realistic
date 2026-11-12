data "snapcd_stack" "this" {
  name = var.stack_name
}

// The tenancy's namespace and Runner, which the app_tenancy_snapcd Module in platform-tenancies creates.
data "snapcd_namespace" "this" {
  name     = var.namespace_name
  stack_id = data.snapcd_stack.this.id
}

data "snapcd_runner" "this" {
  name = var.runner_name
}

resource "snapcd_module" "sample_app_infra" {
  name                 = "sample_app_infra"
  namespace_id         = data.snapcd_namespace.this.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "namespaces/app-x/modules/sample-app-infra"
  runner_id            = data.snapcd_runner.this.id
}

resource "snapcd_module" "sample_app_infra_config" {
  name                 = "sample_app_infra_config"
  namespace_id         = data.snapcd_namespace.this.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "namespaces/app-x/modules/sample-app-infra-config"
  runner_id            = data.snapcd_runner.this.id
}

resource "snapcd_module_input_from_output_set" "sample_app_infra_config" {
  name             = "from_sample_app_infra"
  output_module_id = snapcd_module.sample_app_infra.id
  input_kind       = "Param"
  module_id        = snapcd_module.sample_app_infra_config.id
}

resource "snapcd_module" "sample_app" {
  name                 = "sample_app"
  namespace_id         = data.snapcd_namespace.this.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "namespaces/app-x/modules/sample-app"
  runner_id            = data.snapcd_runner.this.id
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
