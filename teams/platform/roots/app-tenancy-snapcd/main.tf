// Forgets the former tenancy stack without deleting it: deleting a stack deletes its namespaces and their Modules.
removed {
  from = snapcd_stack.this
}

resource "snapcd_state_store" "this" {
  name = var.name
}

module "namespace" {
  source                 = "../../../../modules/snapcd-namespace"
  name                   = var.name
  stack_id               = var.stack_id
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
    kubernetes_namespace        = var.name
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

// Contributor: the app Runner's jobs define the tenancy's Modules in this namespace.
resource "snapcd_namespace_role_assignment" "app_runner" {
  namespace_id            = module.namespace.id
  principal_id            = snapcd_service_principal.app_runner.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "Contributor"
}

// Set here, not through the namespace module: they refer to the namespace and the Runner themselves.
resource "snapcd_namespace_input_from_literal" "tenancy" {
  for_each = {
    app_namespace_id = module.namespace.id
    app_runner_id    = snapcd_runner.this.id
  }
  name          = each.key
  literal_value = each.value
  type          = "String"
  usage_mode    = "UseByDefault"
  input_kind    = "Param"
  namespace_id  = module.namespace.id
}
