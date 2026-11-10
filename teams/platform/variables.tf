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
variable "backend_akv_name" {}
variable "backend_akv_resource_group_name" {}
variable "platform_runner_client_id" {}
variable "platform_runner_client_secret_name" {}

variable "name" {
  description = "Name of the platform: its Snap CD stack, namespace, State Store and Runner, its Kubernetes namespace and Key Vault prefix. Its Azure resource group is <name>-team."
  default     = "platform"
}
variable "chart_version" {
  description = "Version of the snapcd-runner chart at oci://ghcr.io/schrieksoft/charts."
  default     = "0.1.16"
}
