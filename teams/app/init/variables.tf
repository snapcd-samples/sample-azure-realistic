// Applied once by hand, by a member of the app team signed in with the snapcd CLI.
variable "tenancy_name" {
  description = "Name of the tenancy that the platform team created: its Snap CD namespace and Runner."
  default     = "app"
}
variable "stack_name" {
  description = "The stack that holds the tenancy's namespace."
  default     = "default"
}
variable "server_url_from_runner" {
  description = "The Snap CD Server, as the Runners in the cluster reach it."
  default     = "http://snapcd-server.snapcd-server.svc.cluster.local:5000"
}
variable "organization_id" {
  description = "The organization of your snapcd CLI context."
  default     = "10000000-0000-0000-0000-000000000000"
}
variable "source_url" {
  default = "git@github.com:snapcd-samples/sample-azure-realistic.git"
}
variable "source_revision" {
  default = "main"
}
variable "tenancies_namespace_name" {
  description = "The namespace that holds the tenancy's app_runner Module."
  default     = "app-tenancies"
}
