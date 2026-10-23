data "azuread_client_config" "current" {}

module "identity" {
  source               = "../../modules/aad-identity"
  full_name            = var.name
  enable_client_secret = true
  owner_object_ids     = [data.azuread_client_config.current.object_id]
  sp_owner_object_ids  = [data.azuread_client_config.current.object_id]
}
