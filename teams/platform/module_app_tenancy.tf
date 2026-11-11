/////////////////////////////////////////////////////////////////
// The app tenancy, created by the platform Runner
/////////////////////////////////////////////////////////////////

resource "snapcd_module" "app_tenancy_azure" {
  depends_on           = [snapcd_runner_namespace_supply.this, snapcd_organization_role_assignment.platform_runner]
  name                 = "app_tenancy_azure"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform/roots/app-tenancy-azure"
  runner_id            = snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "app_tenancy_azure" {
  for_each = {
    name = var.app_tenancy_name
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_tenancy_azure.id
}

resource "snapcd_module" "app_tenancy_azure_config" {
  depends_on           = [snapcd_runner_namespace_supply.this, snapcd_organization_role_assignment.platform_runner]
  name                 = "app_tenancy_azure_config"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform/roots/app-tenancy-azure-config"
  runner_id            = snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "app_tenancy_azure_config" {
  for_each = {
    name = var.app_tenancy_name
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_tenancy_azure_config.id
}

resource "snapcd_module_input_from_output_set" "app_tenancy_azure_config" {
  name             = "from_app_tenancy_azure"
  output_module_id = snapcd_module.app_tenancy_azure.id
  input_kind       = "Param"
  module_id        = snapcd_module.app_tenancy_azure_config.id
}

resource "snapcd_module" "app_tenancy_k8s" {
  depends_on           = [snapcd_runner_namespace_supply.this, snapcd_organization_role_assignment.platform_runner]
  name                 = "app_tenancy_k8s"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform/roots/app-tenancy-k8s"
  runner_id            = snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "app_tenancy_k8s" {
  for_each = {
    name = var.app_tenancy_name
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_tenancy_k8s.id
}

resource "snapcd_module_input_from_output_set" "app_tenancy_k8s" {
  name             = "from_app_tenancy_azure"
  output_module_id = snapcd_module.app_tenancy_azure.id
  input_kind       = "Param"
  module_id        = snapcd_module.app_tenancy_k8s.id
}

resource "snapcd_module" "app_tenancy_snapcd" {
  depends_on           = [snapcd_runner_namespace_supply.this, snapcd_organization_role_assignment.platform_runner]
  name                 = "app_tenancy_snapcd"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform/roots/app-tenancy-snapcd"
  runner_id            = snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "app_tenancy_snapcd" {
  for_each = {
    name                    = var.app_tenancy_name
    organization_id         = var.organization_id
    server_url_from_runner  = var.server_url_from_runner
    cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
    app_runner_client_id    = var.app_runner_client_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_tenancy_snapcd.id
}

// The Snap CD provider in app-tenancy-snapcd reads these; the platform Runner supplies SNAPCD_CLIENT_ID and SNAPCD_FEDERATED_TOKEN_FILE.
resource "snapcd_module_input_from_literal" "app_tenancy_snapcd_env" {
  for_each = {
    SNAPCD_URL             = var.server_url_from_runner
    SNAPCD_ORGANIZATION_ID = var.organization_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "EnvVar"
  module_id     = snapcd_module.app_tenancy_snapcd.id
}

resource "snapcd_module_input_from_output_set" "app_tenancy_snapcd" {
  name             = "from_app_tenancy_azure"
  output_module_id = snapcd_module.app_tenancy_azure.id
  input_kind       = "Param"
  module_id        = snapcd_module.app_tenancy_snapcd.id
}

resource "snapcd_module" "app_runner" {
  depends_on           = [snapcd_runner_namespace_supply.this, snapcd_organization_role_assignment.platform_runner]
  name                 = "app_runner"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "teams/platform/roots/app-runner"
  runner_id            = snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "app_runner" {
  for_each = {
    name            = var.app_tenancy_name
    chart_version   = var.chart_version
    organization_id = var.organization_id
    server_url      = var.server_url_from_runner
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.app_runner.id
}

resource "snapcd_module_input_from_output_set" "app_runner" {
  for_each = {
    from_app_tenancy_azure        = snapcd_module.app_tenancy_azure.id
    from_app_tenancy_azure_config = snapcd_module.app_tenancy_azure_config.id
    from_app_tenancy_snapcd       = snapcd_module.app_tenancy_snapcd.id
  }
  name             = each.key
  output_module_id = each.value
  input_kind       = "Param"
  module_id        = snapcd_module.app_runner.id
}

// The chart installs into the namespace app_tenancy_k8s creates.
resource "snapcd_depends_on_module" "app_runner" {
  module_id            = snapcd_module.app_runner.id
  depends_on_module_id = snapcd_module.app_tenancy_k8s.id
}
