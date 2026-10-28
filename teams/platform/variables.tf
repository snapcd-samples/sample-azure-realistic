variable "snapcd_url" {
  default = "http://localhost:9000"
}
variable "snapcd_client_id" {}
variable "snapcd_client_secret" {
  sensitive = true
}
variable "snapcd_organization_id" {}
variable "snapcd_server_url_from_runner" {
  default     = "http://snapcd-server:5000"
  description = "Snap CD server URL as the runners reach it, for the state store backend."
}

variable "platform_runner_name" {}
variable "app_runner_name" {}
variable "app_runner_client_id" {
  description = "Client ID of the Snap CD service principal the app runner authenticates as."
}
variable "app_team_client_id" {
  description = "Client ID of the Snap CD service principal that applies namespaces/app."
}
variable "app_azure_principal_object_id" {
  description = "Object ID of the existing Entra service principal the app runner signs in to Azure as."
}

variable "tenant_id" {}
variable "subscription_id" {}
variable "location" {}
variable "administrator_object_id" {
  description = "Entra group or user that administers the SQL servers and the AKS cluster."
}
