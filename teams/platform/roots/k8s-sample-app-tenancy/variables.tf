variable "app_azure_principal_object_id" {
  description = "Object ID of the existing Entra service principal the app runner signs in to the cluster as."
}
variable "public_gateway_fqdn" {}
variable "cluster_issuer" {
  default = "letsencrypt-staging"
}
