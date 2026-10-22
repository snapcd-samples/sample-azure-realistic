# sample-deployment-azure

A Snap CD deployment of an AKS-based platform on Azure, with every module in this one repo.

The workload is `sample-app` (source in `app/`), a small .NET app that signs in with a workload identity and shows whether it can reach its Azure SQL database and Key Vault. It is served over HTTPS at `https://<label>.<region>.cloudapp.azure.com/`, where the label is `public_gateway_domain_name_label` in `locals.tf` and the certificate comes from Let's Encrypt. With the current settings that is `https://sample-app.eastus2.cloudapp.azure.com/`.

## Layout

```
namespaces/platform/        Terraform root: stack `demo`, namespaces `platform` and `app`, and the platform modules
namespaces/platform/roots/  the platform modules' root modules, one per Snap CD module (each has its own state)
namespaces/app/             Terraform root: the sample-app modules, deployed into the `app` namespace created by platform
namespaces/app/roots/       the sample-app modules' root modules
modules/                    shared child modules, referenced from the roots by relative path
app/                        sample-app source, Dockerfile; published to GHCR by .github/workflows/sample-app.yaml
```

Each `snapcd_module` points at this repo with `source_subdirectory = "namespaces/<namespace>/roots/<name>"`. The namespaces set `default_trigger_path_filter_enabled = true`, so a commit only redeploys the modules whose directories it touches. Relative module calls such as `../../../../modules/akv` count as part of the calling module's watched directories.

`namespaces/app` looks up the stack, the `app` namespace and the platform modules it depends on with data sources, so `platform` must be applied first.

## Separation between platform and app

The `app` namespace shows how Snap CD and Azure permissions keep an application team inside its own boundary. Three identities must exist beforehand; their names and IDs are variables, never created here:

- **The app team** - a Snap CD service principal. `namespaces/app` is applied with its credentials. It is Owner of the `app` namespace and MetadataReader on the `demo` stack and on the app runner, so it can look up the platform modules it takes outputs from.
- **The app runner** - a Snap CD runner and its Snap CD service principal. It is supplied to the `app` namespace only, and is Contributor on the `app` state store, which holds the app modules' state.
- **The app runner's Azure identity** - an existing Entra service principal the app runner signs in to Azure as. Platform's `app_landing_zone` gives it Contributor on the `app` resource group and Role Based Access Control Administrator there, limited to assigning Key Vault Administrator and Key Vault Secrets User. Platform's `sample_app_tenancy` gives it a Role in the `sample-app` Kubernetes namespace, and nothing elsewhere in the cluster.

The platform runner is supplied to the `platform` namespace only. Its Snap CD identity is expected to be an Organization Owner and its Azure identity to have broad rights on the subscription.

## Modules

```
platform:  base ──> network ──┬──> cluster ──> istio, cert_manager ──> cert_manager_cluster_issuer, awi_webhook
                              ├──> istio_infra ──> istio
                              └──> sql_server
           app_landing_zone
           cluster, istio_infra, istio, cert_manager_cluster_issuer ──> sample_app_tenancy

app:       sample_app_infra ──> sample_app_infra_config ──> sample_app
           sample_app_infra takes outputs from platform's app_landing_zone and cluster; sample_app from cluster and istio_infra, and waits for sample_app_tenancy and awi_webhook
```

## Usage

Copy the examples and fill them in. They are gitignored.

```bash
cp namespaces/platform/terraform.tfvars.example namespaces/platform/terraform.tfvars  # platform credentials, runner names, app identities, subscription
cp namespaces/app/terraform.tfvars.example namespaces/app/terraform.tfvars            # app team credentials, app runner name
```

Then, for `platform` first and `app` second:

```bash
cd namespaces/platform
source ../../az.sh
terraform init
terraform apply
```

Both roots keep their own state locally (`terraform.tfstate`, gitignored). Module state is kept in Snap CD state stores: `default` for `platform`, `app` for `app`.

## Connect to the cluster

```bash
az login
az account set --subscription <subscription-id>
az aks get-credentials --name platform --resource-group platform
```
