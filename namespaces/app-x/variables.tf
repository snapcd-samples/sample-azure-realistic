// Applied by hand, by a member of the app team signed in with the snapcd CLI, after platform-tenancies has created the tenancy.
variable "stack_name" {
  default = "default"
}
variable "namespace_name" {
  description = "The tenancy's Snap CD namespace."
  default     = "app-x"
}
variable "runner_name" {
  description = "The tenancy's Runner, which runs this namespace's Modules."
  default     = "app-x"
}
variable "source_url" {
  default = "git@github.com:snapcd-samples/sample-azure-realistic.git"
}
variable "source_revision" {
  default = "main"
}
