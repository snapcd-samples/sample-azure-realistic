# teams/app/init

This is the only configuration of the app team that you apply by hand. Apply it one time, from your machine. After that, the app Runner applies everything else.

It creates the `app` Module in the tenancy's namespace, on the tenancy's Runner. The `app` Module runs `teams/app`, which creates the sample app's Modules:

| Module | Root | Deploys |
|---|---|---|
| `sample_app_infra` | `roots/sample-app-infra` | An Azure SQL server and database, a Key Vault with a demo secret, and the app's workload identity, in the tenancy's resource group |
| `sample_app_infra_config` | `roots/sample-app-infra-config` | The database user for the app's workload identity |
| `sample_app` | `roots/sample-app` | The app's Deployment and ClusterIP Service in the tenancy's Kubernetes namespace. There is no ingress |

## Prerequisites

1. The platform team has created the tenancy: the `app` namespace in the `platform` stack, and the `app` Runner, from the `app_tenancy_*` and `app_runner` Modules. See the [platform init README](../../platform/init/README.md).
2. The snapcd CLI on your machine, version 1.18.0 or later. See "Install the snapcd CLI" in the platform init README.
3. OpenTofu on your machine.
4. A Snap CD user that can create Modules in the tenancy's namespace, for example an Owner of the organization.
5. The public SSH key of the app Runner, as a read-only deploy key on this repository. The key is the `app_runner_ssh_public_key_openssh` output of the `app_tenancy_azure_config` Module.

## Apply

1. Sign in, if you have not already:

   ```bash
   snapcd context add azure --url https://<label>.<location>.cloudapp.azure.com
   snapcd login
   ```

2. Apply:

   ```bash
   cd teams/app/init
   tofu init
   tofu apply
   ```

   You need no tfvars file. The defaults find the `app` namespace in the `platform` stack. If the platform team used other names, set `tenancy_name` and `stack_name`.

3. In the Dashboard, open the `app` namespace in the `platform` stack and approve the job of the `app` Module. Then approve the jobs of the sample app's Modules.

## Reach the app

The app has no ingress. Forward a local port to its Service:

```bash
az aks get-credentials --name <cluster> --resource-group <resource-group>
kubectl -n app port-forward service/sample-app 8080:80
```

Then open `http://localhost:8080`. The page shows whether the app can reach its database and its Key Vault.

## State

This configuration keeps its state in a local file, `terraform.tfstate`. Git ignores it. Keep the file: you need it to change or destroy what this configuration created. The Modules keep their state in the tenancy's State Store.
