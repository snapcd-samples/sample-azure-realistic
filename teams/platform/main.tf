resource "snapcd_stack" "platform" {
  name = var.name
}

resource "snapcd_state_store" "platform" {
  name = var.name
}

module "namespace" {
  source                 = "../../modules/snapcd-namespace"
  name                   = var.name
  stack_id               = snapcd_stack.platform.id
  state_store_id         = snapcd_state_store.platform.id
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

data "snapcd_runner" "default" {
  name = "default"
}

data "snapcd_service_principal" "platform_runner" {
  client_id = var.platform_runner_client_id
}

resource "snapcd_runner" "platform" {
  name                 = var.name
  service_principal_id = data.snapcd_service_principal.platform_runner.id
}

// The default Runner deploys the platform's own footing, which needs rights the platform Runner must not have.
resource "snapcd_runner_namespace_supply" "this" {
  for_each = {
    default  = data.snapcd_runner.default.id
    platform = snapcd_runner.platform.id
  }
  runner_id    = each.value
  namespace_id = module.namespace.id
}

resource "snapcd_state_store_role_assignment" "platform_runner" {
  state_store_id          = snapcd_state_store.platform.id
  principal_id            = data.snapcd_service_principal.platform_runner.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "Contributor"
}
