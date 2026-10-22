data "snapcd_runner" "platform" {
  name = var.platform_runner_name
}

data "snapcd_runner" "app" {
  name = var.app_runner_name
}

data "snapcd_service_principal" "app_runner" {
  client_id = var.app_runner_client_id
}

data "snapcd_service_principal" "app_team" {
  client_id = var.app_team_client_id
}
