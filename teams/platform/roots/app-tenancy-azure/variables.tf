variable "name" {
  description = "Name of the tenancy: its Kubernetes namespace and Runner ServiceAccount, and the prefix of its Azure resources. Its resource group is <name>-team."
}
variable "location" {}
variable "tenant_id" {}
variable "administrator_object_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
