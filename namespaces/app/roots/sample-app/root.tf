terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
  }
}
