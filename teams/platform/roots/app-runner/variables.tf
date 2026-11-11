variable "name" {}
variable "chart_version" {}
variable "tenant_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "organization_id" {}
variable "server_url" {
  description = "Snap CD Server URL as the Runner reaches it inside the cluster."
}
variable "app_runner_id" {}
variable "app_runner_client_id" {}

// From app_tenancy_azure, app_tenancy_azure_config and app_tenancy_snapcd.
variable "app_akv_name" {}
variable "app_workload_identity_client_id" {}
variable "app_runner_ssh_key_secret_name" {}
