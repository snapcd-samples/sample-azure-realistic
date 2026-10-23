output "app_client_id" {
  value = azuread_application_registration.this.client_id
}
output "app_client_secret" {
  value     = var.enable_client_secret ? azuread_application_password.this.0.value : ""
  sensitive = true
}
output "app_object_id" {
  value = azuread_application_registration.this.object_id
}
output "app_id" {
  value = azuread_application_registration.this.id
}
output "app_scope_id" {
  value = azuread_application_permission_scope.this.scope_id
}

output "full_name" {
  value = local.full_name
}

output "roles" {
  value = { for role in azuread_application_app_role.this : role.display_name => role.role_id }
}

output "identifier_uri" {
  value = azuread_application_identifier_uri.this.identifier_uri
}

output "service_principal_id" {
  value = azuread_service_principal.this.id
}

output "service_principal_object_id" {
  value = azuread_service_principal.this.object_id
}

output "service_principal_secret" {
  value     = var.enable_service_principal_secret ? azuread_service_principal_password.this.0.value : ""
  sensitive = true
}
