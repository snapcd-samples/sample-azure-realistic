variable "name" {
  description = "Name of the tenancy: its Kubernetes namespace."
}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "app_workload_identity_principal_id" {
  description = "Object ID of the app Runner's managed identity, its user name in the cluster."
}
