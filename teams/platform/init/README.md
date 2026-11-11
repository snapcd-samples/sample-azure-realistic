# teams/platform/init

This is the only configuration in the sample that you apply by hand. Apply it one time, from your machine. After that, the Runners in the cluster apply everything else.

It creates these items on the Snap CD Server:

- The `default` namespace in the `default` stack, with the State Store backend and the `azurerm` provider settings that its Modules use.
- The supply of the `default` Runner to that namespace.
- The `platform` Module in the `default` namespace. It runs `teams/platform` on the `default` Runner.

The `platform` Module then creates the `platform` stack, namespace, State Store and Runner, and the Modules that deploy them. See the [sample README](../../../README.md).

## Prerequisites

1. A Snap CD Server on AKS, version 1.18.0 or later, for example from snapcd-deployment-azure. Its `default` Runner and `default` State Store must exist.
2. The snapcd CLI on your machine. See "Install the snapcd CLI".
3. OpenTofu on your machine.
4. A Snap CD user that is an Owner of the organization. The preseeded `admin@preseeded.io` is an Owner.
5. The public SSH key of the `default` Runner, as a read-only deploy key on this repository. In snapcd-deployment-azure, the key is the `snapcd_runner_ssh_public_key_openssh` output of the `snapcd_runner_infra_config` Module. Without it, the `platform` Module cannot clone this repository.
6. Optional: the Azure CLI, to look up the values in step 3 of "Apply".

## Install the snapcd CLI

1. Download the zip for your platform from the assets of the latest [Snap CD release](https://github.com/schrieksoft/snapcd/releases), for example `snapcd-cli-1.18.0-linux-x64.zip`.
2. Extract the `snapcd` file (`snapcd.exe` on Windows) to a directory on your `PATH`, for example `~/.local/bin`.
3. Make sure that it runs:

   ```bash
   snapcd --version
   ```

The CLI is one self-contained file. It does not need a .NET runtime.

## Apply

1. Add a context for the Server and sign in:

   ```bash
   snapcd context add azure --url https://<label>.<location>.cloudapp.azure.com
   snapcd login
   ```

   The URL is the `url` output of the `snapcd_server_app` Module in snapcd-deployment-azure.

   `snapcd login` opens your browser. Sign in as an Owner of the organization. If you belong to more than one organization, the CLI asks which one to use.

2. Make sure that the context is correct:

   ```bash
   snapcd account show
   ```

3. Copy `terraform.tfvars.example` to `terraform.tfvars`, and set the values. Git ignores `terraform.tfvars`.

   | Variable | Value |
   |---|---|
   | `tenant_id`, `subscription_id` | `az account show --query "{tenant: tenantId, subscription: id}"` |
   | `location` | The Azure region of the cluster, for example `eastus2` |
   | `administrator_object_id` | The object ID of the Entra group that administers the platform Key Vault |
   | `cluster_name`, `cluster_resource_group_name` | The AKS cluster, `platform` and `platform` in snapcd-deployment-azure |
   | `cluster_oidc_issuer_url` | `az aks show -g <resource-group> -n <cluster> --query oidcIssuerProfile.issuerUrl -o tsv`, or the `cluster_oidc_issuer_url` output of the `cluster` Module |

   `organization_id` must be the organization of your CLI context. The default is the preseeded organization, `10000000-0000-0000-0000-000000000000`.

4. Apply:

   ```bash
   tofu init
   tofu apply
   ```

   The provider block is empty. The provider gets your access token, the Server URL and the organization from the snapcd CLI. You need no client secret.

5. In the Dashboard, open the `default` namespace and approve the job of the `platform` Module. Then approve the jobs of the Modules in the `platform` namespace.

6. Add the public SSH key of the `platform` Runner to this repository as a read-only deploy key. The key is the `platform_runner_ssh_public_key_openssh` output of the `platform_infra_config` Module.

## State

This configuration keeps its state in a local file, `terraform.tfstate`. Git ignores it. Keep the file: you need it to change or destroy what this configuration created. The Modules keep their state in Snap CD State Stores.

## Troubleshooting

### "Not logged in to context" or "The session has expired"

Run `snapcd login` again.

### The CLI cannot connect because the certificate is not trusted

A Server that uses a test certificate, for example from the Let's Encrypt staging issuer, has a certificate that your machine does not trust. Turn off the certificate check for that context:

```bash
snapcd context set azure --insecure-skip-verify true
```

Your browser also shows a warning for this certificate. Accept it there.

### The `platform` Module fails to clone the repository

The deploy key of the `default` Runner is missing or wrong. See step 5 of "Prerequisites".
