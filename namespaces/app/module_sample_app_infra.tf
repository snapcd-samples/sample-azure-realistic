resource "snapcd_module" "sample_app_infra" {
  name                 = "sample_app_infra"
  namespace_id         = data.snapcd_namespace.app.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/app/roots/sample-app-infra"
  runner_id            = data.snapcd_runner.app.id
}


resource "snapcd_module_input_from_output_set" "sample_app_infra" {
  for_each = { for obj in [
    {
      name             = "from_app_landing_zone"
      output_module_id = data.snapcd_module.app_landing_zone.id
      input_kind       = "Param"
    },
    {
      name             = "from_cluster"
      output_module_id = data.snapcd_module.cluster.id
      input_kind       = "Param"
    },
  ] : obj.name => obj }
  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = each.value.input_kind
  module_id        = snapcd_module.sample_app_infra.id
}
