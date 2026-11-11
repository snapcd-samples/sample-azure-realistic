variable "name" {}
variable "chart_version" {}
variable "tenant_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "organization_id" {}
variable "server_url" {
  description = "Snap CD Server URL as the Runner reaches it inside the cluster."
}
variable "runner_id" {}
variable "runner_client_id" {}

// From platform_infra and platform_infra_config.
variable "platform_akv_name" {}
variable "platform_workload_identity_client_id" {}
variable "platform_runner_ssh_key_secret_name" {}
