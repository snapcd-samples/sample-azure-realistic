# platform-tenancies

You apply this configuration by hand, from your machine, after `platform-core`. It creates these items on the Snap CD Server:

- The `platform-tenancies` namespace in the `default` stack. Its Modules keep their state in the `platform` State Store.
- The supply of the `platform` Runner to the namespace.
- The Modules of the `app-x` tenancy, which run on the platform Runner:

| Module | Directory | Deploys |
|---|---|---|
| `app_tenancy_azure` | `modules/app-tenancy-azure` | The `app-x-team` resource group, the app-x Runner's workload identity and Key Vault. The identity is Contributor on its resource group, and may assign only the Key Vault roles there |
| `app_tenancy_azure_config` | `modules/app-tenancy-azure-config` | The app-x Runner's SSH key, in its Key Vault |
| `app_tenancy_k8s` | `modules/app-tenancy-k8s` | The `app-x` Kubernetes namespace, and a Role in it for the app-x Runner. The app-x Runner has no rights outside this namespace |
| `app_tenancy_snapcd` | `modules/app-tenancy-snapcd` | The `app-x` namespace in the `default` stack, the `app-x` State Store, the `app-x-runner` Service Principal with its Federated Credential, and the `app-x` Runner. The app-x Runner is supplied to the `app-x` namespace only, and is Contributor on it |
| `app_tenancy_k8s_runner` | `modules/app-tenancy-k8s-runner` | The `snapcd-runner` chart for the app-x Runner, in the `app-x` Kubernetes namespace |

`app_tenancy_name` sets the name of the tenancy. The default is `app-x`.

## Prerequisites

1. `platform-core` is applied, its Modules have run, and the platform Runner is online.
2. The snapcd CLI and OpenTofu on your machine, and a Snap CD user that is an Owner of the organization. See the [platform-core README](../platform-core/README.md).

## Apply

1. Sign in, if you have not already. See the platform-core README.
2. Copy `terraform.tfvars.example` to `terraform.tfvars`, and set the values. Git ignores `terraform.tfvars`. They are the same Azure and cluster values as in `platform-core`. The configuration finds the `default` stack, the `platform` State Store and the `platform` Runner by name.
3. Apply:

   ```bash
   cd namespaces/platform-tenancies
   tofu init
   tofu apply
   ```

4. In the Dashboard, open the `platform-tenancies` namespace and approve the jobs of its Modules.
5. Add the public SSH key of the app-x Runner to this repository as a read-only deploy key. The key is the `app_runner_ssh_public_key_openssh` output of the `app_tenancy_azure_config` Module.

## State

This configuration keeps its state in a local file, `terraform.tfstate`. Git ignores it. Keep the file: you need it to change or destroy what this configuration created.
