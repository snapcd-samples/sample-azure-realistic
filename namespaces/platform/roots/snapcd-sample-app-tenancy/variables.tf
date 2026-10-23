variable "namespace_name" {}
variable "stack_id" {}
variable "before_hook_script" {
  default = ""
}
variable "organization_id" {}
variable "snapcd_server_url_from_runner" {
  description = "Snap CD server URL as the runners reach it, for the provider and the state store backend."
}

variable "location" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "administrator_object_id" {}

variable "app_runner_name" {}
variable "app_runner_client_id" {
  description = "Client ID of the Snap CD service principal the app runner authenticates as."
}
variable "app_team_client_id" {
  description = "Client ID of the Snap CD service principal that applies namespaces/app."
}
