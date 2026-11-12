provider "azrandom" {
  vault_url                              = var.platform_akv_url
  disable_workload_identity_credential   = false
  disable_environment_credential         = true
  disable_managed_identity_credential    = true
  disable_azure_developer_cli_credential = true
  disable_azure_cli_credential           = true
}
