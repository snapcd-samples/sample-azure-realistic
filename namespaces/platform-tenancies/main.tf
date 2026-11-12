data "snapcd_stack" "this" {
  name = var.stack_name
}

// The platform State Store also holds the state of this namespace's Modules.
data "snapcd_state_store" "platform" {
  name = var.platform_state_store_name
}

// Runs this namespace's Modules.
data "snapcd_runner" "platform" {
  name = var.platform_runner_name
}

module "namespace" {
  source                 = "../../modules/snapcd-namespace"
  name                   = var.namespace_name
  stack_id               = data.snapcd_stack.this.id
  state_store_id         = data.snapcd_state_store.platform.id
  organization_id        = var.organization_id
  server_url_from_runner = var.server_url_from_runner
  azurerm                = true
  subscription_id        = var.subscription_id
  tenant_id              = var.tenant_id
  params = {
    location                    = var.location
    tenant_id                   = var.tenant_id
    subscription_id             = var.subscription_id
    administrator_object_id     = var.administrator_object_id
    cluster_name                = var.cluster_name
    cluster_resource_group_name = var.cluster_resource_group_name
  }
}

resource "snapcd_runner_namespace_supply" "platform" {
  runner_id    = data.snapcd_runner.platform.id
  namespace_id = module.namespace.id
}
