// Credentials come from the runner's SNAPCD_CLIENT_ID and SNAPCD_CLIENT_SECRET.
provider "snapcd" {
  url             = var.snapcd_server_url_from_runner
  organization_id = var.organization_id
}
