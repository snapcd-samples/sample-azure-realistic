variable "resource_group_name" {
  type = string
  description = "Name of the resource group to deploy"
}

variable "location" {
  type = string
  description = "Location into which to deploy Azure resources"
}

variable "administrator_object_id" {}

variable "name" {
  type        = string
  description = "Prefix for the SQL server name"
}
