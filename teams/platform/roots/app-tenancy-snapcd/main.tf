resource "snapcd_stack" "this" {
  name = var.name
}

resource "snapcd_state_store" "this" {
  name = var.name
}

module "namespace" {
  source                 = "../../../../modules/snapcd-namespace"
  name                   = var.name
  stack_id               = snapcd_stack.this.id
  state_store_id         = snapcd_state_store.this.id
  organization_id        = var.organization_id
  server_url_from_runner = var.server_url_from_runner
  azurerm                = true
  subscription_id        = var.subscription_id
  tenant_id              = var.tenant_id
  params = {
    location                    = var.location
    tenant_id                   = var.tenant_id
    subscription_id             = var.subscription_id
    resource_group_name         = var.app_resource_group_name
    cluster_name                = var.cluster_name
    cluster_resource_group_name = var.cluster_resource_group_name
  }
}

// No client secret: the app Runner authenticates with its projected ServiceAccount token.
resource "snapcd_service_principal" "app_runner" {
  client_id = var.app_runner_client_id
}

resource "snapcd_service_principal_federated_credential" "app_runner" {
  service_principal_id = snapcd_service_principal.app_runner.id
  name                 = "aks"
  issuer               = var.cluster_oidc_issuer_url
  subject              = "system:serviceaccount:${var.name}:${var.name}"
  audience             = "snapcd"
}

resource "snapcd_runner" "this" {
  name                 = var.name
  service_principal_id = snapcd_service_principal.app_runner.id
}

// Supplied to the tenancy's namespace only.
resource "snapcd_runner_namespace_supply" "this" {
  runner_id    = snapcd_runner.this.id
  namespace_id = module.namespace.id
}

resource "snapcd_state_store_role_assignment" "app_runner" {
  state_store_id          = snapcd_state_store.this.id
  principal_id            = snapcd_service_principal.app_runner.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "Contributor"
}
