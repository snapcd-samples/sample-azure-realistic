data "terraform_remote_state" "platform_core" {
  backend = "local"
  config = {
    path = var.platform_core_state_path
  }
}

locals {
  core = data.terraform_remote_state.platform_core.outputs
}

module "namespace" {
  source                 = "../../modules/snapcd-namespace"
  name                   = var.namespace_name
  stack_id               = local.core.stack_id
  state_store_id         = local.core.state_store_id
  organization_id        = local.core.organization_id
  server_url_from_runner = local.core.server_url_from_runner
  azurerm                = true
  subscription_id        = local.core.subscription_id
  tenant_id              = local.core.tenant_id
  params = {
    location                    = local.core.location
    tenant_id                   = local.core.tenant_id
    subscription_id             = local.core.subscription_id
    administrator_object_id     = local.core.administrator_object_id
    cluster_name                = local.core.cluster_name
    cluster_resource_group_name = local.core.cluster_resource_group_name
  }
}

resource "snapcd_runner_namespace_supply" "platform" {
  runner_id    = local.core.runner_id
  namespace_id = module.namespace.id
}
