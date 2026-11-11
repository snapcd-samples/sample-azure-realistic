// Set by the app_tenancies Module.
variable "organization_id" {}
variable "server_url_from_runner" {}
variable "source_url" {}
variable "source_revision" {}
variable "cluster_oidc_issuer_url" {}
variable "chart_version" {}
variable "platform_name" {
  description = "Name of the platform: its Snap CD namespace, State Store and Runner."
}
variable "app_tenancy_name" {}
variable "app_runner_client_id" {}

// From the platform namespace.
variable "location" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "administrator_object_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}

variable "name" {
  description = "Name of the Snap CD namespace that holds the tenancies' Modules."
  default     = "app-tenancies"
}
