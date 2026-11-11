variable "name" {}
variable "app_akv_url" {}
variable "keepers" {
  description = "Change to generate a new SSH key."
  default     = { iteration = 1 }
}
