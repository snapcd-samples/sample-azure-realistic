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
        clientId = var.platform_workload_identity_client_id
        tenantId = var.tenant_id
      }
    }

    config = {
      appsettings = {
        Runner = {
          Id             = var.runner_id
          OrganizationId = var.organization_id
          Credentials    = { ClientId = var.runner_client_id }
        }
        Server        = { Url = var.server_url }
        RunnerEnvVars = { SNAPCD_CLIENT_ID = var.runner_client_id }
      }
    }

    // The client secret was put in the backend vault by hand; the Runner reads it with its workload identity.
    externalSettings = {
      content = {
        PeriodInSeconds = 300
        DueTimeSeconds  = 300
        ReloadEnabled   = true
        Providers = [{
          Loader        = "AzureKeyVault"
          Configuration = { VaultUrl = var.backend_akv_url }
          Data = {
            Runner        = { Credentials = { ClientSecret = var.runner_client_secret_name } }
            RunnerEnvVars = { SNAPCD_CLIENT_SECRET = var.runner_client_secret_name }
          }
        }]
      }
    }

    // The SSH key is a file, so the Secrets Store CSI driver mounts it from the platform Key Vault.
    ssh = {
      keyVolume = {
        csi = {
          driver           = "secrets-store.csi.k8s.io"
          readOnly         = true
          volumeAttributes = { secretProviderClass = "${var.name}-ssh" }
        }
      }
      keyVolumeKey = var.platform_runner_ssh_key_secret_name
    }
    extraManifests = [{
      apiVersion = "secrets-store.csi.x-k8s.io/v1"
      kind       = "SecretProviderClass"
      metadata   = { name = "${var.name}-ssh", namespace = var.name }
      spec = {
        provider = "azure"
        parameters = {
          usePodIdentity = "false"
          clientID       = var.platform_workload_identity_client_id
          keyvaultName   = var.platform_akv_name
          tenantId       = var.tenant_id
          objects = yamlencode({
            array = [yamlencode({
              objectName = var.platform_runner_ssh_key_secret_name
              objectType = "secret"
            })]
          })
        }
      }
    }]
  })]
}
