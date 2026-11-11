variable "name" {
  description = "Name of the tenancy: its Snap CD namespace, State Store and Runner."
}
variable "stack_id" {
  description = "The platform's stack. The tenancy's namespace goes in it, next to the platform namespace."
}
variable "organization_id" {}
variable "server_url_from_runner" {}
variable "cluster_oidc_issuer_url" {}
variable "app_runner_client_id" {
  description = "Client ID of the Snap CD Service Principal the app Runner signs in as."
}

// Given to every Module in the tenancy's namespace.
variable "location" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "app_resource_group_name" {}
