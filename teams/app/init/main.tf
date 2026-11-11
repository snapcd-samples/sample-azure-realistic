data "snapcd_stack" "this" {
  name = var.stack_name
}

data "snapcd_namespace" "tenancy" {
  name     = var.tenancy_name
  stack_id = data.snapcd_stack.this.id
}

data "snapcd_runner" "tenancy" {
  name = var.tenancy_name
}

// Applies teams/app, which declares the sample app's Modules in the same namespace.
resource "snapcd_module" "app" {
  name                 = "app"
  namespace_id         = data.snapcd_namespace.tenancy.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/app"
  runner_id            = data.snapcd_runner.tenancy.id
}

// The Snap CD provider in teams/app reads these; the app Runner supplies SNAPCD_CLIENT_ID and SNAPCD_FEDERATED_TOKEN_FILE.
resource "snapcd_module_input_from_literal" "app_env" {
  for_each = {
    SNAPCD_URL             = var.server_url_from_runner
    SNAPCD_ORGANIZATION_ID = var.organization_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "EnvVar"
  module_id     = snapcd_module.app.id
}

resource "snapcd_module_input_from_literal" "app" {
  for_each = {
    source_url      = var.source_url
    source_revision = var.source_revision
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app.id
}

data "snapcd_namespace" "tenancies" {
  name     = var.tenancies_namespace_name
  stack_id = data.snapcd_stack.this.id
}

data "snapcd_module" "app_runner" {
  name         = "app_runner"
  namespace_id = data.snapcd_namespace.tenancies.id
}

// The app Module runs on the app Runner, so a destroy must remove it before the Runner.
resource "snapcd_depends_on_module" "app" {
  module_id            = snapcd_module.app.id
  depends_on_module_id = data.snapcd_module.app_runner.id
}
