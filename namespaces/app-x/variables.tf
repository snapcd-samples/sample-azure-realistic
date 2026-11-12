// Applied by hand, by a member of the app team signed in with the snapcd CLI, after platform-tenancies has created the tenancy.
variable "platform_tenancies_state_path" {
  description = "The local state file of platform-tenancies, whose outputs this configuration reads."
  default     = "../platform-tenancies/terraform.tfstate"
}
