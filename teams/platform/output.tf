// The Azure and Snap CD context of the platform, for Modules that build on it.

output "tenant_id" {
  value = var.tenant_id
}
output "subscription_id" {
  value = var.subscription_id
}
output "location" {
  value = var.location
}
output "administrator_object_id" {
  value = var.administrator_object_id
}
output "cluster_name" {
  value = var.cluster_name
}
output "cluster_resource_group_name" {
  value = var.cluster_resource_group_name
}
output "cluster_oidc_issuer_url" {
  value = var.cluster_oidc_issuer_url
}

output "organization_id" {
  value = var.organization_id
}
output "server_url_from_runner" {
  value = var.server_url_from_runner
}
output "name" {
  value = var.name
}
output "stack_id" {
  value = snapcd_stack.platform.id
}
output "namespace_id" {
  value = module.namespace.id
}
output "state_store_id" {
  value = snapcd_state_store.platform.id
}
output "runner_id" {
  value = snapcd_runner.platform.id
}
output "runner_client_id" {
  value = snapcd_service_principal.platform_runner.client_id
}
output "runner_service_principal_id" {
  value = snapcd_service_principal.platform_runner.id
}

output "app_tenancy_name" {
  value = var.app_tenancy_name
}
