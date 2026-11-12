locals {
  state_url = "${var.server_url_from_runner}/api/${var.organization_id}/state/${var.state_store_id}"

  extra_files = merge({
    "extra_namespace_root.tf" = <<-EOT
      terraform {
        backend "http" {}
      }
    EOT
    }, var.azurerm ? {
    "extra_namespace_providers.tf" = <<-EOT
      provider "azurerm" {
        subscription_id                 = var.extra_subscription_id
        tenant_id                       = var.extra_tenant_id
        use_aks_workload_identity       = true
        resource_provider_registrations = "none"
        features {
          resource_group {
            prevent_deletion_if_contains_resources = false
          }
          key_vault {
            purge_soft_delete_on_destroy = ${var.azurerm_purge_key_vaults_on_destroy}
          }
        }
      }
    EOT
    // In their own file so a root that also declares subscription_id or tenant_id does not clash.
    "extra_namespace_variables.tf" = <<-EOT
      variable "extra_subscription_id" {}
      variable "extra_tenant_id" {}
    EOT
  } : {})

  params = merge(var.params, var.azurerm ? {
    extra_subscription_id = var.subscription_id
    extra_tenant_id       = var.tenant_id
  } : {})
}

resource "snapcd_namespace" "this" {
  name                                       = var.name
  stack_id                                   = var.stack_id
  default_engine                             = "OpenTofu"
  default_apply_approval_threshold           = var.approval_threshold
  default_destroy_approval_threshold         = var.approval_threshold
  default_state_migration_approval_threshold = var.approval_threshold
  default_trigger_path_filter_enabled        = true
}

resource "snapcd_namespace_extra_file" "this" {
  for_each     = local.extra_files
  file_name    = each.key
  contents     = each.value
  namespace_id = snapcd_namespace.this.id
  overwrite    = false
}

resource "snapcd_namespace_terraform_flag" "init" {
  for_each     = toset(["Upgrade", "MigrateState"])
  namespace_id = snapcd_namespace.this.id
  task         = "Init"
  flag         = each.value
}

// No password flag: the Runners are federated and set TF_HTTP_PASSWORD from their token.
resource "snapcd_namespace_terraform_array_flag" "backend_config" {
  for_each = {
    address        = "${local.state_url}/$${NamespaceName}--$${ModuleName}"
    lock_address   = "${local.state_url}/$${NamespaceName}--$${ModuleName}/lock"
    unlock_address = "${local.state_url}/$${NamespaceName}--$${ModuleName}/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
    username       = "$${SNAPCD_CLIENT_ID}"
  }
  namespace_id = snapcd_namespace.this.id
  task         = "Init"
  flag         = "BackendConfig"
  value        = "${each.key}=${each.value}"
}

resource "snapcd_namespace_input_from_definition" "this" {
  for_each = {
    NamespaceName = "NamespaceName"
    ModuleName    = "ModuleName"
  }
  name            = each.key
  definition_name = each.value
  usage_mode      = "UseByDefault"
  input_kind      = "EnvVar"
  namespace_id    = snapcd_namespace.this.id
}

resource "snapcd_namespace_input_from_literal" "this" {
  for_each      = local.params
  name          = each.key
  literal_value = each.value
  type          = "String"
  usage_mode    = "UseByDefault"
  input_kind    = "Param"
  namespace_id  = snapcd_namespace.this.id
}
