// The app runner runs the app namespace's jobs and reads and writes its state.
resource "snapcd_runner_namespace_supply" "app" {
  runner_id    = data.snapcd_runner.app.id
  namespace_id = module.namespace[local.app_namespace_name].id
}

resource "snapcd_state_store_role_assignment" "app_runner" {
  state_store_id          = snapcd_state_store.app.id
  principal_id            = data.snapcd_service_principal.app_runner.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "Contributor"
}

// The app team owns the app namespace and can look up the stack, the platform modules it takes outputs from, and the app runner.
resource "snapcd_namespace_role_assignment" "app_team_owner" {
  namespace_id            = module.namespace[local.app_namespace_name].id
  principal_id            = data.snapcd_service_principal.app_team.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "Owner"
}

resource "snapcd_stack_role_assignment" "app_team_metadata_reader" {
  stack_id                = snapcd_stack.this.id
  principal_id            = data.snapcd_service_principal.app_team.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "MetadataReader"
}

resource "snapcd_runner_role_assignment" "app_team_metadata_reader" {
  runner_id               = data.snapcd_runner.app.id
  principal_id            = data.snapcd_service_principal.app_team.id
  principal_discriminator = "ServicePrincipal"
  role_name               = "MetadataReader"
}
