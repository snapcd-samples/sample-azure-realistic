variable "name" {}
variable "stack_id" {}
variable "before_hook_script" {
  default = ""
}
variable "location" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "administrator_object_id" {}
variable "state_store_id" {}
variable "snapcd_server_url_from_runner" {
  description = "Snap CD server URL as the runner reaches it, for the state store backend."
}
variable "organization_id" {}
variable "resource_provider_registrations" {
  default     = "legacy"
  description = "azurerm resource_provider_registrations for module providers; \"none\" when the runner's identity cannot register providers on the subscription."
}
