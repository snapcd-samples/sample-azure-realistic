// Applies teams/platform/tenancies on the platform Runner: the app-tenancies namespace and the tenancies' Modules.
resource "snapcd_module" "app_tenancies" {
  depends_on           = [snapcd_runner_namespace_supply.this, snapcd_organization_role_assignment.platform_runner, snapcd_state_store_role_assignment.platform_runner]
  name                 = "app_tenancies"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform/tenancies"
  runner_id            = snapcd_runner.platform.id
}

// The Snap CD provider in teams/platform/tenancies reads these; the platform Runner supplies SNAPCD_CLIENT_ID and SNAPCD_FEDERATED_TOKEN_FILE.
resource "snapcd_module_input_from_literal" "app_tenancies_env" {
  for_each = {
    SNAPCD_URL             = var.server_url_from_runner
    SNAPCD_ORGANIZATION_ID = var.organization_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "EnvVar"
  module_id     = snapcd_module.app_tenancies.id
}

resource "snapcd_module_input_from_literal" "app_tenancies" {
  for_each = {
    organization_id         = var.organization_id
    server_url_from_runner  = var.server_url_from_runner
    source_url              = var.source_url
    source_revision         = var.source_revision
    cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
    chart_version           = var.chart_version
    platform_name           = var.name
    app_tenancy_name        = var.app_tenancy_name
    app_runner_client_id    = var.app_runner_client_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_tenancies.id
}

// The platform Runner runs this Module, and the tenancies' Modules depend on platform_k8s and platform_runner.
resource "snapcd_depends_on_module" "app_tenancies" {
  for_each = {
    platform_k8s    = snapcd_module.platform_k8s.id
    platform_runner = snapcd_module.platform_runner.id
  }
  module_id            = snapcd_module.app_tenancies.id
  depends_on_module_id = each.value
}
