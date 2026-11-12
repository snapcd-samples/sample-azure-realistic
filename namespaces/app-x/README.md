# app-x

You apply this configuration by hand, from your machine, after `platform-tenancies`. It creates the sample app's Modules in the `app-x` namespace, on the app-x Runner. `platform-tenancies` created that namespace and Runner.

| Module | Directory | Deploys |
|---|---|---|
| `sample_app_infra` | `modules/sample-app-infra` | An Azure SQL server and database, a Key Vault with a demo secret, and the app's workload identity, in the tenancy's resource group |
| `sample_app_infra_config` | `modules/sample-app-infra-config` | The database user for the app's workload identity |
| `sample_app` | `modules/sample-app` | The app's Deployment and ClusterIP Service in the tenancy's Kubernetes namespace. There is no ingress |

`sample_app_infra` depends on the tenancy's `app_tenancy_k8s_runner` Module, so a destroy removes the sample app before the app-x Runner.

## Prerequisites

1. `platform-tenancies` is applied, its Modules have run, and the app-x Runner is online.
2. The app-x Runner's public SSH key is a read-only deploy key on this repository. See the [platform-tenancies README](../platform-tenancies/README.md).
3. The snapcd CLI and OpenTofu on your machine, and a Snap CD user that can create Modules in the `app-x` namespace, for example an Owner of the organization.

## Apply

1. Sign in, if you have not already. See the [platform-core README](../platform-core/README.md).
2. Apply:

   ```bash
   cd namespaces/app-x
   tofu init
   tofu apply
   ```

   You need no tfvars file. The configuration reads the tenancy from the outputs of `platform-tenancies`, in `../platform-tenancies/terraform.tfstate`.

3. In the Dashboard, open the `app-x` namespace and approve the jobs of the sample app's Modules.

## Reach the app

The app has no ingress. Forward a local port to its Service:

```bash
az aks get-credentials --name <cluster> --resource-group <resource-group>
kubectl -n app-x port-forward service/sample-app 8080:80
```

Then open `http://localhost:8080`. The page shows whether the app can reach its database and its Key Vault.

## State

This configuration keeps its state in a local file, `terraform.tfstate`. Git ignores it. Keep the file: you need it to change or destroy what this configuration created. The Modules keep their state in the `app-x` State Store.
