// Applied by hand, as an organization Owner signed in with the snapcd CLI.
variable "organization_id" {
  description = "The organization of your snapcd CLI context. The Runners use it for the State Store and the Snap CD provider."
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

variable "tenant_id" {}
variable "subscription_id" {}
variable "location" {}
variable "administrator_object_id" {
  description = "Entra group made administrator of the platform's Key Vault."
}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "cluster_oidc_issuer_url" {
  description = "Issuer of the cluster's ServiceAccount tokens, which the platform Runner authenticates with: the cluster_oidc_issuer_url output of the cluster Module in snapcd-deployment-azure."
}

variable "namespace_name" {
  description = "The Snap CD namespace that holds the platform's Modules."
  default     = "platform-core"
}
variable "name" {
  description = "Name of the platform: its State Store and Runner, its Kubernetes namespace, Azure resource group and Key Vault prefix."
  default     = "platform"
}
variable "platform_runner_client_id" {
  description = "Client ID of the Snap CD Service Principal the platform Runner signs in as."
  default     = "platform-runner"
}
variable "chart_version" {
  description = "Version of the snapcd-runner chart at oci://ghcr.io/schrieksoft/charts."
  default     = "0.1.20"
}
