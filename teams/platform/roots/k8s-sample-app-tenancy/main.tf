module "sample_app_tenancy" {
  source         = "../../../../modules/kustomization"
  absolute_paths = ["${path.root}/manifests"]
  patches = [
    {
      patch = templatefile("${path.module}/patches/rolebinding.yaml.tftpl", {
        principal_object_id = var.app_azure_principal_object_id
      })
    },
    {
      patch = templatefile("${path.module}/patches/gateway.yaml.tftpl", {
        hostname = var.public_gateway_fqdn
      })
    },
    {
      patch = templatefile("${path.module}/patches/certificate.yaml.tftpl", {
        hostname       = var.public_gateway_fqdn
        cluster_issuer = var.cluster_issuer
      })
    },
  ]
}
