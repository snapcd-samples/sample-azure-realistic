module "sample_app" {
  source         = "../../../../modules/kustomization"
  absolute_paths = ["${path.root}/manifests/app"]
  namespace      = var.kubernetes_namespace
  patches = [
    {
      patch = templatefile("${path.module}/patches/serviceaccount.yaml.tftpl", {
        awi_client_id = var.sample_app_identity_client_id
        tenant_id     = var.tenant_id
      })
    },
    {
      patch = templatefile("${path.module}/patches/deployment.yaml.tftpl", {
        sql_connection_string = "Server=tcp:${var.sample_app_mssql_server_fqdn},1433;Database=${var.sample_app_mssql_database_name};Encrypt=True;Connect Timeout=30"
        key_vault_url         = var.sample_app_akv_url
        demo_secret_name      = var.sample_app_demo_secret_name
      })
    },
  ]
}
