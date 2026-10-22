variable "location" {
  description = "The location into which to deploy Azure resources"
}
variable "app_resource_group_name" {
  description = "The resource group into which to deploy Azure resources"
}
variable "tenant_id" {
  description = "Azure tenant ID"
}
variable "administrator_object_id" {
  description = "Object ID of the Azure AD Group that acts as administrator for Key Vault"
}
variable "cluster_name" {
  description = "Name of the Kubernetes cluster that we are deploying manifests to in this module."
}
variable "cluster_oidc_issuer_url" {
  description = "Name of the OIDC issuer for Kubernetes cluster that we are deploying manifests to in this module."
}

