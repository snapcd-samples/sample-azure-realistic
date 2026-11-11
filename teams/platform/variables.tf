// Set by the init Module.
variable "organization_id" {}
variable "server_url_from_runner" {}
variable "source_url" {}
variable "source_revision" {}
variable "tenant_id" {}
variable "subscription_id" {}
variable "location" {}
variable "administrator_object_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "cluster_oidc_issuer_url" {}
variable "platform_runner_client_id" {}

variable "name" {
  description = "Name of the platform: its Snap CD stack, namespace, State Store and Runner, its Kubernetes namespace and Key Vault prefix. Its Azure resource group is <name>-team."
  default     = "platform"
}
variable "chart_version" {
  description = "Version of the snapcd-runner chart at oci://ghcr.io/schrieksoft/charts."
  default     = "0.1.20"
}
variable "app_tenancy_name" {
  description = "Name of the app tenancy: its Kubernetes namespace, Snap CD stack, namespace and Runner, and the prefix of its Azure resources."
  default     = "app"
}
variable "app_runner_client_id" {
  description = "Client ID of the Snap CD Service Principal the app Runner signs in as."
  default     = "app-runner"
}
