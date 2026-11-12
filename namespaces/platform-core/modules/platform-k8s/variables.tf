variable "name" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "platform_workload_identity_principal_id" {
  description = "Object ID of the platform Runner's managed identity, its user name in the cluster."
}
