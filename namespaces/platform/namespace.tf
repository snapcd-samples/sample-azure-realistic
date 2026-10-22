resource "snapcd_stack" "this" {
  name = local.stack_name
}

data "snapcd_state_store" "default" {
  name = "default"
}

resource "snapcd_state_store" "app" {
  name = local.app_namespace_name
}

module "namespace" {
  for_each = {
    (local.name) = {
      state_store_id                  = data.snapcd_state_store.default.id
      resource_provider_registrations = "legacy"
    }
    (local.app_namespace_name) = {
      state_store_id                  = snapcd_state_store.app.id
      resource_provider_registrations = "none"
    }
  }
  source = "./modules/namespace"

  name                            = each.key
  stack_id                        = snapcd_stack.this.id
  state_store_id                  = each.value.state_store_id
  resource_provider_registrations = each.value.resource_provider_registrations
  snapcd_server_url_from_runner   = var.snapcd_server_url_from_runner
  organization_id                 = var.snapcd_organization_id
  before_hook_script              = local.before_hook_base
  location                        = var.location
  subscription_id                 = var.subscription_id
  tenant_id                       = var.tenant_id
  administrator_object_id         = var.administrator_object_id
}

resource "snapcd_runner_namespace_supply" "platform" {
  runner_id    = data.snapcd_runner.platform.id
  namespace_id = module.namespace[local.name].id
}
