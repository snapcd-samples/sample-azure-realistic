variable "cluster_oidc_issuer_url" {
  type        = string
  default     = ""
  description = "The OIDC issuer URL that corresponds to the cluster with the name 'var.cluster_name'. IRSA must have been enabled on this cluster"
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of this deployment"
}

variable "full_name" {
  type        = string
  description = "The full name that will be used for azuread_application"
  default     = ""
}

variable "service_account" {
  type        = string
  default     = ""
  description = "The name of the service account that will be federated as the service principal"

}

variable "namespace" {
  type        = string
  default     = ""
  description = "The namespace of the service account that will be federated as the service principal"
}

variable "owner_object_ids" {
  type        = list(string)
  default     = []
  description = "List of object IDs of identities to assign as `owner` on application"

}

variable "sp_owner_object_ids" {
  type        = list(string)
  default     = []
  description = "List of object IDs of identities to assign as `owner` on service principal"

}



variable "enable_federated_identity_credential" { default = false }

variable "enable_client_secret" { default = false }

variable "enable_service_principal_secret" { default = false }


variable "roles" { default = {} }

variable "roles_assigned_to_application" { default = [] }

variable "redirect_uris" { default = {} }

variable "api_permissions" { default = [] }

variable "pre_authorized_applications" { default = [] }
