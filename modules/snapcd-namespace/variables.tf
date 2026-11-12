variable "name" {}
variable "stack_id" {}
variable "state_store_id" {
  description = "State Store holding the state of this namespace's Modules."
}
variable "organization_id" {}
variable "server_url_from_runner" {
  description = "Snap CD Server URL as the Runners reach it, for the State Store backend."
}
variable "approval_threshold" {
  default = 1
}
variable "params" {
  description = "String Params every Module in the namespace receives."
  type        = map(string)
  default     = {}
}
variable "azurerm" {
  description = "Give every Module an azurerm provider that signs in with the Runner's workload identity."
  default     = false
}
variable "subscription_id" {
  description = "Subscription the azurerm provider signs in to. Only with azurerm."
  default     = ""
}
variable "tenant_id" {
  default = ""
}
variable "azurerm_purge_key_vaults_on_destroy" {
  description = "Purge a Key Vault when a Module destroys it. Purging needs a subscription-wide right, so turn it off for a namespace whose Runner has rights in its own resource group only."
  default     = true
}
