output "resource_group_name" {
  value = var.resource_group_name
}

output "location" {
  value = var.location
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "mssql_server_fully_qualified_domain_name" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "mssql_server_id" {
  value = azurerm_mssql_server.this.id
}
