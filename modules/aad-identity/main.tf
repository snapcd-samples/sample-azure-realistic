locals {
  full_name = var.full_name == "" ? "aad-id--${var.cluster_name}--${var.namespace}--${var.service_account}" : var.full_name
}


resource "azuread_application_registration" "this" {
  display_name     = local.full_name
  sign_in_audience = "AzureADMyOrg"

  implicit_access_token_issuance_enabled = false
  implicit_id_token_issuance_enabled     = true
  requested_access_token_version         = 2
}

resource "azuread_application_owner" "this" {
  for_each        = toset(var.owner_object_ids)
  application_id  = azuread_application_registration.this.id
  owner_object_id = each.key
}

resource "azuread_application_federated_identity_credential" "this" {
  count          = var.enable_federated_identity_credential ? 1 : 0
  application_id = azuread_application_registration.this.id
  display_name   = local.full_name
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = var.cluster_oidc_issuer_url
  subject        = "system:serviceaccount:${var.namespace}:${var.service_account}"
}


resource "azuread_application_password" "this" {
  count          = var.enable_client_secret ? 1 : 0
  application_id = azuread_application_registration.this.id
}


resource "random_uuid" "app_role" {
  for_each = var.roles
}

resource "azuread_application_app_role" "this" {
  for_each       = var.roles
  application_id = azuread_application_registration.this.id
  role_id        = random_uuid.app_role[each.key].id

  allowed_member_types = each.value.allowed_member_types
  description          = each.value.description
  display_name         = each.key
  value                = each.key
}


resource "azuread_application_identifier_uri" "this" {
  application_id = azuread_application_registration.this.id
  identifier_uri = "api://${azuread_application_registration.this.client_id}"
}


resource "random_uuid" "app_scope" {
}

resource "azuread_application_permission_scope" "this" {
  application_id             = azuread_application_registration.this.id
  scope_id                   = random_uuid.app_scope.id
  value                      = "access_as_user"
  type                       = "User"
  admin_consent_description  = "Allows the app to access the web API on behalf of the signed-in user"
  admin_consent_display_name = "Access the API on behalf of a user"
}

resource "azuread_application_api_access" "this" {
  for_each       = { for index, obj in var.api_permissions : index => obj }
  application_id = azuread_application_registration.this.id
  api_client_id  = each.value.api_client_id
  role_ids       = each.value.role_ids
  scope_ids      = each.value.scope_ids
}


resource "azuread_service_principal" "this" {
  client_id = azuread_application_registration.this.client_id
  owners    = var.sp_owner_object_ids
}

resource "azuread_service_principal_password" "this" {
  count                = var.enable_service_principal_secret ? 1 : 0
  service_principal_id = azuread_service_principal.this.id
}


resource "azuread_app_role_assignment" "this" {
  for_each            = { for index, obj in var.roles_assigned_to_application : index => obj }
  app_role_id         = each.value.role_id
  principal_object_id = azuread_service_principal.this.object_id
  resource_object_id  = each.value.resource_object_id
}

resource "azuread_application_redirect_uris" "this" {
  for_each       = var.redirect_uris
  application_id = azuread_application_registration.this.id
  type           = each.key
  redirect_uris  = each.value
}

resource "azuread_application_pre_authorized" "this" {
  for_each             = { for index, authorized_client_id in var.pre_authorized_applications : index => authorized_client_id }
  application_id       = azuread_application_registration.this.id
  authorized_client_id = each.value

  permission_ids = [azuread_application_permission_scope.this.scope_id]
}

