locals {
  stack_name         = "demo"
  name               = "platform"
  app_namespace_name = "app"
  source_url         = "git@github.com:snapcd-samples/sample-deployment-azure.git"

  public_gateway_domain_name_label = "sample-app"

  before_hook_base = <<EOT
EOT
}
