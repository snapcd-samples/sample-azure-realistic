variable "snapcd_url" {
  default = "http://localhost:9000"
}
variable "snapcd_client_id" {}
variable "snapcd_client_secret" {
  sensitive = true
}
variable "snapcd_organization_id" {}
variable "app_runner_name" {}
