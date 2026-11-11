output "app_stack_id" {
  value = snapcd_stack.this.id
}
output "app_namespace_id" {
  value = module.namespace.id
}
output "app_state_store_id" {
  value = snapcd_state_store.this.id
}
output "app_runner_id" {
  value = snapcd_runner.this.id
}
output "app_runner_client_id" {
  value = snapcd_service_principal.app_runner.client_id
}
