resource "snapcd_module" "sql_server" {
  name                 = "sql_server"
  namespace_id         = module.namespace[local.name].id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/platform/roots/sql-server"
  runner_id            = data.snapcd_runner.platform.id
}

resource "snapcd_module_input_from_literal" "sql_server" {
  for_each = { for obj in [
    {
      name          = "name"
      literal_value = local.name
      type          = "String"
    },
    {
      name          = "administrator_object_id"
      literal_value = var.administrator_object_id
      type          = "String"
    },
    {
      name          = "allow_all_ips"
      literal_value = false
      type          = "NotString"
    },


  ] : obj.name => obj }

  name          = each.value.name
  type          = each.value.type
  literal_value = each.value.literal_value
  input_kind    = "Param"
  module_id     = snapcd_module.sql_server.id
}

resource "snapcd_module_input_from_output_set" "sql_server_from_base" {
  name             = "from_base"
  output_module_id = snapcd_module.base.id
  input_kind       = "Param"
  module_id        = snapcd_module.sql_server.id
}

resource "snapcd_module_input_from_output_set" "sql_server_from_network" {
  name             = "from_network"
  output_module_id = snapcd_module.network.id
  input_kind       = "Param"
  module_id        = snapcd_module.sql_server.id
}