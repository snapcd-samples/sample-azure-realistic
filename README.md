# sample-azure-realistic

A Snap CD sample of a platform team on Azure. The platform team owns two Snap CD namespaces and a Runner. The Runner has the Azure and Kubernetes rights to create tenancies for application teams, and no more.

The sample runs on a Snap CD installation on AKS, such as the one that [snapcd-deployment-azure](https://github.com/schrieksoft/snapcd-deployment-azure) deploys. That installation supplies the cluster, the `default` stack and the `default` Runner.

The platform team creates a tenancy for an application team. The application team then deploys a sample app into its tenancy with its own Runner.

## Layout

```
namespaces/platform-core/              the platform-core namespace, the platform State Store and Runner, and the platform's Modules
namespaces/platform-tenancies/         the platform-tenancies namespace and the Modules that create the app-x tenancy
namespaces/app-x/                      the sample app's Modules, in the app-x namespace
namespaces/<namespace>/modules/<name>/ one directory for each Module in that namespace
modules/                               shared child modules
app/                                   source of the sample application
```

You apply each of the three configurations under `namespaces/` by hand, from your machine, as yourself. Each one defines the Modules of one Snap CD namespace. The Runner supplied to that namespace then applies the Modules. All namespaces are in the `default` stack.

The namespaces use path filters, so a commit starts jobs only for the Modules whose directories it changes.

## Order

| Step | You apply | It creates | The Modules run on | They deploy |
|---|---|---|---|---|
| 1 | `namespaces/platform-core` | The `platform-core` namespace, the `platform` State Store, the platform Runner's Service Principal, Federated Credential and Runner, and the Modules | The `default` Runner | The platform Runner: its Azure identity, Key Vault and SSH key, its Azure and cluster rights, and its chart. See the [platform-core README](namespaces/platform-core/README.md) |
| 2 | `namespaces/platform-tenancies` | The `platform-tenancies` namespace and the Modules | The platform Runner | The app-x tenancy: its resource group, the app-x Runner's identity, Key Vault and SSH key, the `app-x` Kubernetes namespace, the `app-x` namespace, State Store and Runner, and the app-x Runner's chart. See the [platform-tenancies README](namespaces/platform-tenancies/README.md) |
| 3 | `namespaces/app-x` | The Modules in the `app-x` namespace | The app-x Runner | The sample app. See the [app-x README](namespaces/app-x/README.md) |

Each step reads the outputs of the step before from its local state file.

The platform Modules in `platform-core` run on the `default` Runner because they deploy the platform Runner itself. The platform Runner is an Owner of the Snap CD organization, and has a custom Azure role and a ClusterRole that let it create tenancies and nothing more.

The destroy order follows Module dependencies across the namespaces: the app-x Modules before the app-x Runner, the tenancy Modules before the platform Runner.

## Identities

No Runner uses a client secret. Each Runner signs in to Snap CD with its projected ServiceAccount token. The Server accepts the token through a Federated Credential, which holds the AKS OIDC issuer and the Runner's ServiceAccount. The Runner jobs use the same token for the Snap CD provider and for the State Store.

- The `default` Runner gets its Federated Credential from the Server's preseed.
- `namespaces/platform-core` creates the platform Runner's Service Principal (`platform-runner`) and its Federated Credential.
- The `app_tenancy_snapcd` Module creates the app-x Runner's Service Principal (`app-x-runner`) and its Federated Credential.

Each Runner signs in to Azure with its workload identity.

## Deploy keys

Each Runner clones this repository over SSH with its own key. The key is generated in the Runner's Key Vault and is mounted into the Runner. Its public key is an output. Add each public key to this repository as a read-only deploy key:

| Runner | Output with the public key | Add it before |
|---|---|---|
| `default` | `snapcd_runner_ssh_public_key_openssh` of `snapcd_runner_infra_config` in snapcd-deployment-azure | You apply `namespaces/platform-core` |
| `platform` | `platform_runner_ssh_public_key_openssh` of `platform_azure_config` | The platform Runner runs its first job |
| `app-x` | `app_runner_ssh_public_key_openssh` of `app_tenancy_azure_config` | The app-x Runner runs its first job |

## State

Each configuration under `namespaces/` keeps its state in a local `terraform.tfstate`, which Git ignores. Keep the files: you need them to change or destroy what the configurations created, and the next configuration reads them. The Modules keep their state in Snap CD State Stores: `platform` for the `platform-core` and `platform-tenancies` namespaces, and `app-x` for the `app-x` namespace.

## Connect to the cluster

```bash
az login
az account set --subscription <subscription-id>
az aks get-credentials --name platform --resource-group platform
```
