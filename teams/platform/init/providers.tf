provider "snapcd" {
  url             = var.snapcd_url
  client_id       = var.snapcd_client_id
  client_secret   = var.snapcd_client_secret
  organization_id = var.organization_id
}
