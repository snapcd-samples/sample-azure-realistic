resource "snapcd_module" "platform_k8s_runner" {
  depends_on           = [snapcd_runner_namespace_supply.this]
  name                 = "platform_k8s_runner"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "namespaces/platform-core/modules/platform-k8s-runner"
  runner_id            = data.snapcd_runner.default.id
}

resource "snapcd_module_input_from_literal" "platform_k8s_runner" {
  for_each = {
    name             = var.name
    chart_version    = var.chart_version
    organization_id  = var.organization_id
    server_url       = var.server_url_from_runner
    runner_id        = snapcd_runner.platform.id
    runner_client_id = var.platform_runner_client_id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.platform_k8s_runner.id
}

resource "snapcd_module_input_from_output_set" "platform_k8s_runner" {
  for_each = {
    from_platform_azure        = snapcd_module.platform_azure.id
    from_platform_azure_config = snapcd_module.platform_azure_config.id
  }
  name             = each.key
  output_module_id = each.value
  input_kind       = "Param"
  module_id        = snapcd_module.platform_k8s_runner.id
}

resource "snapcd_depends_on_module" "platform_k8s_runner" {
  for_each = {
    platform_k8s = snapcd_module.platform_k8s.id
  }
  module_id            = snapcd_module.platform_k8s_runner.id
  depends_on_module_id = each.value
}
