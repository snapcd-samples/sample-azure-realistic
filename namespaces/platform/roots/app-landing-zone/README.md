# app-landing-zone

The Azure resource group the `app` namespace deploys into, and the app runner's Azure service principal's rights on it: Contributor, plus Role Based Access Control Administrator limited by a condition to assigning Key Vault Administrator and Key Vault Secrets User. The service principal must already exist; this module only references its object ID.
