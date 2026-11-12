data "terraform_remote_state" "platform_tenancies" {
  backend = "local"
  config = {
    path = var.platform_tenancies_state_path
  }
}

locals {
  tenancies = data.terraform_remote_state.platform_tenancies.outputs
}

// The tenancy's namespace and Runner, which the app_tenancy_snapcd Module in platform-tenancies creates.
data "snapcd_namespace" "this" {
  name     = local.tenancies.app_tenancy_name
  stack_id = local.tenancies.stack_id
}

data "snapcd_runner" "this" {
  name = local.tenancies.app_tenancy_name
}

resource "snapcd_module" "sample_app_infra" {
  name                 = "sample_app_infra"
  namespace_id         = data.snapcd_namespace.this.id
  source_type          = "Git"
  source_url           = local.tenancies.source_url
  source_revision      = local.tenancies.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "namespaces/app-x/modules/sample-app-infra"
  runner_id            = data.snapcd_runner.this.id
}

// The sample app's Modules run on the app Runner, so a destroy must remove them before the Runner.
resource "snapcd_depends_on_module" "sample_app_infra" {
  module_id            = snapcd_module.sample_app_infra.id
  depends_on_module_id = local.tenancies.app_tenancy_k8s_runner_module_id
}

resource "snapcd_module" "sample_app_infra_config" {
  name                 = "sample_app_infra_config"
  namespace_id         = data.snapcd_namespace.this.id
  source_type          = "Git"
  source_url           = local.tenancies.source_url
  source_revision      = local.tenancies.source_revision
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
  source_url           = local.tenancies.source_url
  source_revision      = local.tenancies.source_revision
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
