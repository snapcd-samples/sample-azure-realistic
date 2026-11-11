// From the app namespace, which the platform team's app_tenancy_snapcd Module creates.
variable "tenant_id" {}
variable "cluster_name" {}
variable "cluster_resource_group_name" {}
variable "kubernetes_namespace" {}

// From sample_app_infra and sample_app_infra_config.
variable "sample_app_mssql_server_fqdn" {}
variable "sample_app_mssql_database_name" {}
variable "sample_app_akv_url" {}
variable "sample_app_demo_secret_name" {}
variable "sample_app_identity_client_id" {}
