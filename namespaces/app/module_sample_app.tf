resource "snapcd_module" "sample_app" {
  name                 = "sample_app"
  namespace_id         = data.snapcd_namespace.app.id
  source_revision      = "main"
  source_revision_type = "Default"
  source_type          = "Git"
  source_url           = local.source_url
  source_subdirectory  = "namespaces/app/roots/sample-app"
  runner_id            = data.snapcd_runner.app.id
}


resource "snapcd_module_input_from_output_set" "sample_app" {
  for_each = { for obj in [
    {
      name             = "from_sample_app_infra"
      output_module_id = snapcd_module.sample_app_infra.id
      input_kind       = "Param"
    },
    {
      name             = "from_sample_app_infra_config"
      output_module_id = snapcd_module.sample_app_infra_config.id
      input_kind       = "Param"
    },
    {
      name             = "from_istio_infra"
      output_module_id = data.snapcd_module.istio_infra.id
      input_kind       = "Param"
    },
  ] : obj.name => obj }
  name             = each.value.name
  output_module_id = each.value.output_module_id
  input_kind       = each.value.input_kind
  module_id        = snapcd_module.sample_app.id
}


resource "snapcd_module_input_from_output" "sample_app" {
  for_each = {
    extra_cluster_host           = "cluster_host"
    extra_cluster_ca_certificate = "cluster_ca_certificate"
  }
  name             = each.key
  output_name      = each.value
  output_module_id = data.snapcd_module.cluster.id
  input_kind       = "Param"
  module_id        = snapcd_module.sample_app.id
}

// Signs in to AKS as the runner's own Azure identity (ARM_* env vars); 6dae42f8-... is the AKS Entra server application.
resource "snapcd_module_extra_file" "sample_app" {
  for_each = { for obj in [
    {
      file_name = "extra_module_providers.tf"
      contents  = <<EOT
provider "kustomization" {
  kubeconfig_raw = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters   = [{ name = "aks", cluster = { server = var.extra_cluster_host, certificate-authority-data = base64encode(var.extra_cluster_ca_certificate) } }]
    users = [{ name = "runner", user = { exec = {
      apiVersion      = "client.authentication.k8s.io/v1beta1"
      command         = "kubelogin"
      args            = ["get-token", "--login", "spn", "--use-azurerm-env-vars", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
      interactiveMode = "Never"
    } } }]
    contexts        = [{ name = "aks", context = { cluster = "aks", user = "runner" } }]
    current-context = "aks"
  })
}
  EOT
    },
    {
      file_name = "extra_module_variables.tf"
      contents  = <<EOT
variable "extra_cluster_host" {
  sensitive = true
}
variable "extra_cluster_ca_certificate" {
  sensitive = true
}
  EOT
    },
  ] : obj.file_name => obj }

  file_name = each.value.file_name
  contents  = each.value.contents
  module_id = snapcd_module.sample_app.id
  overwrite = false
}

// The namespace, the deploy rights and the Gateway come from sample_app_tenancy_k8s; the pod's token injection from awi_webhook.
resource "snapcd_depends_on_module" "sample_app" {
  for_each = {
    sample_app_tenancy_k8s = data.snapcd_module.sample_app_tenancy_k8s.id
    awi_webhook            = data.snapcd_module.awi_webhook.id
  }
  module_id            = snapcd_module.sample_app.id
  depends_on_module_id = each.value
}
