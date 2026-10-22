# k8s-sample-app-tenancy

What the platform provides to the app team in the cluster:

- The `sample-app` namespace, pinned to the `d2s` node pool.
- A Role and RoleBinding that let the app runner's Azure service principal (an Entra user to Kubernetes, named by its object ID) manage Deployments, Services, ServiceAccounts, ConfigMaps, Secrets and Istio VirtualServices in that namespace only.
- The `sample-app` Gateway in `istio-gateway`, serving HTTPS for `public_gateway_fqdn` and accepting VirtualServices from the `sample-app` namespace only, and the cert-manager Certificate it uses. `cluster_issuer` defaults to `letsencrypt-staging`; set it to `letsencrypt-prod` once the staging certificate is served.
