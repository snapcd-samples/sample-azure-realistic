// From the app namespace, which the platform team's app_tenancy_snapcd Module creates.
variable "location" {}
variable "resource_group_name" {
  description = "The tenancy's resource group, where the app's Azure resources go."
}
variable "tenant_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "kubernetes_namespace" {
  description = "The tenancy's Kubernetes namespace, where the app runs."
}
