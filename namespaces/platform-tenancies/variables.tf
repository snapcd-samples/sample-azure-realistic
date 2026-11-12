// Applied by hand, as an organization Owner signed in with the snapcd CLI, after platform-core.
variable "platform_core_state_path" {
  description = "The local state file of platform-core, whose outputs this configuration reads."
  default     = "../platform-core/terraform.tfstate"
}
variable "namespace_name" {
  description = "The Snap CD namespace that holds the tenancies' Modules."
  default     = "platform-tenancies"
}
variable "app_tenancy_name" {
  description = "Name of the app tenancy: its Kubernetes namespace, its Snap CD namespace, State Store and Runner, and the prefix of its Azure resources."
  default     = "app-x"
}
variable "app_runner_client_id" {
  description = "Client ID of the Snap CD Service Principal the app Runner signs in as."
  default     = "app-x-runner"
}
