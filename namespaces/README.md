# Namespaces

Each directory here is the contents of one Snap CD namespace in the `default` stack. You apply it by hand, as an Owner signed in with the snapcd CLI. The Runner supplied to the namespace then applies its Modules.

| Namespace | Created by | Modules defined by | Runner | Modules | What they deploy |
|---|---|---|---|---|---|
| `platform-core` | `namespaces/platform-core` | `namespaces/platform-core` | `default` | `platform_azure`, `platform_azure_config`, `platform_k8s`, `platform_k8s_runner` | The platform Runner: its `platform` resource group, workload identity, Key Vault and SSH key, its Azure and cluster rights, and its chart |
| `platform-tenancies` | `namespaces/platform-tenancies` | `namespaces/platform-tenancies` | `platform` | `app_tenancy_azure`, `app_tenancy_azure_config`, `app_tenancy_k8s`, `app_tenancy_snapcd`, `app_tenancy_k8s_runner` | The app-x tenancy: the `app-x-team` resource group, the app-x Runner's workload identity, Key Vault and SSH key, the `app-x` Kubernetes namespace, the `app-x` namespace, State Store and Runner, and the app-x Runner's chart |
| `app-x` | The `app_tenancy_snapcd` Module | `namespaces/app-x` | `app-x` | `sample_app_infra`, `sample_app_infra_config`, `sample_app` | The sample app: its SQL database, Key Vault and workload identity in `app-x-team`, its database user, and its Deployment and Service in the `app-x` Kubernetes namespace |

Apply them in the order of the table. `platform-tenancies` reads the outputs of `platform-core` from `../platform-core/terraform.tfstate`, and `app-x` reads the outputs of `platform-tenancies` from `../platform-tenancies/terraform.tfstate`.
