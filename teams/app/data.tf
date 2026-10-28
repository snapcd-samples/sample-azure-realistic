data "snapcd_runner" "app" {
  name = var.app_runner_name
}

data "snapcd_stack" "this" {
  name = local.stack_name
}

data "snapcd_namespace" "app" {
  name     = local.name
  stack_id = data.snapcd_stack.this.id
}

data "snapcd_namespace" "platform" {
  name     = local.platform_namespace_name
  stack_id = data.snapcd_stack.this.id
}

data "snapcd_module" "cluster" {
  name         = "cluster"
  namespace_id = data.snapcd_namespace.platform.id
}

data "snapcd_module" "istio_infra" {
  name         = "istio_infra"
  namespace_id = data.snapcd_namespace.platform.id
}

data "snapcd_module" "sample_app_tenancy_azure" {
  name         = "sample_app_tenancy_azure"
  namespace_id = data.snapcd_namespace.platform.id
}

data "snapcd_module" "sample_app_tenancy_k8s" {
  name         = "sample_app_tenancy_k8s"
  namespace_id = data.snapcd_namespace.platform.id
}

data "snapcd_module" "awi_webhook" {
  name         = "awi_webhook"
  namespace_id = data.snapcd_namespace.platform.id
}
