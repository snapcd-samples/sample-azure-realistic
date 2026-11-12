resource "helm_release" "runner" {
  name       = var.name
  namespace  = var.name
  repository = "oci://ghcr.io/schrieksoft/charts"
  chart      = "snapcd-runner"
  version    = var.chart_version
  wait       = true
  atomic     = true
  timeout    = 600

  values = [yamlencode({
    fullnameOverride = var.name

    workloadIdentity = {
      azure = {
        clientId = var.app_workload_identity_client_id
        tenantId = var.tenant_id
      }
    }

    // The Runner and its jobs authenticate with the projected ServiceAccount token, which matches
    // the Federated Credential app_tenancy_snapcd creates.
    credentials = {
      mode = "Federated"
    }

    config = {
      appsettings = {
        Runner = {
          Id             = var.app_runner_id
          OrganizationId = var.organization_id
          Credentials    = { ClientId = var.app_runner_client_id }
        }
        Server        = { Url = var.server_url }
        RunnerEnvVars = { SNAPCD_CLIENT_ID = var.app_runner_client_id }
      }
    }

    // The SSH key is a file, so the Secrets Store CSI driver mounts it from the app Key Vault.
    ssh = {
      keyVolume = {
        csi = {
          driver           = "secrets-store.csi.k8s.io"
          readOnly         = true
          volumeAttributes = { secretProviderClass = "${var.name}-ssh" }
        }
      }
      keyVolumeKey = var.app_runner_ssh_key_secret_name
    }
    extraManifests = [{
      apiVersion = "secrets-store.csi.x-k8s.io/v1"
      kind       = "SecretProviderClass"
      metadata   = { name = "${var.name}-ssh", namespace = var.name }
      spec = {
        provider = "azure"
        parameters = {
          usePodIdentity = "false"
          clientID       = var.app_workload_identity_client_id
          keyvaultName   = var.app_akv_name
          tenantId       = var.tenant_id
          objects = yamlencode({
            array = [yamlencode({
              objectName = var.app_runner_ssh_key_secret_name
              objectType = "secret"
            })]
          })
        }
      }
    }]
  })]
}
