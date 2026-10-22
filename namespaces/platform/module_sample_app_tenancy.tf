resource "snapcd_module" "sample_app_tenancy" {
  name                 = "sample_app_tenancy"
  namespace_id         = module.namespace[local.name].id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/platform/roots/k8s-sample-app-tenancy"
  runner_id            = data.snapcd_runner.platform.id
}


resource "snapcd_module_input_from_output" "sample_app_tenancy" {
  for_each = { for obj in [
    {
      name             = "extra_kubeconfig"
      output_name      = "cluster_kube_admin_config_raw"
      output_module_id = snapcd_module.cluster.id
      input_kind       = "Param"
    },

  ] : obj.name => obj }
  name             = each.value.name
  output_name      = each.value.output_name
  output_module_id = each.value.output_module_id
  input_kind       = each.value.input_kind
  module_id        = snapcd_module.sample_app_tenancy.id
}

resource "snapcd_module_input_from_output_set" "sample_app_tenancy" {
  name             = "from_istio_infra"
  output_module_id = snapcd_module.istio_infra.id
  input_kind       = "Param"
  module_id        = snapcd_module.sample_app_tenancy.id
}

resource "snapcd_module_input_from_literal" "sample_app_tenancy" {
  name          = "app_azure_principal_object_id"
  literal_value = var.app_azure_principal_object_id
  type          = "String"
  input_kind    = "Param"
  module_id     = snapcd_module.sample_app_tenancy.id
}

resource "snapcd_module_extra_file" "sample_app_tenancy" {
  for_each = { for obj in [
    {
      file_name = "extra_module_providers.tf"
      contents  = <<EOT
provider "kustomization" {
  kubeconfig_raw = var.extra_kubeconfig
}
  EOT
    },
    {
      file_name = "extra_module_variables.tf"
      contents  = <<EOT
variable "extra_kubeconfig" {
    sensitive = true
}
  EOT
    },
  ] : obj.file_name => obj }

  file_name = each.value.file_name
  contents  = each.value.contents
  module_id = snapcd_module.sample_app_tenancy.id
  overwrite = false
}

// The Gateway and Certificate need the Istio and cert-manager CRDs, and the Certificate needs the issuers.
resource "snapcd_depends_on_module" "sample_app_tenancy" {
  for_each = {
    istio                       = snapcd_module.istio.id
    cert_manager_cluster_issuer = snapcd_module.cert_manager_cluster_issuer.id
  }
  module_id            = snapcd_module.sample_app_tenancy.id
  depends_on_module_id = each.value
}
