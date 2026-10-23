variable "tenant_id" {
  type = string
}

variable "name" {
  type        = string
  default     = "app-runner"
  description = "Display name of the app registration and its service principal"
}
