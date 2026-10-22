variable "location" {}
variable "app_resource_group_name" {}
variable "app_azure_principal_object_id" {
  description = "Object ID of the existing Entra service principal the app runner signs in to Azure as."
}
