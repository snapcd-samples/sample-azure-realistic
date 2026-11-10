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
