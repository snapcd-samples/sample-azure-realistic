data "snapcd_stack" "default" {
  name = "default"
}

data "snapcd_state_store" "platform" {
  name = var.platform_name
}

data "snapcd_runner" "platform" {
  name = var.platform_name
}

data "snapcd_namespace" "platform" {
  name     = var.platform_name
  stack_id = data.snapcd_stack.default.id
}

data "snapcd_module" "platform_k8s" {
  name         = "platform_k8s"
  namespace_id = data.snapcd_namespace.platform.id
}

data "snapcd_module" "app_tenancies" {
  name         = "app_tenancies"
  namespace_id = data.snapcd_namespace.platform.id
}

data "snapcd_module" "platform_runner" {
  name         = "platform_runner"
  namespace_id = data.snapcd_namespace.platform.id
}

module "namespace" {
  source                 = "../../../modules/snapcd-namespace"
  name                   = var.name
  stack_id               = data.snapcd_stack.default.id
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
