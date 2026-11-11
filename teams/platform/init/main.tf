data "snapcd_stack" "default" {
  name = "default"
}

data "snapcd_state_store" "default" {
  name = "default"
}

data "snapcd_runner" "default" {
  name = "default"
}

module "namespace" {
  source                 = "../../../modules/snapcd-namespace"
  name                   = var.init_namespace_name
  stack_id               = data.snapcd_stack.default.id
  state_store_id         = data.snapcd_state_store.default.id
  organization_id        = var.organization_id
  server_url_from_runner = var.server_url_from_runner
}

resource "snapcd_runner_namespace_supply" "default" {
  runner_id    = data.snapcd_runner.default.id
  namespace_id = module.namespace.id
}

// Applies teams/platform, which declares the platform namespace and its Modules.
resource "snapcd_module" "platform" {
  depends_on           = [snapcd_runner_namespace_supply.default]
  name                 = "platform"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform"
  runner_id            = data.snapcd_runner.default.id
}

// The Snap CD provider in teams/platform reads these; the Runner supplies SNAPCD_CLIENT_ID and SNAPCD_FEDERATED_TOKEN_FILE.
resource "snapcd_module_input_from_literal" "platform_env" {
  for_each = {
    SNAPCD_URL             = var.server_url_from_runner
    SNAPCD_ORGANIZATION_ID = var.organization_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "EnvVar"
  module_id     = snapcd_module.platform.id
}

resource "snapcd_module_input_from_literal" "platform" {
  for_each = {
    organization_id             = var.organization_id
    server_url_from_runner      = var.server_url_from_runner
    source_url                  = var.source_url
    source_revision             = var.source_revision
    tenant_id                   = var.tenant_id
    subscription_id             = var.subscription_id
    location                    = var.location
    administrator_object_id     = var.administrator_object_id
    cluster_name                = var.cluster_name
    cluster_resource_group_name = var.cluster_resource_group_name
    cluster_oidc_issuer_url     = var.cluster_oidc_issuer_url
    platform_runner_client_id   = var.platform_runner_client_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.platform.id
}
