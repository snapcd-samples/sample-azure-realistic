# sample-app

Deploys `sample-app` (source in `app/` at the repo root) into the `sample-app` namespace, and attaches its VirtualService to the `istio-gateway/sample-app` Gateway. The namespace, the Gateway, the certificate and this module's Kubernetes rights come from the platform's `k8s-sample-app-tenancy` module.

The module signs in to the cluster as the runner's Azure identity, with an Entra token for the AKS server application, and can only manage the resource kinds the platform's Role allows in `sample-app`.

The pod runs as the `sample-app` service account, federated with the managed identity from `sample_app_infra`, and reaches Azure SQL and Key Vault with that identity. No secrets are passed to the pod.
