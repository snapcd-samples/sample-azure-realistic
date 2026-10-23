output "tenant_id" {
  value = var.tenant_id
}

output "client_id" {
  value = module.identity.app_client_id
}

output "client_secret" {
  value     = nonsensitive(module.identity.app_client_secret)
}

output "service_principal_object_id" {
  value = module.identity.service_principal_object_id
}
