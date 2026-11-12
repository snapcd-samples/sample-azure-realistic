// Applied by hand, as an organization Owner signed in with the snapcd CLI, after platform-core.
variable "organization_id" {
  description = "The organization of your snapcd CLI context."
  default     = "10000000-0000-0000-0000-000000000000"
}
variable "server_url_from_runner" {
  description = "The Snap CD Server, as the Runners in the cluster reach it."
  default     = "http://snapcd-server.snapcd-server.svc.cluster.local:5000"
}
variable "source_url" {
  default = "git@github.com:snapcd-samples/sample-azure-realistic.git"
}
variable "source_revision" {
  default = "main"
}
variable "chart_version" {
  description = "Version of the snapcd-runner chart at oci://ghcr.io/schrieksoft/charts."
  default     = "0.1.20"
}

variable "tenant_id" {}
variable "subscription_id" {}
variable "location" {}
variable "administrator_object_id" {
  description = "Entra group made administrator of the tenancies' Key Vaults."
}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "cluster_oidc_issuer_url" {
  description = "Issuer of the cluster's ServiceAccount tokens, which the app Runner authenticates with."
}

// Created by platform-core.
variable "stack_name" {
  default = "default"
}
variable "platform_state_store_name" {
  default = "platform"
}
variable "platform_runner_name" {
  default = "platform"
}

variable "namespace_name" {
  description = "The Snap CD namespace that holds the tenancies' Modules."
  default     = "platform-tenancies"
}
variable "app_tenancy_name" {
  description = "Name of the app tenancy: its Kubernetes namespace, its Snap CD namespace, State Store and Runner, and the prefix of its Azure resources."
  default     = "app-x"
}
variable "app_runner_client_id" {
  description = "Client ID of the Snap CD Service Principal the app Runner signs in as."
  default     = "app-x-runner"
}
