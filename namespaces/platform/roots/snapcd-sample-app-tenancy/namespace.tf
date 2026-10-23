locals {
  state_url = "${var.snapcd_server_url_from_runner}/api/${var.organization_id}/state/${snapcd_state_store.this.id}"
}


resource "snapcd_namespace" "this" {
  name                                = var.namespace_name
  stack_id                            = var.stack_id
  default_engine                      = "OpenTofu"
  default_apply_approval_threshold    = 1
  default_destroy_approval_threshold  = 1
  default_trigger_path_filter_enabled = true
}

resource "snapcd_namespace_hook" "default_before_hooks" {
  for_each = toset([
    "Init",
    "Validate",
    "Plan",
    "Apply",
    "Output",
    "PlanDestroy",
    "Destroy",
  ])

  namespace_id = snapcd_namespace.this.id
  task         = each.value
  phase        = "Before"
  script       = var.before_hook_script
}

resource "snapcd_namespace_terraform_flag" "flags" {
  for_each = toset(["Upgrade", "MigrateState"])

  namespace_id = snapcd_namespace.this.id
  task         = "Init"
  flag         = each.value
}


resource "snapcd_namespace_terraform_array_flag" "backend_config" {
  for_each = {
    address        = "${local.state_url}/$${NamespaceName}--$${ModuleName}"
    lock_address   = "${local.state_url}/$${NamespaceName}--$${ModuleName}/lock"
    unlock_address = "${local.state_url}/$${NamespaceName}--$${ModuleName}/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
    username       = "$${SNAPCD_CLIENT_ID}"
    password       = "$${SNAPCD_CLIENT_SECRET}"
  }

  namespace_id = snapcd_namespace.this.id
  task         = "Init"
  flag         = "BackendConfig"
  value        = "${each.key}=${each.value}"
}


resource "snapcd_namespace_input_from_definition" "this" {
  for_each = { for obj in [

    // Params
    {
      name            = "stack_id"
      definition_name = "StackId"
      usage_mode      = "UseIfSelected"
      input_kind      = "Param"
    },
    {
      name            = "namespace"
      definition_name = "NamespaceName"
      usage_mode      = "UseByDefault"
      input_kind      = "Param"
    },
    {
      name            = "target_revision"
      definition_name = "SourceRevision"
      usage_mode      = "UseByDefault"
      input_kind      = "Param"
    },
    {
      name            = "repo_url"
      definition_name = "SourceUrl"
      usage_mode      = "UseByDefault"
      input_kind      = "Param"
    },

    // Env Vars
    {
      name            = "StackName"
      definition_name = "StackName"
      usage_mode      = "UseByDefault"
      input_kind      = "EnvVar"
    },
    {
      name            = "NamespaceName"
      definition_name = "NamespaceName"
      usage_mode      = "UseByDefault"
      input_kind      = "EnvVar"
    },
    {
      name            = "ModuleName"
      definition_name = "ModuleName"
      usage_mode      = "UseByDefault"
      input_kind      = "EnvVar"
    },
    {
      name            = "ModuleId"
      definition_name = "ModuleId"
      usage_mode      = "UseByDefault"
      input_kind      = "EnvVar"
    },
  ] : obj.name => obj }

  name            = each.value.name
  definition_name = each.value.definition_name
  usage_mode      = each.value.usage_mode
  namespace_id    = snapcd_namespace.this.id
  input_kind      = each.value.input_kind
}

resource "snapcd_namespace_input_from_literal" "this" {
  for_each = { for obj in [

    // EnvVars


    // Params
    {
      name          = "location"
      literal_value = var.location
      type          = "String"
      usage_mode    = "UseByDefault"
      input_kind    = "Param"
    },
    {
      name          = "subscription_id"
      literal_value = var.subscription_id
      type          = "String"
      usage_mode    = "UseByDefault"
      input_kind    = "Param"
    },
    {
      name          = "tenant_id"
      literal_value = var.tenant_id
      type          = "String"
      usage_mode    = "UseByDefault"
      input_kind    = "Param"
    },
    {
      name          = "extra_subscription_id"
      literal_value = var.subscription_id
      type          = "String"
      usage_mode    = "UseByDefault"
      input_kind    = "Param"
    },
    {
      name          = "extra_tenant_id"
      literal_value = var.tenant_id
      type          = "String"
      usage_mode    = "UseByDefault"
      input_kind    = "Param"
    },




    {
      name          = "administrator_object_id"
      literal_value = var.administrator_object_id
      type          = "String"
      usage_mode    = "UseByDefault"
      input_kind    = "Param"
    },
  ] : obj.name => obj }

  name          = each.value.name
  type          = each.value.type
  literal_value = each.value.literal_value
  usage_mode    = each.value.usage_mode
  namespace_id  = snapcd_namespace.this.id
  input_kind    = each.value.input_kind
}

resource "snapcd_namespace_extra_file" "this" {
  for_each = { for obj in [
    {
      file_name = "extra_namespace_root.tf"
      contents  = <<EOT
terraform {
  backend "http" {}
}
  EOT
    },
    {
      file_name = "extra_namespace_providers.tf"
      contents  = <<EOT
provider "azurerm" {
  subscription_id                 = var.extra_subscription_id
  tenant_id                       = var.extra_tenant_id
  resource_provider_registrations = "none"
  features {}
}

provider "azurerm" {
  alias                           = "default"
  subscription_id                 = var.extra_subscription_id
  tenant_id                       = var.extra_tenant_id
  resource_provider_registrations = "none"
  features {
    key_vault {
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_secrets_on_destroy = false
      purge_soft_deleted_keys_on_destroy    = false
      recover_soft_deleted_keys             = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

  EOT
    },
    {
      file_name = "extra_namespace_variables.tf"
      contents  = <<EOT
variable "extra_subscription_id" {}
variable "extra_tenant_id" {}
  EOT
    },
  ] : obj.file_name => obj }

  file_name    = each.value.file_name
  contents     = each.value.contents
  namespace_id = snapcd_namespace.this.id
  overwrite    = false
}
