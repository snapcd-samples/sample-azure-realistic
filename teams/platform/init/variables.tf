// Applied once by hand, with an organization Owner's credentials.
variable "snapcd_url" {
  description = "The Snap CD Server, as this machine reaches it."
}
variable "snapcd_client_id" {
  default = "default"
}
variable "snapcd_client_secret" {
  sensitive = true
}
variable "organization_id" {
  default = "10000000-0000-0000-0000-000000000000"
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

// Passed to teams/platform.
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
variable "platform_runner_client_id" {
  description = "Client ID of the Snap CD Service Principal the platform Runner signs in as. teams/platform creates it."
  default     = "platform-runner"
}
