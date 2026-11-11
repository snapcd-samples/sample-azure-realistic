data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.cluster_resource_group_name
}

// Signs in as the app Runner's own workload identity. 6dae42f8-... is the AKS Entra server application.
provider "kustomization" {
  kubeconfig_raw = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name    = "aks"
      cluster = { server = data.azurerm_kubernetes_cluster.this.kube_config[0].host, certificate-authority-data = data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate }
    }]
    users = [{
      name = "runner"
      user = { exec = {
        apiVersion      = "client.authentication.k8s.io/v1beta1"
        command         = "kubelogin"
        args            = ["get-token", "--login", "workloadidentity", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
        interactiveMode = "Never"
      } }
    }]
    contexts        = [{ name = "aks", context = { cluster = "aks", user = "runner" } }]
    current-context = "aks"
  })
}
