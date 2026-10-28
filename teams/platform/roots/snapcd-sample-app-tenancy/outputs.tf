output "namespace_id" {
  value = snapcd_namespace.this.id
}

output "namespace_name" {
  value = snapcd_namespace.this.name
}

output "state_store_id" {
  value = snapcd_state_store.this.id
}
