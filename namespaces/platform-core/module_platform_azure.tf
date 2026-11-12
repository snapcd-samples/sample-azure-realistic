resource "snapcd_module" "platform_azure" {
  depends_on           = [snapcd_runner_namespace_supply.this]
  name                 = "platform_azure"
  namespace_id         = module.namespace.id
  source_type          = "Git"
  source_url           = var.source_url
  source_revision      = var.source_revision
  source_revision_type = "Default"
  source_subdirectory  = "namespaces/platform-core/modules/platform-azure"
  runner_id            = data.snapcd_runner.default.id
}

resource "snapcd_module_input_from_literal" "platform_azure" {
  for_each = {
    name = var.name
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.platform_azure.id
}
