# sample-azure-realistic

A Snap CD sample of a platform team on Azure. The platform team owns a Snap CD namespace and a Runner. The Runner has the Azure and Kubernetes rights to create tenancies for application teams, and no more.

The sample runs on a Snap CD installation on AKS, such as the one that [snapcd-deployment-azure](https://github.com/schrieksoft/snapcd-deployment-azure) deploys. That installation supplies the cluster, the `default` stack, the `default` State Store and the `default` Runner.

The platform team creates a tenancy for an application team. The application team's own configuration (`teams/app`) is not updated for this layout yet.

## Layout

```
teams/platform/init/          applied once by hand: the `default` namespace and the `platform` Module
teams/platform/               the `platform` Module: the platform stack, namespace, State Store, Runner and its Modules
teams/platform/roots/<name>/  one directory for each Module in the platform namespace
teams/app/                    the application team (not updated yet)
modules/                      shared child modules
app/                          source of the sample application
```

Each Module reads its code from this repository. The namespaces use path filters, so a commit starts jobs only for the Modules whose directories it changes.

## How it runs

1. You apply `teams/platform/init` from your machine. It creates the `default` namespace in the `default` stack, and the `platform` Module in it, on the `default` Runner.
2. The `default` Runner applies `teams/platform`. This creates the `platform` stack, State Store and namespace, the `platform` Runner, and the Modules below.
3. The `default` Runner applies the Modules in the `platform` namespace:

| Module | Root | Deploys |
|---|---|---|
| `platform_infra` | `roots/platform-infra` | The `platform-team` resource group, the platform Runner's workload identity and Key Vault, and its Azure rights to create tenancies |
| `platform_infra_config` | `roots/platform-infra-config` | The platform Runner's SSH key, in its Key Vault |
| `platform_k8s` | `roots/platform-k8s` | The `platform` Kubernetes namespace, and the platform Runner's cluster rights to create tenancies |
| `platform_runner` | `roots/platform-runner` | The `snapcd-runner` chart for the platform Runner |

The resource group is `platform-team` because the cluster's own resource group can already be called `platform`.

4. The platform Runner applies the app tenancy. These Modules are also in the `platform` namespace, but they run on the platform Runner, with its limited rights:

| Module | Root | Deploys |
|---|---|---|
| `app_tenancy_azure` | `roots/app-tenancy-azure` | The `app-team` resource group, the app Runner's workload identity and Key Vault. The identity is Contributor on its resource group, and may assign only the Key Vault roles there |
| `app_tenancy_azure_config` | `roots/app-tenancy-azure-config` | The app Runner's SSH key, in its Key Vault |
| `app_tenancy_k8s` | `roots/app-tenancy-k8s` | The `app` Kubernetes namespace, and a Role in it for the app Runner. The app Runner has no rights outside this namespace |
| `app_tenancy_snapcd` | `roots/app-tenancy-snapcd` | The `app` stack, State Store and namespace, the `app-runner` Service Principal with its Federated Credential, and the `app` Runner. The app Runner is supplied to the `app` namespace only |
| `app_runner` | `roots/app-runner` | The `snapcd-runner` chart for the app Runner, in the `app` Kubernetes namespace |

To give the platform Runner these rights, `teams/platform` makes it an Owner of the Snap CD organization, `platform_infra` gives it a custom Azure role that can create resource groups, managed identities and Key Vaults and can assign only the roles a tenancy hands out, and `platform_k8s` gives it a ClusterRole to create namespaces and install Runners.

`app_tenancy_name` in `teams/platform` sets the name of the tenancy. The default is `app`.

## Identities

No Runner uses a client secret. Each Runner signs in to Snap CD with its projected ServiceAccount token. The Server accepts the token through a Federated Credential, which holds the AKS OIDC issuer and the Runner's ServiceAccount. The Runner jobs use the same token for the Snap CD provider and for the State Store.

- The `default` Runner gets its Federated Credential from the Server's preseed.
- `teams/platform` creates the platform Runner's Service Principal (`platform-runner`) and its Federated Credential.

Each Runner signs in to Azure with its workload identity.

## Deploy keys

Each Runner clones this repository over SSH with its own key. The key is generated in the Runner's Key Vault and is mounted into the Runner. Its public key is an output. Add each public key to this repository as a read-only deploy key:

| Runner | Output with the public key | Add it before |
|---|---|---|
| `default` | `snapcd_runner_ssh_public_key_openssh` of `snapcd_runner_infra_config` in snapcd-deployment-azure | You apply `teams/platform/init` |
| `platform` | `platform_runner_ssh_public_key_openssh` of `platform_infra_config` | The platform Runner runs its first job |
| `app` | `app_runner_ssh_public_key_openssh` of `app_tenancy_azure_config` | The app Runner runs its first job |

## Usage

You need the snapcd CLI on your machine, version 1.18.0 or later. You apply `teams/platform/init` one time, as yourself, signed in with `snapcd login`. No client secret is necessary. The [init README](teams/platform/init/README.md) tells you how to install the CLI and how to apply.

In short:

```bash
snapcd context add azure --url https://<label>.<location>.cloudapp.azure.com
snapcd login
cd teams/platform/init
cp terraform.tfvars.example terraform.tfvars   # then set the values
tofu init
tofu apply
```

Then, in the Dashboard, approve the `platform` Module in the `default` namespace, and then the Modules in the `platform` namespace.

`teams/platform/init` keeps its state locally (`terraform.tfstate`, which Git ignores). The Modules keep their state in Snap CD State Stores: `default` for the `default` namespace, `platform` for the `platform` namespace.

## Connect to the cluster

```bash
az login
az account set --subscription <subscription-id>
az aks get-credentials --name platform --resource-group platform
```
